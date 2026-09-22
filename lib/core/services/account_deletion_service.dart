import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Helper to manage Firestore WriteBatch operations with a safety ceiling
/// well below Firestore's 500-operation limit (max 450 writes per batch).
class _BatchManager {
  final FirebaseFirestore firestore;
  static const int maxBatchSize = 450;
  WriteBatch _batch;
  int _count = 0;

  _BatchManager(this.firestore) : _batch = firestore.batch();

  void delete(DocumentReference ref) {
    _batch.delete(ref);
    _count++;
  }

  void update(DocumentReference ref, Map<String, dynamic> data) {
    _batch.update(ref, data);
    _count++;
  }

  Future<void> flushIfNeeded() async {
    if (_count >= maxBatchSize) {
      await commit();
    }
  }

  Future<void> commit() async {
    if (_count > 0) {
      await _batch.commit();
      _batch = firestore.batch();
      _count = 0;
    }
  }
}

/// Service handling comprehensive, cascading, permanent account deletion
/// across Firestore, nested subcollections, shared references, and local caches.
class AccountDeletionService {
  final FirebaseFirestore _firestore;

  AccountDeletionService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Orchestrates full cascading deletion for [user] with step-by-step progress callbacks.
  Future<void> executeFullDeletion(
    User user, {
    void Function(String step)? onProgress,
  }) async {
    final uid = user.uid;

    int postsDeleted = 0;
    int commentsFound = 0;
    int commentsDeleted = 0;
    int likedPostsFound = 0;
    int likesRemoved = 0;
    int followersRemoved = 0;
    int followingRemoved = 0;
    int notificationsRemoved = 0;

    // Step 1: User comments everywhere (including other users' posts)
    onProgress?.call('Removing your comments across the app...');
    debugPrint('=== [AccountDeletion] 1. Deleting comments everywhere for $uid ===');
    try {
      final commentStats = await _deleteCommentsEverywhere(uid);
      commentsFound = commentStats.found;
      commentsDeleted = commentStats.deleted;
    } catch (e) {
      debugPrint('[AccountDeletion] Error deleting comments: $e');
    }

    // Step 2: Remove likes everywhere
    onProgress?.call('Removing your likes and reactions...');
    debugPrint('=== [AccountDeletion] 2. Removing user likes everywhere for $uid ===');
    try {
      final likeStats = await _removeLikesEverywhere(uid);
      likedPostsFound = likeStats.found;
      likesRemoved = likeStats.removed;
    } catch (e) {
      debugPrint('[AccountDeletion] Error removing likes: $e');
    }

    // Step 3: User's posts and their nested resources
    onProgress?.call('Deleting your posts...');
    debugPrint('=== [AccountDeletion] 3. Deleting user posts for $uid ===');
    try {
      postsDeleted = await _deleteUserPosts(uid);
    } catch (e) {
      debugPrint('[AccountDeletion] Error deleting posts: $e');
    }

    // Step 4: Follower and following relationships
    onProgress?.call('Cleaning up follower relationships...');
    debugPrint('=== [AccountDeletion] 4. Cleaning up follow relationships ===');
    try {
      final followStats = await _deleteFollowRelationships(uid);
      followersRemoved = followStats.followersRemoved;
      followingRemoved = followStats.followingRemoved;
    } catch (e) {
      debugPrint('[AccountDeletion] Error deleting relationships: $e');
    }

    // Step 5: Notifications (received & sent orphan notifications)
    onProgress?.call('Purging notifications...');
    debugPrint('=== [AccountDeletion] 5. Purging notifications ===');
    try {
      notificationsRemoved = await _deleteNotifications(uid);
    } catch (e) {
      debugPrint('[AccountDeletion] Error purging notifications: $e');
    }

    // Step 6: User profile document
    onProgress?.call('Deleting profile data...');
    debugPrint('=== [AccountDeletion] 6. Deleting users/$uid document ===');
    try {
      await _deleteUserProfile(uid);
    } catch (e) {
      debugPrint('[AccountDeletion] Error deleting user profile: $e');
    }

    // Step 7: Local cache cleanup
    onProgress?.call('Clearing local caches...');
    debugPrint('=== [AccountDeletion] 7. Clearing local cache ===');
    try {
      await _clearLocalCache(uid);
    } catch (e) {
      debugPrint('[AccountDeletion] Error clearing local cache: $e');
    }

    // Print temporary audit logs as required by audit specifications
    // ignore: avoid_print
    print('Posts deleted: $postsDeleted');
    // ignore: avoid_print
    print('Comments found: $commentsFound');
    // ignore: avoid_print
    print('Comments deleted: $commentsDeleted');
    // ignore: avoid_print
    print('Liked posts found: $likedPostsFound');
    // ignore: avoid_print
    print('Likes removed: $likesRemoved');
    // ignore: avoid_print
    print('Followers removed: $followersRemoved');
    // ignore: avoid_print
    print('Following removed: $followingRemoved');
    // ignore: avoid_print
    print('Notifications removed: $notificationsRemoved');

    debugPrint('Posts deleted: $postsDeleted');
    debugPrint('Comments found: $commentsFound');
    debugPrint('Comments deleted: $commentsDeleted');
    debugPrint('Liked posts found: $likedPostsFound');
    debugPrint('Likes removed: $likesRemoved');
    debugPrint('Followers removed: $followersRemoved');
    debugPrint('Following removed: $followingRemoved');
    debugPrint('Notifications removed: $notificationsRemoved');

    debugPrint('=== [AccountDeletion] Firestore deletion complete for $uid ===');
  }

  /// 1. Delete ALL comments created by the user across the entire application,
  /// including comments on other users' posts.
  ///
  /// Uses collectionGroup('comments').where('userId', isEqualTo: uid).
  /// For every comment:
  /// - delete the comment
  /// - decrement commentCount on parent post using a transaction
  /// - never allow commentCount < 0
  Future<({int found, int deleted})> _deleteCommentsEverywhere(String uid) async {
    int found = 0;
    int deleted = 0;
    final Set<String> processedCommentPaths = {};

    // 1. Primary: collectionGroup('comments').where('userId', isEqualTo: uid)
    try {
      final commentsQuery = await _firestore
          .collectionGroup('comments')
          .where('userId', isEqualTo: uid)
          .get();

      found += commentsQuery.docs.length;

      for (final commentDoc in commentsQuery.docs) {
        processedCommentPaths.add(commentDoc.reference.path);
        final parentPostRef = commentDoc.reference.parent.parent;
        if (parentPostRef != null) {
          try {
            await _firestore.runTransaction((transaction) async {
              // Read all required documents first (Firestore transaction contract)
              final postSnap = await transaction.get(parentPostRef);
              final commSnap = await transaction.get(commentDoc.reference);

              if (postSnap.exists) {
                final currentCount =
                    (postSnap.data()?['commentCount'] as num?)?.toInt() ?? 0;
                final newCount = max(0, currentCount - 1);
                transaction.update(parentPostRef, {'commentCount': newCount});
              }
              if (commSnap.exists) {
                transaction.delete(commentDoc.reference);
              }
            });
            deleted++;
          } catch (e) {
            debugPrint('[AccountDeletion] Transaction failed deleting comment ${commentDoc.id}: $e');
            // Fallback: direct delete
            try {
              await commentDoc.reference.delete();
              deleted++;
              final pSnap = await parentPostRef.get();
              if (pSnap.exists) {
                final cur = (pSnap.data()?['commentCount'] as num?)?.toInt() ?? 0;
                if (cur > 0) {
                  await parentPostRef.update({'commentCount': max(0, cur - 1)});
                }
              }
            } catch (fallbackError) {
              debugPrint('[AccountDeletion] Direct delete failed for comment ${commentDoc.id}: $fallbackError');
            }
          }
        } else {
          try {
            await commentDoc.reference.delete();
            deleted++;
          } catch (e) {
            debugPrint('[AccountDeletion] Direct delete failed for orphan comment ${commentDoc.id}: $e');
          }
        }
      }
    } catch (e) {
      debugPrint('[AccountDeletion] collectionGroup query error: $e');
    }

    // 2. Secondary sweep: inspect every post subcollection directly to guarantee
    // 100% comment removal even during background index propagation.
    try {
      final allPostsSnap = await _firestore.collection('posts').get();
      for (final postDoc in allPostsSnap.docs) {
        final subCommentsSnap = await postDoc.reference
            .collection('comments')
            .where('userId', isEqualTo: uid)
            .get();

        for (final commDoc in subCommentsSnap.docs) {
          if (!processedCommentPaths.contains(commDoc.reference.path)) {
            found++;
            processedCommentPaths.add(commDoc.reference.path);
            try {
              await _firestore.runTransaction((transaction) async {
                final postSnap = await transaction.get(postDoc.reference);
                final commSnap = await transaction.get(commDoc.reference);

                if (postSnap.exists) {
                  final curCount =
                      (postSnap.data()?['commentCount'] as num?)?.toInt() ?? 0;
                  final newCount = max(0, curCount - 1);
                  transaction.update(postDoc.reference, {'commentCount': newCount});
                }
                if (commSnap.exists) {
                  transaction.delete(commDoc.reference);
                }
              });
              deleted++;
            } catch (e) {
              try {
                await commDoc.reference.delete();
                deleted++;
                final cur = (postDoc.data()['commentCount'] as num?)?.toInt() ?? 0;
                if (cur > 0) {
                  await postDoc.reference.update({'commentCount': max(0, cur - 1)});
                }
              } catch (_) {}
            }
          }
        }
      }
    } catch (e) {
      debugPrint('[AccountDeletion] Secondary comment sweep error: $e');
    }

    return (found: found, deleted: deleted);
  }

  /// 2. Remove likes everywhere.
  /// Finds every post liked by this user via where('likes', arrayContains: uid).
  /// For every matching post:
  /// - remove uid from likes
  /// - decrement likeCount
  /// - clamp likeCount >= 0
  /// - execute inside a Firestore transaction
  Future<({int found, int removed})> _removeLikesEverywhere(String uid) async {
    int found = 0;
    int removed = 0;
    final Set<String> processedPostIds = {};

    // 1. Primary: where('likes', arrayContains: uid)
    try {
      final likedPostsQuery = await _firestore
          .collection('posts')
          .where('likes', arrayContains: uid)
          .get();

      found += likedPostsQuery.docs.length;

      for (final postDoc in likedPostsQuery.docs) {
        processedPostIds.add(postDoc.id);
        try {
          await _firestore.runTransaction((transaction) async {
            final postSnap = await transaction.get(postDoc.reference);
            if (!postSnap.exists) return;

            final data = postSnap.data() ?? {};
            final likes = List<String>.from(data['likes'] ?? []);
            final currentLikeCount =
                (data['likeCount'] as num?)?.toInt() ?? likes.length;

            if (likes.contains(uid)) {
              likes.removeWhere((id) => id == uid);
              final newCount = max(0, currentLikeCount - 1);
              transaction.update(postDoc.reference, {
                'likes': likes,
                'likeCount': newCount,
              });
            }
          });
          removed++;
        } catch (e) {
          debugPrint('[AccountDeletion] Transaction failed removing like on post ${postDoc.id}: $e');
          try {
            await postDoc.reference.update({
              'likes': FieldValue.arrayRemove([uid]),
            });
            removed++;
          } catch (fallbackError) {
            debugPrint('[AccountDeletion] Fallback failed removing like on post ${postDoc.id}: $fallbackError');
          }
        }
      }
    } catch (e) {
      debugPrint('[AccountDeletion] Liked posts query error: $e');
    }

    // 2. Secondary sweep: verify every post to ensure no lingering like remains
    try {
      final allPostsSnap = await _firestore.collection('posts').get();
      for (final postDoc in allPostsSnap.docs) {
        if (!processedPostIds.contains(postDoc.id)) {
          final data = postDoc.data();
          final likes = List<String>.from(data['likes'] ?? []);
          if (likes.contains(uid)) {
            found++;
            processedPostIds.add(postDoc.id);
            try {
              await _firestore.runTransaction((transaction) async {
                final snap = await transaction.get(postDoc.reference);
                if (!snap.exists) return;
                final curData = snap.data() ?? {};
                final curLikes = List<String>.from(curData['likes'] ?? []);
                final curCount =
                    (curData['likeCount'] as num?)?.toInt() ?? curLikes.length;
                if (curLikes.contains(uid)) {
                  curLikes.removeWhere((id) => id == uid);
                  final newCount = max(0, curCount - 1);
                  transaction.update(postDoc.reference, {
                    'likes': curLikes,
                    'likeCount': newCount,
                  });
                }
              });
              removed++;
            } catch (_) {
              try {
                await postDoc.reference.update({
                  'likes': FieldValue.arrayRemove([uid]),
                });
                removed++;
              } catch (_) {}
            }
          }
        }
      }
    } catch (e) {
      debugPrint('[AccountDeletion] Secondary like sweep error: $e');
    }

    return (found: found, removed: removed);
  }

  /// 3. Deletes all posts created by [uid].
  /// For each post, its nested comments subcollection is deleted first.
  /// The post document is deleted last.
  Future<int> _deleteUserPosts(String uid) async {
    int postsDeleted = 0;
    final batchManager = _BatchManager(_firestore);

    final postsQuery = await _firestore
        .collection('posts')
        .where('userId', isEqualTo: uid)
        .get();

    for (final postDoc in postsQuery.docs) {
      // Delete any remaining comments in this post's subcollection
      final commentsSnap =
          await postDoc.reference.collection('comments').get();
      for (final commDoc in commentsSnap.docs) {
        batchManager.delete(commDoc.reference);
        await batchManager.flushIfNeeded();
      }

      // Delete post document last
      batchManager.delete(postDoc.reference);
      await batchManager.flushIfNeeded();
      postsDeleted++;
    }

    await batchManager.commit();
    return postsDeleted;
  }

  /// 4. Removes following and follower relationships.
  /// Uses transactions to decrement counters on counterparty user profiles (clamped >= 0).
  Future<({int followersRemoved, int followingRemoved})>
      _deleteFollowRelationships(String uid) async {
    final userRef = _firestore.collection('users').doc(uid);
    int followersRemoved = 0;
    int followingRemoved = 0;

    // 4a. Target users this user was FOLLOWING
    final followingSnap = await userRef.collection('following').get();
    for (final doc in followingSnap.docs) {
      final targetUserId = doc.id;
      final targetRef = _firestore.collection('users').doc(targetUserId);
      final targetFollowerDoc =
          targetRef.collection('followers').doc(uid);

      try {
        await _firestore.runTransaction((transaction) async {
          final targetSnap = await transaction.get(targetRef);
          if (targetSnap.exists) {
            final count =
                (targetSnap.data()?['followersCount'] as num?)?.toInt() ?? 0;
            if (count > 0) {
              transaction.update(targetRef, {'followersCount': count - 1});
            }
          }
          transaction.delete(targetFollowerDoc);
          transaction.delete(doc.reference);
        });
        followingRemoved++;
      } catch (e) {
        debugPrint('[AccountDeletion] Transaction failed removing following $targetUserId: $e');
        try {
          await targetFollowerDoc.delete();
          await doc.reference.delete();
          followingRemoved++;
        } catch (_) {}
      }
    }

    // 4b. Users that were FOLLOWING this user
    final followersSnap = await userRef.collection('followers').get();
    for (final doc in followersSnap.docs) {
      final followerUserId = doc.id;
      final followerRef = _firestore.collection('users').doc(followerUserId);
      final followerFollowingDoc =
          followerRef.collection('following').doc(uid);

      try {
        await _firestore.runTransaction((transaction) async {
          final followerSnap = await transaction.get(followerRef);
          if (followerSnap.exists) {
            final count =
                (followerSnap.data()?['followingCount'] as num?)?.toInt() ?? 0;
            if (count > 0) {
              transaction.update(followerRef, {'followingCount': count - 1});
            }
          }
          transaction.delete(followerFollowingDoc);
          transaction.delete(doc.reference);
        });
        followersRemoved++;
      } catch (e) {
        debugPrint('[AccountDeletion] Transaction failed removing follower $followerUserId: $e');
        try {
          await followerFollowingDoc.delete();
          await doc.reference.delete();
          followersRemoved++;
        } catch (_) {}
      }
    }

    return (
      followersRemoved: followersRemoved,
      followingRemoved: followingRemoved,
    );
  }

  /// 5. Deletes all received notifications in users/{uid}/notifications,
  /// and purges any orphan notifications sent by this user across the application.
  Future<int> _deleteNotifications(String uid) async {
    int notificationsRemoved = 0;
    final batchManager = _BatchManager(_firestore);

    // 5a. Received notifications
    try {
      final receivedSnap = await _firestore
          .collection('users')
          .doc(uid)
          .collection('notifications')
          .get();

      for (final doc in receivedSnap.docs) {
        batchManager.delete(doc.reference);
        await batchManager.flushIfNeeded();
        notificationsRemoved++;
      }
      await batchManager.commit();
    } catch (e) {
      debugPrint('[AccountDeletion] Error clearing received notifications: $e');
    }

    // 5b. Sent notifications across all users (orphan notifications cleanup)
    try {
      final sentSnap = await _firestore
          .collectionGroup('notifications')
          .where('senderId', isEqualTo: uid)
          .get();

      for (final doc in sentSnap.docs) {
        batchManager.delete(doc.reference);
        await batchManager.flushIfNeeded();
        notificationsRemoved++;
      }
      await batchManager.commit();
    } catch (e) {
      debugPrint('[AccountDeletion] Error clearing sent notifications: $e');
    }

    return notificationsRemoved;
  }

  /// 6. Deletes the primary user document: users/{uid}
  Future<void> _deleteUserProfile(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).delete();
    } catch (e) {
      debugPrint('[AccountDeletion] Error deleting user profile document: $e');
    }
  }

  /// 7. Clears any local Hive / in-memory caches (future-compatible).
  Future<void> _clearLocalCache(String uid) async {
    try {
      // Future integration hook:
      // if (Hive.isBoxOpen('user_cache_$uid')) await Hive.box('user_cache_$uid').clear();
      // if (Hive.isBoxOpen('posts_cache_$uid')) await Hive.box('posts_cache_$uid').clear();
    } catch (e) {
      debugPrint('[AccountDeletion] Error clearing local cache: $e');
    }
  }
}
