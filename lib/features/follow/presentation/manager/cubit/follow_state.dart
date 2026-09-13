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

  FollowLoaded({
    required this.isFollowing,
    this.isActionLoading = false,
    required this.followersCount,
    required this.followingCount,
    this.profileImage,
    this.username,
    this.bio,
  });
}

class FollowError extends FollowState {
  final String message;
  FollowError(this.message);
}
