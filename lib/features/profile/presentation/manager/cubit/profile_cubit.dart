import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  Map<String, dynamic>? _userData;
  List<PostModel> _userPosts = [];
  int _totalLikes = 0;
  int _followersCount = 0;
  int _followingCount = 0;

  ProfileRepo get repo => _profileRepo;

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

    // Stream 2: user document for live followers/following counts and profile data
    _userDocSubscription = _profileRepo.getUserStream(user.uid).listen(
      (doc) {
        if (doc.exists && doc.data() != null) {
          final data = doc.data() as Map<String, dynamic>;
          _userData = data;
          _followersCount = (data['followersCount'] as num?)?.toInt() ?? 0;
          _followingCount = (data['followingCount'] as num?)?.toInt() ?? 0;
        }
        if (state is ProfileLoaded || state is ProfileLoading) {
          _emitLoaded();
        }
      },
      onError: (_) {}, // Silently ignore — non-critical stream error
    );
  }

  void _emitLoaded() {
    if (_user == null) return;
    emit(
      ProfileLoaded(
        user: _user!,
        userData: _userData,
        userPosts: _userPosts,
        totalLikes: _totalLikes,
        followersCount: _followersCount,
        followingCount: _followingCount,
      ),
    );
  }

  /// Updates profile image, display name, username, and bio.
  Future<bool> updateProfile({
    required String name,
    required String username,
    required String bio,
    Uint8List? imageBytes,
    File? imageFile,
  }) async {
    final user = _user ?? _profileRepo.currentUser;
    if (user == null) return false;

    emit(ProfileUpdating());
    try {
      String? imageUrl = _userData?['profileImage'] as String? ?? user.photoURL;
      if (imageBytes != null) {
        final uploaded = await _profileRepo.uploadProfileBytes(imageBytes);
        if (uploaded != null) {
          imageUrl = uploaded;
        }
      } else if (imageFile != null) {
        final uploaded = await _profileRepo.uploadProfileImage(imageFile);
        if (uploaded != null) {
          imageUrl = uploaded;
        }
      }

      await _profileRepo.updateProfile(
        name: name,
        username: username,
        bio: bio,
        profileImageUrl: imageUrl,
      );

      _user = _profileRepo.currentUser;
      _userData = {
        ...?_userData,
        'name': name.trim(),
        'username': username.trim().replaceAll('@', ''),
        'bio': bio.trim(),
        'profileImage': ?imageUrl,
      };

      emit(ProfileUpdateSuccess());
      _emitLoaded();
      return true;
    } catch (e) {
      emit(ProfileUpdateError(e.toString().replaceAll('Exception: ', '')));
      _emitLoaded();
      return false;
    }
  }

  /// Removes a follower using the existing Firestore transaction.
  Future<void> removeFollower(String followerId) async {
    final user = _profileRepo.currentUser;
    if (user == null) return;
    await _profileRepo.removeFollower(
      currentUserId: user.uid,
      followerId: followerId,
    );
  }

  /// Unfollows a target user using the existing Firestore transaction.
  Future<void> unfollowUser(String targetUserId) async {
    final user = _profileRepo.currentUser;
    if (user == null) return;
    await _profileRepo.unfollowUser(
      currentUserId: user.uid,
      targetUserId: targetUserId,
    );
  }

  /// Stream of followers for a given user.
  Stream<QuerySnapshot> getFollowersStream(String userId) {
    return _profileRepo.getFollowersStream(userId);
  }

  /// Stream of following for a given user.
  Stream<QuerySnapshot> getFollowingStream(String userId) {
    return _profileRepo.getFollowingStream(userId);
  }

  /// Fetch user document snapshot.
  Future<DocumentSnapshot> getUserDoc(String userId) {
    return _profileRepo.getUserDoc(userId);
  }

  /// Stream of posts liked by [userId].
  Stream<List<PostModel>> getLikedPostsStream(String userId) {
    return _profileRepo.getLikedPostsStream(userId);
  }

  @override
  Future<void> close() {
    _postsSubscription?.cancel();
    _userDocSubscription?.cancel();
    return super.close();
  }
}
