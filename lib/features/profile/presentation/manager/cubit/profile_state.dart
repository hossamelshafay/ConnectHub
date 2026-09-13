import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connecthub/features/home/data/models/post_model.dart';

abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final User user;
  final Map<String, dynamic>? userData;
  final List<PostModel> userPosts;
  final int totalLikes;
  final int followersCount;
  final int followingCount;

  ProfileLoaded({
    required this.user,
    this.userData,
    required this.userPosts,
    required this.totalLikes,
    this.followersCount = 0,
    this.followingCount = 0,
  });

  String get displayName {
    final name = (userData?['name'] as String?)?.trim();
    if (name != null && name.isNotEmpty) return name;
    final authName = user.displayName?.trim();
    if (authName != null && authName.isNotEmpty) return authName;
    return 'User';
  }

  String get username {
    final custom = (userData?['username'] as String?)?.trim();
    if (custom != null && custom.isNotEmpty) {
      return custom.startsWith('@') ? custom : '@$custom';
    }
    final emailPart = user.email?.split('@').first;
    return '@${emailPart ?? 'user'}';
  }

  String get bio => (userData?['bio'] as String?)?.trim() ?? '';

  String? get profileImage =>
      (userData?['profileImage'] as String?) ?? user.photoURL;

  DateTime get joinedDate {
    final ts = userData?['createdAt'] as Timestamp?;
    if (ts != null) return ts.toDate();
    return user.metadata.creationTime ?? DateTime.now();
  }
}

class ProfileError extends ProfileState {
  final String message;
  ProfileError(this.message);
}

class ProfileUpdating extends ProfileState {}

class ProfileUpdateSuccess extends ProfileState {}

class ProfileUpdateError extends ProfileState {
  final String message;
  ProfileUpdateError(this.message);
}
