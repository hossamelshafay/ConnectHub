import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connecthub/core/services/image_bb_service.dart';
import 'package:connecthub/features/home/data/models/post_model.dart';
import 'package:connecthub/features/profile/data/repos/profile_repo.dart';

class ProfileRepoImp implements ProfileRepo {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _postsCollection =
      FirebaseFirestore.instance.collection('posts');

  CollectionReference get _users => _firestore.collection('users');

  @override
  User? get currentUser => _auth.currentUser;

  @override
  Stream<List<PostModel>> getUserPostsStream(String userId) {
    return _postsCollection.where('userId', isEqualTo: userId).snapshots().map((
      snapshot,
    ) {
      final posts =
          snapshot.docs.map((doc) => PostModel.fromDoc(doc)).toList();
      posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return posts;
    });
  }

  @override
  Stream<QuerySnapshot> getUserPostsRawStream(String userId) {
    return _postsCollection.where('userId', isEqualTo: userId).snapshots();
  }

  @override
  Stream<DocumentSnapshot> getUserStream(String userId) {
    return _users.doc(userId).snapshots();
  }

  @override
  Future<DocumentSnapshot> getUserDoc(String userId) {
    return _users.doc(userId).get();
  }

  @override
  Future<String?> uploadProfileImage(File image) async {
    final bytes = await image.readAsBytes();
    final base64Image = base64Encode(bytes);
    return await ImageBBService.uploadImage(base64Image);
  }

  @override
  Future<void> updateProfile({
    required String name,
    required String username,
    required String bio,
    String? profileImageUrl,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('You must be logged in to update your profile.');
    }

    final sanitizedUsername = username.trim().replaceAll('@', '');

    final updates = <String, dynamic>{
      'name': name.trim(),
      'username': sanitizedUsername,
      'bio': bio.trim(),
    };

    if (profileImageUrl != null && profileImageUrl.isNotEmpty) {
      updates['profileImage'] = profileImageUrl;
      await user.updatePhotoURL(profileImageUrl);
    }

    await user.updateDisplayName(name.trim());
    await user.reload();

    await _users.doc(user.uid).set(updates, SetOptions(merge: true));
  }

  @override
  Stream<QuerySnapshot> getFollowersStream(String userId) {
    return _users.doc(userId).collection('followers').snapshots();
  }

  @override
  Stream<QuerySnapshot> getFollowingStream(String userId) {
    return _users.doc(userId).collection('following').snapshots();
  }

  @override
  Future<void> removeFollower({
    required String currentUserId,
    required String followerId,
  }) async {
    final followerRef =
        _users.doc(currentUserId).collection('followers').doc(followerId);
    final followingRef =
        _users.doc(followerId).collection('following').doc(currentUserId);

    await _firestore.runTransaction((transaction) async {
      final followerSnap = await transaction.get(followerRef);
      if (!followerSnap.exists) return;

      transaction.delete(followerRef);
      transaction.delete(followingRef);
      transaction.update(_users.doc(currentUserId), {
        'followersCount': FieldValue.increment(-1),
      });
      transaction.update(_users.doc(followerId), {
        'followingCount': FieldValue.increment(-1),
      });
    });
  }

  @override
  Future<void> unfollowUser({
    required String currentUserId,
    required String targetUserId,
  }) async {
    final followerRef =
        _users.doc(targetUserId).collection('followers').doc(currentUserId);
    final followingRef =
        _users.doc(currentUserId).collection('following').doc(targetUserId);

    await _firestore.runTransaction((transaction) async {
      final followerSnap = await transaction.get(followerRef);
      if (!followerSnap.exists) return;

      transaction.delete(followerRef);
      transaction.delete(followingRef);
      transaction.update(_users.doc(targetUserId), {
        'followersCount': FieldValue.increment(-1),
      });
      transaction.update(_users.doc(currentUserId), {
        'followingCount': FieldValue.increment(-1),
      });
    });
  }

  @override
  Stream<List<PostModel>> getLikedPostsStream(String userId) {
    return _postsCollection
        .where('likes', arrayContains: userId)
        .snapshots()
        .map((snapshot) {
      final posts =
          snapshot.docs.map((doc) => PostModel.fromDoc(doc)).toList();
      posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return posts;
    });
  }
}
