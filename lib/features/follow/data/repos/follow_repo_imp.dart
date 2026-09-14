import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connecthub/features/follow/data/repos/follow_repo.dart';
import 'package:connecthub/features/notification/data/models/notification_model.dart';
import 'package:connecthub/features/notification/data/repos/notification_repo_imp.dart';

class FollowRepoImp implements FollowRepo {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _users => _firestore.collection('users');

  /// Follows [targetUserId] from [currentUserId].
  ///
  /// Uses a Firestore Transaction so that the counter increment only happens
  /// when the follower document did not previously exist. This prevents
  /// counter inflation in multi-device or rapid-tap race conditions.
  @override
  Future<void> followUser(String currentUserId, String targetUserId) async {
    final followerRef = _users
        .doc(targetUserId)
        .collection('followers')
        .doc(currentUserId);
    final followingRef = _users
        .doc(currentUserId)
        .collection('following')
        .doc(targetUserId);

    await _firestore.runTransaction((transaction) async {
      final followerSnap = await transaction.get(followerRef);

      // Idempotency guard: already following → do nothing, counter unchanged.
      if (followerSnap.exists) return;

      transaction.set(followerRef, {
        'uid': currentUserId,
        'followedAt': FieldValue.serverTimestamp(),
      });
      transaction.set(followingRef, {
        'uid': targetUserId,
        'followedAt': FieldValue.serverTimestamp(),
      });
      transaction.update(_users.doc(targetUserId), {
        'followersCount': FieldValue.increment(1),
      });
      transaction.update(_users.doc(currentUserId), {
        'followingCount': FieldValue.increment(1),
      });
    });

    // Fire follow notification — self-follow guard.
    if (currentUserId != targetUserId) {
      try {
        final senderDoc =
            await _users.doc(currentUserId).get();
        final senderData =
            senderDoc.data() as Map<String, dynamic>? ?? {};
        await NotificationRepoImp().createNotification(
          NotificationModel(
            id: '',
            senderId: currentUserId,
            senderName: senderData['name'] as String? ?? 'Someone',
            senderUsername:
                senderData['username'] as String? ?? '',
            senderPhoto:
                senderData['profileImage'] as String?,
            receiverId: targetUserId,
            type: NotificationType.follow,
            createdAt: DateTime.now(),
            isRead: false,
          ),
        );
      } catch (_) {
        // Notification failure must not break the follow action.
      }
    }
  }

  /// Unfollows [targetUserId] from [currentUserId].
  ///
  /// Uses a Firestore Transaction so that the counter decrement only happens
  /// when the follower document actually exists. This prevents the counter
  /// from going negative if unfollow is called while not following (e.g.,
  /// simultaneous unfollow from two devices).
  @override
  Future<void> unfollowUser(String currentUserId, String targetUserId) async {
    final followerRef = _users
        .doc(targetUserId)
        .collection('followers')
        .doc(currentUserId);
    final followingRef = _users
        .doc(currentUserId)
        .collection('following')
        .doc(targetUserId);

    try {
      await _firestore.runTransaction((transaction) async {
        final followerSnap = await transaction.get(followerRef);

        // Idempotency guard: not following → do nothing, counter unchanged.
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
    } catch (_) {
      final snap = await followerRef.get();
      if (snap.exists) {
        await followerRef.delete();
        await followingRef.delete();
        await _users.doc(targetUserId).update({
          'followersCount': FieldValue.increment(-1),
        });
        await _users.doc(currentUserId).update({
          'followingCount': FieldValue.increment(-1),
        });
      }
    }
  }

  @override
  Stream<bool> isFollowingStream(String currentUserId, String targetUserId) {
    // O(1) existence check on a single document — no full collection scan.
    return _users
        .doc(targetUserId)
        .collection('followers')
        .doc(currentUserId)
        .snapshots()
        .map((doc) => doc.exists);
  }

  @override
  Stream<DocumentSnapshot> getUserStream(String userId) {
    return _users.doc(userId).snapshots();
  }
}
