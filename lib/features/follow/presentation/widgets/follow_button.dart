import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connecthub/core/utils/app_theme.dart';
import 'package:connecthub/features/follow/presentation/manager/cubit/follow_cubit.dart';
import 'package:connecthub/features/follow/presentation/manager/cubit/follow_state.dart';

/// Stateless follow/unfollow button that reads [FollowCubit] from context.
/// Must be placed within a widget tree that provides [FollowCubit].
class FollowButton extends StatelessWidget {
  const FollowButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FollowCubit, FollowState>(
      builder: (context, state) {
        if (state is FollowInitial) return const SizedBox.shrink();

        if (state is FollowLoading) {
          return const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: Colors.white,
            ),
          );
        }

        if (state is FollowLoaded) {
          return _FollowButtonContent(
            isFollowing: state.isFollowing,
            isActionLoading: state.isActionLoading,
            onTap: () => context.read<FollowCubit>().toggleFollow(),
          );
        }

        // FollowError: show a neutral retry affordance
        if (state is FollowError) {
          return _FollowButtonContent(
            isFollowing: false,
            isActionLoading: false,
            onTap: () => context.read<FollowCubit>().loadFollowStatus(),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

class _FollowButtonContent extends StatelessWidget {
  final bool isFollowing;
  final bool isActionLoading;
  final VoidCallback onTap;

  const _FollowButtonContent({
    required this.isFollowing,
    required this.isActionLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isActionLoading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 11),
        decoration: BoxDecoration(
          gradient: isFollowing
              ? null
              : const LinearGradient(
                  colors: [Colors.white24, Colors.white10],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          color: isFollowing ? Colors.white : null,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white, width: 1.5),
        ),
        child: isActionLoading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              )
            : Text(
                isFollowing ? 'Following' : 'Follow',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isFollowing ? AppColors.primary : Colors.white,
                  letterSpacing: 0.3,
                ),
              ),
      ),
    );
  }
}
