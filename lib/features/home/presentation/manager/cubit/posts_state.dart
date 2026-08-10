import 'package:connecthub/features/home/data/models/post_model.dart';

abstract class PostsState {}

class PostsInitial extends PostsState {}

class PostsLoading extends PostsState {}

class PostsLoaded extends PostsState {
  final List<PostModel> posts;
  PostsLoaded(this.posts);
}

class PostsError extends PostsState {
  final String message;
  PostsError(this.message);
}
