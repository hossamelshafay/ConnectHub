import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connecthub/features/profile/data/repos/profile_repo.dart';
import 'package:connecthub/features/profile/data/repos/profile_repo_imp.dart';
import 'package:connecthub/features/profile/presentation/manager/cubit/profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepo _profileRepo;
  StreamSubscription? _postsSubscription;

  ProfileCubit({ProfileRepo? profileRepo})
      : _profileRepo = profileRepo ?? ProfileRepoImp(),
        super(ProfileInitial());

  void loadProfile() {
    final user = _profileRepo.currentUser;
    if (user == null) {
      emit(ProfileError('Not logged in'));
      return;
    }

    emit(ProfileLoading());
    _postsSubscription?.cancel();
    _postsSubscription = _profileRepo.getUserPostsStream(user.uid).listen(
      (posts) {
        int totalLikes = 0;
        for (final post in posts) {
          totalLikes += post.likeCount;
        }
        emit(ProfileLoaded(
          user: user,
          userPosts: posts,
          totalLikes: totalLikes,
        ));
      },
      onError: (error) {
        final msg = error is FirebaseException
            ? (error.message ?? error.code)
            : error.toString();
        emit(ProfileError('Failed to load profile: $msg'));
      },
    );
  }

  @override
  Future<void> close() {
    _postsSubscription?.cancel();
    return super.close();
  }
}
