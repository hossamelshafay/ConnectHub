import 'package:connecthub/features/profile/data/models/user_model.dart';

abstract class FollowState {}

class FollowInitial extends FollowState {}

class FollowLoading extends FollowState {}

class FollowLoaded extends FollowState {
  final bool isFollowing;
  final bool isActionLoading;
  final int followersCount;
  final int followingCount;
  final String? profileImage;
  final String? username;
  final String? bio;
  final String? headline;
  final String? location;
  final SocialLinksModel socialLinks;
  final bool websiteGenerated;
  final String? websiteUrl;

  FollowLoaded({
    required this.isFollowing,
    this.isActionLoading = false,
    required this.followersCount,
    required this.followingCount,
    this.profileImage,
    this.username,
    this.bio,
    this.headline,
    this.location,
    this.socialLinks = const SocialLinksModel(),
    this.websiteGenerated = false,
    this.websiteUrl,
  });
}

class FollowError extends FollowState {
  final String message;
  FollowError(this.message);
}
