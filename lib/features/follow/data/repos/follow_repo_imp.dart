import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connecthub/features/follow/data/repos/follow_repo.dart';

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
