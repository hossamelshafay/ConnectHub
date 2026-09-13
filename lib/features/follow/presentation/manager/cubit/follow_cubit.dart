import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connecthub/features/follow/data/repos/follow_repo.dart';
import 'package:connecthub/features/follow/data/repos/follow_repo_imp.dart';
import 'package:connecthub/features/follow/presentation/manager/cubit/follow_state.dart';

class FollowCubit extends Cubit<FollowState> {
  final FollowRepo _followRepo;
  final String targetUserId;

  StreamSubscription<bool>? _followStatusSubscription;
  StreamSubscription<DocumentSnapshot>? _userDocSubscription;

  // Private cache — rebuilt into FollowLoaded whenever either stream fires.
  bool _isFollowing = false;
  bool _isActionLoading = false;
  int _followersCount = 0;
  int _followingCount = 0;
  String? _profileImage;
  String? _username;
  String? _bio;

  // Ensures FollowLoaded is only emitted after the user document has loaded
  // so followers/following counts are accurate on first render.
  bool _userDocInitialized = false;

  FollowCubit({required this.targetUserId, FollowRepo? followRepo})
    : _followRepo = followRepo ?? FollowRepoImp(),
      super(FollowInitial());

  String? get _currentUserId => FirebaseAuth.instance.currentUser?.uid;

  /// Starts real-time listeners for follow status and user follow counts.
  /// No-ops silently when the current user is the target (can't follow yourself).
  void loadFollowStatus() {
    final currentUserId = _currentUserId;
    if (currentUserId == null) {
      emit(FollowError('Not logged in.'));
      return;
    }
    if (currentUserId == targetUserId) return;

    emit(FollowLoading());
    _followStatusSubscription?.cancel();
    _userDocSubscription?.cancel();
    _userDocInitialized = false;

    // Stream 1: real-time follow status
    _followStatusSubscription = _followRepo
        .isFollowingStream(currentUserId, targetUserId)
        .listen(
          (isFollowing) {
            _isFollowing = isFollowing;
            if (_userDocInitialized) _emitLoaded();
          },
          onError: (e, st) =>
              emit(FollowError(_formatError(e, st as StackTrace?))),
        );

    // Stream 2: target user's document for live follower/following counts
    _userDocSubscription = _followRepo.getUserStream(targetUserId).listen(
      (doc) {
        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          _followersCount = (data['followersCount'] as num?)?.toInt() ?? 0;
          _followingCount = (data['followingCount'] as num?)?.toInt() ?? 0;
          _profileImage = data['profileImage'] as String?;
          _username = data['username'] as String?;
          _bio = data['bio'] as String?;
        }
        _userDocInitialized = true;
        _emitLoaded();
      },
      onError: (e, st) => emit(FollowError(_formatError(e, st as StackTrace?))),
    );
  }

  /// Toggles follow/unfollow with optimistic locking via [isActionLoading].
  /// Emits [FollowError] on failure then immediately recovers to [FollowLoaded].
  ///
  /// All post-await emits are guarded with [isClosed] to prevent
  /// [StateError]s when the user navigates away while the operation is in
  /// flight (BlocProvider disposes the cubit, but the Future keeps running).
  Future<void> toggleFollow() async {
    final currentUserId = _currentUserId;
    if (currentUserId == null || currentUserId == targetUserId) return;
    if (state is! FollowLoaded || _isActionLoading) return;

    // Capture intent before the await so the error message is always correct
    // even if the Firestore stream updates _isFollowing mid-flight.
    final wasFollowing = _isFollowing;

    _isActionLoading = true;
    _emitLoaded();

    try {
      if (wasFollowing) {
        await _followRepo.unfollowUser(currentUserId, targetUserId);
      } else {
        await _followRepo.followUser(currentUserId, targetUserId);
      }
      // On success the Firestore stream updates _isFollowing automatically.
    } catch (e, st) {
      // Guard: cubit may have been closed while the Future was in flight.
      if (isClosed) return;
      emit(FollowError(_formatError(e, st)));
    }

    // Guard again: the await above can complete after the view is popped.
    if (isClosed) return;
    _isActionLoading = false;
    _emitLoaded();
  }

  /// Logs the full exception to the debug console AND returns a
  /// human-readable string for the snackbar.
  ///
  /// Look for lines starting with [FollowCubit] in the flutter run output
  /// to find the exact Firestore error code and message.
  String _formatError(Object e, [StackTrace? st]) {
    if (e is FirebaseException) {
      final output =
          '[FollowCubit] FirebaseException\n'
          '  code   : ${e.code}\n'
          '  message: ${e.message ?? "(no message)"}\n'
          '  plugin : ${e.plugin}';
      debugPrint(output);
      return '[${e.code}] ${e.message ?? "Firebase error."}]';
    }
    // Non-Firebase exception — print full stack trace so nothing is hidden.
    debugPrint('[FollowCubit] Unexpected error: $e');
    if (st != null) debugPrint(st.toString());
    return e.toString();
  }

  void _emitLoaded() {
    emit(
      FollowLoaded(
        isFollowing: _isFollowing,
        isActionLoading: _isActionLoading,
        followersCount: _followersCount,
        followingCount: _followingCount,
        profileImage: _profileImage,
        username: _username,
        bio: _bio,
      ),
    );
  }

  @override
  Future<void> close() {
    _followStatusSubscription?.cancel();
    _userDocSubscription?.cancel();
    return super.close();
  }
}
