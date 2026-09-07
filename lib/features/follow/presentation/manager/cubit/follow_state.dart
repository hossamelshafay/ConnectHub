abstract class FollowState {}

class FollowInitial extends FollowState {}

class FollowLoading extends FollowState {}

class FollowLoaded extends FollowState {
  final bool isFollowing;
  final bool isActionLoading;
  final int followersCount;
  final int followingCount;

  FollowLoaded({
    required this.isFollowing,
    this.isActionLoading = false,
    required this.followersCount,
    required this.followingCount,
  });
}

class FollowError extends FollowState {
  final String message;
  FollowError(this.message);
}
