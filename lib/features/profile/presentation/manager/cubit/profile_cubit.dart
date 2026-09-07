import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connecthub/features/home/data/models/post_model.dart';
import 'package:connecthub/features/profile/data/repos/profile_repo.dart';
import 'package:connecthub/features/profile/data/repos/profile_repo_imp.dart';
import 'package:connecthub/features/profile/presentation/manager/cubit/profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepo _profileRepo;
  StreamSubscription? _postsSubscription;
  StreamSubscription? _userDocSubscription;

  // Private cache — both streams contribute to the same ProfileLoaded state.
  User? _user;
  List<PostModel> _userPosts = [];
  int _totalLikes = 0;
  int _followersCount = 0;
  int _followingCount = 0;

  ProfileCubit({ProfileRepo? profileRepo})
    : _profileRepo = profileRepo ?? ProfileRepoImp(),
      super(ProfileInitial());

  void loadProfile() {
    final user = _profileRepo.currentUser;
    if (user == null) {
      emit(ProfileError('Not logged in'));
      return;
    }

    _user = user;
    _userPosts = [];
    _totalLikes = 0;
    _followersCount = 0;
    _followingCount = 0;

    emit(ProfileLoading());
    _postsSubscription?.cancel();
    _userDocSubscription?.cancel();

    // Stream 1: user's posts for post count and total likes
    _postsSubscription = _profileRepo
        .getUserPostsStream(user.uid)
        .listen(
          (posts) {
            _userPosts = posts;
            _totalLikes = posts.fold(0, (acc, post) => acc + post.likeCount);
            _emitLoaded();
          },
          onError: (error) {
            final msg = error is FirebaseException
                ? (error.message ?? error.code)
                : error.toString();
            emit(ProfileError('Failed to load profile: $msg'));
          },
        );

    // Stream 2: user document for live followers/following counts
    _userDocSubscription = _profileRepo.getUserStream(user.uid).listen(
      (doc) {
        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          _followersCount = (data['followersCount'] as num?)?.toInt() ?? 0;
          _followingCount = (data['followingCount'] as num?)?.toInt() ?? 0;
        }
        // Only update if posts have already loaded to avoid a blank flash
        if (state is ProfileLoaded) _emitLoaded();
      },
      onError: (_) {}, // Silently ignore — follow counts are non-critical
    );
  }

  void _emitLoaded() {
    if (_user == null) return;
    emit(
      ProfileLoaded(
        user: _user!,
        userPosts: _userPosts,
        totalLikes: _totalLikes,
        followersCount: _followersCount,
        followingCount: _followingCount,
      ),
    );
  }

  @override
  Future<void> close() {
    _postsSubscription?.cancel();
    _userDocSubscription?.cancel();
    return super.close();
  }
}
