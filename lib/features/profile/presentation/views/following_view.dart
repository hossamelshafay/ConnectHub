import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connecthub/core/utils/app_theme.dart';
import 'package:connecthub/core/utils/app_widgets.dart';
import 'package:connecthub/features/profile/presentation/manager/cubit/profile_cubit.dart';
import 'package:connecthub/features/profile/presentation/widgets/user_follow_tile.dart';
import 'package:connecthub/features/profile/presentation/widgets/follow_empty_view.dart';

class FollowingView extends StatelessWidget {
  final String? userId;
  final String? userName;

  const FollowingView({super.key, this.userId, this.userName});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ProfileCubit>();
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final targetUserId = userId ?? currentUserId;
    final isOwnProfile = targetUserId == currentUserId;

    final titleText = isOwnProfile
        ? 'Following'
        : (userName != null ? '$userName\'s Following' : 'Following');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(titleText, style: AppTextStyles.headline3),
        centerTitle: true,
        leading: Center(
          child: AppIconButton(
            icon: Icons.arrow_back_ios_new,
            size: 18,
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: cubit.getFollowingStream(targetUserId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const NotificationTileShimmer(itemCount: 8);
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Failed to load following: ${snapshot.error}',
                style: AppTextStyles.body2.copyWith(color: AppColors.error),
              ),
            );
          }

          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const FollowEmptyView(
              icon: Icons.person_add_alt_1_rounded,
              title: 'Not following anyone yet',
              subtitle: 'Explore posts and follow creators to see them here.',
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: docs.length,
            separatorBuilder: (_, _) =>
                Divider(height: 16, color: AppColors.divider),
            itemBuilder: (context, index) {
              final targetId = docs[index].id;
              return UserFollowTile(
                userId: targetId,
                isOwnProfile: isOwnProfile,
                actionLabel: 'Unfollow',
                onAction: () => _confirmUnfollow(context, targetUserId: targetId),
              );
            },
          );
        },
      ),
    );
  }

  void _confirmUnfollow(
    BuildContext context, {
    required String targetUserId,
  }) {
    AppConfirmDialog.show(
      context,
      title: 'Unfollow User',
      content: 'Are you sure you want to unfollow this user? Their posts will no longer appear in your feed.',
      confirmLabel: 'Unfollow',
      isDestructive: true,
      onConfirm: () async {
        try {
          await context.read<ProfileCubit>().unfollowUser(targetUserId);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Unfollowed successfully.'),
                backgroundColor: AppColors.textPrimary,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to unfollow: $e'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        }
      },
    );
  }
}
