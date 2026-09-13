import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connecthub/features/home/data/models/post_model.dart';

abstract class ProfileRepo {
  User? get currentUser;
  Stream<List<PostModel>> getUserPostsStream(String userId);
  Stream<QuerySnapshot> getUserPostsRawStream(String userId);

  /// Real-time stream of the user's Firestore document (for follow counts and profile info).
  Stream<DocumentSnapshot> getUserStream(String userId);

  /// Fetch a single user document snapshot by ID.
  Future<DocumentSnapshot> getUserDoc(String userId);

  /// Updates the user's profile info in Firestore and Firebase Auth.
  Future<void> updateProfile({
    required String name,
    required String username,
    required String bio,
    String? profileImageUrl,
  });

  /// Uploads a new profile image and returns the public URL.
  Future<String?> uploadProfileImage(File image);

  /// Uploads image bytes directly (supports Flutter Web and all platforms).
  Future<String?> uploadProfileBytes(Uint8List bytes);

  /// Real-time stream of the user's followers subcollection.
  Stream<QuerySnapshot> getFollowersStream(String userId);

  /// Real-time stream of the user's following subcollection.
  Stream<QuerySnapshot> getFollowingStream(String userId);

  /// Removes [followerId] from [currentUserId]'s followers list using a Firestore transaction.
  Future<void> removeFollower({
    required String currentUserId,
    required String followerId,
  });

  /// Unfollows [targetUserId] from [currentUserId] using a Firestore transaction.
  Future<void> unfollowUser({
    required String currentUserId,
    required String targetUserId,
  });

  /// Stream of all posts that [userId] has liked.
  Stream<List<PostModel>> getLikedPostsStream(String userId);
}
