abstract class PostActionState {
  const PostActionState();
}

class PostActionInitial extends PostActionState {
  const PostActionInitial();
}

class PostActionLoading extends PostActionState {
  const PostActionLoading();
}

class PostActionSuccess extends PostActionState {
  final String message;
  const PostActionSuccess([this.message = 'Post updated successfully!']);
}

class PostActionNoChanges extends PostActionState {
  final String message;
  const PostActionNoChanges([this.message = 'No changes were made.']);
}

class PostActionPostDeleted extends PostActionState {
  final String message;
  const PostActionPostDeleted([this.message = 'Post deleted successfully!']);
}

class PostActionPostNotFound extends PostActionState {
  final String message;
  const PostActionPostNotFound([this.message = 'This post no longer exists.']);
}

class PostActionFailure extends PostActionState {
  final String message;
  const PostActionFailure(this.message);
}
