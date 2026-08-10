import 'dart:io';

abstract class CreatePostState {}

class CreatePostInitial extends CreatePostState {}

class CreatePostImagePicked extends CreatePostState {
  final File image;
  CreatePostImagePicked(this.image);
}

class CreatePostSubmitting extends CreatePostState {}

class CreatePostSuccess extends CreatePostState {}

class CreatePostError extends CreatePostState {
  final String message;
  CreatePostError(this.message);
}
