import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connecthub/features/post/data/repos/post_repo.dart';
import 'package:connecthub/features/post/data/repos/post_repo_imp.dart';
import 'package:connecthub/features/post/presentation/manager/cubit/post_action_state.dart';

class PostActionCubit extends Cubit<PostActionState> {
  final PostRepo postRepo;

  PostActionCubit({PostRepo? postRepo})
      : postRepo = postRepo ?? PostRepoImp(),
        super(const PostActionInitial());

  Future<void> updatePost({
    required String postId,
    required String title,
    required String description,
    File? newImage,
    bool removeImage = false,
    String? oldDeleteHash,
    String? oldDescription,
  }) async {
    // Prevent duplicate updates while an edit operation is running
    if (state is PostActionLoading) return;

    if (title.trim().isEmpty) {
      emit(const PostActionFailure('Title cannot be empty.'));
      return;
    }
    if (description.trim().isEmpty) {
      emit(const PostActionFailure('Description cannot be empty.'));
      return;
    }

    emit(const PostActionLoading());

    try {
      await postRepo.updatePost(
        postId: postId,
        title: title,
        description: description,
        newImage: newImage,
        removeImage: removeImage,
        oldDeleteHash: oldDeleteHash,
        oldDescription: oldDescription,
      );
      emit(const PostActionSuccess());
    } catch (e) {
      final message = e.toString().replaceFirst('Exception: ', '');
      if (message == 'NO_CHANGES') {
        emit(const PostActionNoChanges());
      } else if (message.contains('no longer exists')) {
        emit(const PostActionPostNotFound());
      } else {
        emit(PostActionFailure(message));
      }
    }
  }

  Future<void> deletePost({
    required String postId,
    String? deleteHash,
  }) async {
    if (state is PostActionLoading) return;

    emit(const PostActionLoading());

    try {
      await postRepo.deletePost(
        postId: postId,
        deleteHash: deleteHash,
      );
      emit(const PostActionPostDeleted());
    } catch (e) {
      final message = e.toString().replaceFirst('Exception: ', '');
      emit(PostActionFailure(message));
    }
  }
}
