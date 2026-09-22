import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connecthub/core/services/image_bb_service.dart';
import 'package:connecthub/core/utils/mention_helper.dart';
import 'package:connecthub/features/post/data/repos/post_repo.dart';

class PostRepoImp implements PostRepo {
  final CollectionReference _postsCollection =
      FirebaseFirestore.instance.collection('posts');

  @override
  Future<String> createPost({
    required String title,
    required String description,
    File? image,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('You must be logged in to create a post.');
    }

    String userName = (user.displayName ?? '').trim();
    if (userName.isEmpty) {
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (userDoc.exists && userDoc.data() != null) {
          final data = userDoc.data() as Map<String, dynamic>;
          userName = data['name'] ?? '';
        }
      } catch (_) {}
    }
    if (userName.isEmpty) {
      userName = user.email?.split('@').first ?? 'User';
    }

    String? imageUrl;
    String? deleteHash;

    if (image != null) {
      final bytes = await image.readAsBytes();
      final base64Image = base64Encode(bytes);
      final uploadResult =
          await ImageBBService.uploadImageDetailed(base64Image);
      if (uploadResult == null) {
        throw Exception('Failed to upload image. Please try again.');
      }
      imageUrl = uploadResult.url;
      deleteHash = uploadResult.deleteHash;
    }

    try {
      final docRef = await _postsCollection.add({
        'userId': user.uid,
        'userName': userName,
        'title': title.trim(),
        'description': description.trim(),
        'imageUrl': imageUrl,
        'deleteHash': deleteHash,
        'likes': [],
        'likeCount': 0,
        'commentCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw Exception(
            'Firestore permission denied. Please log out and sign in again.');
      }
      throw Exception(e.message ?? 'Failed to create post.');
    }
  }

  @override
  Future<void> updatePost({
    required String postId,
    required String title,
    required String description,
    File? newImage,
    bool removeImage = false,
    String? oldDeleteHash,
    String? oldDescription,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('You must be logged in to edit a post.');
    }

    final postRef = _postsCollection.doc(postId);
    final postDoc = await postRef.get();
    if (!postDoc.exists || postDoc.data() == null) {
      throw Exception('This post no longer exists.');
    }

    final postData = postDoc.data() as Map<String, dynamic>;
    if (postData['userId'] != user.uid) {
      throw Exception('You do not have permission to edit this post.');
    }

    final currentTitle = (postData['title'] as String? ?? '').trim();
    final currentDesc = (postData['description'] as String? ?? '').trim();
    final currentImageUrl = postData['imageUrl'] as String?;
    final currentDeleteHash = postData['deleteHash'] as String?;

    final newTrimmedTitle = title.trim();
    final newTrimmedDesc = description.trim();

    final hasTitleChanged = newTrimmedTitle != currentTitle;
    final hasDescChanged = newTrimmedDesc != currentDesc;
    final isReplacingImage = newImage != null;
    final isRemovingImage = removeImage && currentImageUrl != null;

    if (!hasTitleChanged &&
        !hasDescChanged &&
        !isReplacingImage &&
        !isRemovingImage) {
      throw Exception('NO_CHANGES');
    }

    final Map<String, dynamic> updates = {};

    if (hasTitleChanged) {
      updates['title'] = newTrimmedTitle;
    }
    if (hasDescChanged) {
      updates['description'] = newTrimmedDesc;
    }

    if (isReplacingImage) {
      final bytes = await newImage.readAsBytes();
      final base64Image = base64Encode(bytes);
      final uploadResult =
          await ImageBBService.uploadImageDetailed(base64Image);
      if (uploadResult == null) {
        throw Exception('Failed to upload image. Please try again.');
      }

      // Delete previous image if delete hash exists
      final oldHash = oldDeleteHash ?? currentDeleteHash;
      if (oldHash != null && oldHash.isNotEmpty) {
        await ImageBBService.deleteImage(deleteHash: oldHash);
      } else {
        // TODO: Hook for future media cleanup if previous image had no delete hash.
      }

      updates['imageUrl'] = uploadResult.url;
      updates['deleteHash'] = uploadResult.deleteHash;
    } else if (isRemovingImage) {
      final oldHash = oldDeleteHash ?? currentDeleteHash;
      if (oldHash != null && oldHash.isNotEmpty) {
        await ImageBBService.deleteImage(deleteHash: oldHash);
      } else {
        // TODO: Hook for future media cleanup if previous image had no delete hash.
      }

      updates['imageUrl'] = FieldValue.delete();
      updates['deleteHash'] = FieldValue.delete();
    }

    // Always update lastEditedAt on successful edit; never touch createdAt
    updates['lastEditedAt'] = FieldValue.serverTimestamp();

    await postRef.update(updates);

    // Synchronize mentions: notify ONLY newly added mentions
    if (hasDescChanged) {
      try {
        final originalDesc = oldDescription ?? currentDesc;
        final oldMentions = MentionHelper.extractUsernames(originalDesc);
        final newMentions = MentionHelper.extractUsernames(newTrimmedDesc);
        final newOnlyMentions = newMentions.difference(oldMentions);

        if (newOnlyMentions.isNotEmpty) {
          await MentionHelper.sendMentionNotifications(
            text: newTrimmedDesc,
            postId: postId,
            onlyUsernames: newOnlyMentions,
          );
        }
      } catch (_) {}
    }
  }

  @override
  Future<void> deletePost({
    required String postId,
    String? deleteHash,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('You must be logged in to delete a post.');
    }

    final postRef = _postsCollection.doc(postId);
    final postDoc = await postRef.get();
    if (!postDoc.exists) {
      return; // Already deleted
    }

    final postData = postDoc.data() as Map<String, dynamic>? ?? {};
    if (postData['userId'] != user.uid) {
      throw Exception('You do not have permission to delete this post.');
    }

    final targetDeleteHash = deleteHash ?? postData['deleteHash'] as String?;

    // 1. Delete comments in batches (<= 450 per batch)
    try {
      while (true) {
        final commentsSnapshot =
            await postRef.collection('comments').limit(450).get();
        if (commentsSnapshot.docs.isEmpty) break;

        final batch = FirebaseFirestore.instance.batch();
        for (final doc in commentsSnapshot.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();

        if (commentsSnapshot.docs.length < 450) break;
      }
    } catch (_) {}

    // 2. Delete related notifications across all users in batches (<= 450 per batch)
    try {
      while (true) {
        final notifSnapshot = await FirebaseFirestore.instance
            .collectionGroup('notifications')
            .where('postId', isEqualTo: postId)
            .limit(450)
            .get();
        if (notifSnapshot.docs.isEmpty) break;

        final batch = FirebaseFirestore.instance.batch();
        for (final doc in notifSnapshot.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();

        if (notifSnapshot.docs.length < 450) break;
      }
    } catch (_) {}

    // 3. Delete remote image from ImgBB if delete hash exists
    if (targetDeleteHash != null && targetDeleteHash.isNotEmpty) {
      await ImageBBService.deleteImage(deleteHash: targetDeleteHash);
    } else {
      // TODO: Hook for future media cleanup if post image has no delete hash stored.
    }

    // 4. Finally, delete the post document
    await postRef.delete();
  }

  @override
  Stream<DocumentSnapshot> getPostStream(String postId) {
    return _postsCollection.doc(postId).snapshots();
  }

  @override
  Stream<QuerySnapshot> getCommentsStream(String postId) {
    return _postsCollection
        .doc(postId)
        .collection('comments')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  @override
  Future<String> addComment(String postId, Map<String, dynamic> data) async {
    _postsCollection.doc(postId).update({
      'commentCount': FieldValue.increment(1),
    });
    final commentRef =
        await _postsCollection.doc(postId).collection('comments').add(data);
    return commentRef.id;
  }

  @override
  Future<void> updateComment({
    required String postId,
    required String commentId,
    required String text,
    String? oldText,
  }) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      throw Exception('You must be logged in to edit a comment.');
    }

    final postRef = _postsCollection.doc(postId);
    final commentRef = postRef.collection('comments').doc(commentId);

    final commentDoc = await commentRef.get();
    if (!commentDoc.exists || commentDoc.data() == null) {
      throw Exception('This comment no longer exists.');
    }

    final commentData = commentDoc.data() as Map<String, dynamic>;
    if (commentData['userId'] != currentUser.uid) {
      throw Exception(
          'Permission denied: Only the comment author can edit this comment.');
    }

    final currentText = (commentData['text'] as String? ?? '').trim();
    final newTrimmedText = text.trim();

    if (newTrimmedText.isEmpty) {
      throw Exception('Comment cannot be empty.');
    }

    if (newTrimmedText == currentText) {
      throw Exception('NO_CHANGES');
    }

    // Update only text and lastEditedAt; never modify createdAt or other fields
    await commentRef.update({
      'text': newTrimmedText,
      'lastEditedAt': FieldValue.serverTimestamp(),
    });

    // Mention diffing: notify only newly added mentions & clean up removed mentions
    try {
      final originalText = oldText ?? currentText;
      final oldMentions = MentionHelper.extractUsernames(originalText);
      final newMentions = MentionHelper.extractUsernames(newTrimmedText);
      final addedMentions = newMentions.difference(oldMentions);
      final removedMentions = oldMentions.difference(newMentions);

      if (addedMentions.isNotEmpty) {
        await MentionHelper.sendMentionNotifications(
          text: newTrimmedText,
          postId: postId,
          commentId: commentId,
          onlyUsernames: addedMentions,
        );
      }

      if (removedMentions.isNotEmpty) {
        for (final username in removedMentions) {
          final targetUser = await MentionHelper.getUserByUsername(username);
          if (targetUser != null) {
            final targetUserId = targetUser['id'] as String? ?? '';
            if (targetUserId.isNotEmpty) {
              final notifSnap = await FirebaseFirestore.instance
                  .collectionGroup('notifications')
                  .where('commentId', isEqualTo: commentId)
                  .where('postId', isEqualTo: postId)
                  .where('senderId', isEqualTo: currentUser.uid)
                  .where('receiverId', isEqualTo: targetUserId)
                  .where('type', isEqualTo: 'mention')
                  .get();

              if (notifSnap.docs.isNotEmpty) {
                final batch = FirebaseFirestore.instance.batch();
                for (final doc in notifSnap.docs) {
                  batch.delete(doc.reference);
                }
                await batch.commit();
              }
            }
          }
        }
      }
    } catch (_) {}
  }

  @override
  Future<void> deleteComment({
    required String postId,
    required String commentId,
  }) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      throw Exception('You must be logged in to delete a comment.');
    }

    final postRef = _postsCollection.doc(postId);
    final commentRef = postRef.collection('comments').doc(commentId);

    // 1. Transaction to safely verify, delete comment, and decrement commentCount
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final commentDoc = await transaction.get(commentRef);
      if (!commentDoc.exists) {
        return; // Idempotent: already deleted
      }

      final postDoc = await transaction.get(postRef);
      if (!postDoc.exists) {
        throw Exception('This post no longer exists.');
      }

      final commentData = commentDoc.data() as Map<String, dynamic>;
      final postData = postDoc.data() as Map<String, dynamic>;

      final commentOwnerId = commentData['userId'] as String? ?? '';
      final postOwnerId = postData['userId'] as String? ?? '';

      final isCommentOwner = currentUser.uid == commentOwnerId;
      final isPostOwner = currentUser.uid == postOwnerId;

      if (!isCommentOwner && !isPostOwner) {
        throw Exception(
            'Permission denied: You cannot delete this comment.');
      }

      // Delete the comment document
      transaction.delete(commentRef);

      // Decrement commentCount clamped to >= 0
      final currentCount = (postData['commentCount'] as num?)?.toInt() ?? 0;
      final newCount = (currentCount - 1).clamp(0, 999999999);
      transaction.update(postRef, {'commentCount': newCount});
    });

    // 2. Remove all notifications related to this comment
    try {
      final notifSnapshot = await FirebaseFirestore.instance
          .collectionGroup('notifications')
          .where('commentId', isEqualTo: commentId)
          .get();

      if (notifSnapshot.docs.isNotEmpty) {
        final batch = FirebaseFirestore.instance.batch();
        for (final doc in notifSnapshot.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();
      }
    } catch (_) {}
  }

  @override
  Future<void> toggleLike(String postId, String userId) async {
    final postRef = _postsCollection.doc(postId);
    final doc = await postRef.get();
    final data = doc.data() as Map<String, dynamic>;
    final likes = List<String>.from(data['likes'] ?? []);

    if (likes.contains(userId)) {
      likes.remove(userId);
    } else {
      likes.add(userId);
    }

    await postRef.update({'likes': likes, 'likeCount': likes.length});
  }

  @override
  Future<DocumentSnapshot> getUser(String userId) {
    return FirebaseFirestore.instance.collection('users').doc(userId).get();
  }
}

