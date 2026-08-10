import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connecthub/features/home/data/repos/posts_repo.dart';
import 'package:connecthub/features/home/data/repos/posts_repo_imp.dart';
import 'package:connecthub/features/home/presentation/manager/cubit/posts_state.dart';

class PostsCubit extends Cubit<PostsState> {
  final PostsRepo _postsRepo;
  StreamSubscription? _subscription;

  PostsCubit({PostsRepo? postsRepo})
      : _postsRepo = postsRepo ?? PostsRepoImp(),
        super(PostsInitial());

  void loadPosts() {
    emit(PostsLoading());
    _subscription?.cancel();
    _subscription = _postsRepo.getPostsStream().listen(
      (posts) {
        emit(PostsLoaded(posts));
      },
      onError: (error) {
        emit(PostsError('Failed to load posts.'));
      },
    );
  }

  void loadUserPosts(String userId) {
    emit(PostsLoading());
    _subscription?.cancel();
    _subscription = _postsRepo.getUserPostsStream(userId).listen(
      (posts) {
        emit(PostsLoaded(posts));
      },
      onError: (error) {
        emit(PostsError('Failed to load posts.'));
      },
    );
  }

  Future<void> toggleLike(String postId, String userId) async {
    await _postsRepo.toggleLike(postId, userId);
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
