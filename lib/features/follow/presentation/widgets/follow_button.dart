import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connecthub/core/utils/app_theme.dart';
import 'package:connecthub/features/follow/presentation/manager/cubit/follow_cubit.dart';
import 'package:connecthub/features/follow/presentation/manager/cubit/follow_state.dart';

class FollowButton extends StatelessWidget {
  const FollowButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FollowCubit, FollowState>(
      builder: (context, state) {
        if (state is FollowInitial) return const SizedBox.shrink();

        if (state is FollowLoading) {
          return SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          );
        }

        if (state is FollowLoaded) {
          return _FollowButtonContent(
            isFollowing: state.isFollowing,
            isActionLoading: state.isActionLoading,
            onTap: () {
              HapticFeedback.lightImpact();
              context.read<FollowCubit>().toggleFollow();
            },
          );
        }

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
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
        decoration: BoxDecoration(
          color: isFollowing ? AppColors.glass : AppColors.primary,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
            color: isFollowing
                ? AppColors.glassBorder
                : AppColors.primary,
            width: 1,
          ),
          boxShadow: [
            if (!isFollowing)
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.08),
                blurRadius: 4,
                offset: const Offset(0, 1.5),
              ),
          ],
        ),
        child: isActionLoading
            ? SizedBox(
                width: 15,
                height: 15,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isFollowing ? AppColors.textPrimary : Colors.white,
                  ),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isFollowing) ...[
                    Icon(
                      Icons.check_rounded,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 5),
                  ],
                  Text(
                    isFollowing ? 'Following' : 'Follow',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isFollowing
                          ? AppColors.textPrimary
                          : Colors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
