import 'package:firebase_auth/firebase_auth.dart';
import 'package:connecthub/features/home/data/models/post_model.dart';

abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final User user;
  final List<PostModel> userPosts;
  final int totalLikes;
  final int followersCount;
  final int followingCount;

  ProfileLoaded({
    required this.user,
    required this.userPosts,
    required this.totalLikes,
    this.followersCount = 0,
    this.followingCount = 0,
  });
}

class ProfileError extends ProfileState {
  final String message;
  ProfileError(this.message);
}
