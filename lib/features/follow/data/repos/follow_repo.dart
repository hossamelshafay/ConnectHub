import 'package:cloud_firestore/cloud_firestore.dart';

abstract class FollowRepo {
  /// Adds currentUser → targetUser follow relationship and increments counters.
  Future<void> followUser(String currentUserId, String targetUserId);

  /// Removes currentUser → targetUser follow relationship and decrements counters.
  Future<void> unfollowUser(String currentUserId, String targetUserId);

  /// Real-time stream: true when currentUser is following targetUser.
  Stream<bool> isFollowingStream(String currentUserId, String targetUserId);

  /// Real-time stream of the target user's Firestore document.
  Stream<DocumentSnapshot> getUserStream(String userId);
}
