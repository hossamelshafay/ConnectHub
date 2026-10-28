import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connecthub/core/utils/app_theme.dart';
import 'package:connecthub/core/utils/app_widgets.dart';
import 'package:connecthub/features/profile/presentation/manager/cubit/profile_cubit.dart';
import 'package:connecthub/features/profile/presentation/widgets/user_follow_tile.dart';
import 'package:connecthub/features/profile/presentation/widgets/follow_empty_view.dart';

class FollowersView extends StatelessWidget {
  final String? userId;
  final String? userName;

  const FollowersView({super.key, this.userId, this.userName});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ProfileCubit>();
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final targetUserId = userId ?? currentUserId;
    final isOwnProfile = targetUserId == currentUserId;

    final titleText = isOwnProfile
        ? 'Followers'
        : (userName != null ? '$userName\'s Followers' : 'Followers');

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
        stream: cubit.getFollowersStream(targetUserId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const NotificationTileShimmer(itemCount: 8);
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Failed to load followers: ${snapshot.error}',
                style: AppTextStyles.body2.copyWith(color: AppColors.error),
              ),
            );
          }

          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const FollowEmptyView(
              icon: Icons.people_outline_rounded,
              title: 'No followers yet',
              subtitle: 'When people follow, they will appear here.',
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: docs.length,
            separatorBuilder: (_, _) =>
                Divider(height: 16, color: AppColors.divider),
            itemBuilder: (context, index) {
              final followerId = docs[index].id;
              return UserFollowTile(
                userId: followerId,
                isOwnProfile: isOwnProfile,
                actionLabel: 'Remove',
                onAction: () => _confirmRemoveFollower(
                  context,
                  followerId: followerId,
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _confirmRemoveFollower(
    BuildContext context, {
    required String followerId,
  }) {
    AppConfirmDialog.show(
      context,
      title: 'Remove Follower',
      content: 'ConnectHub won\'t notify this user that they were removed from your followers.',
      confirmLabel: 'Remove',
      isDestructive: true,
      onConfirm: () async {
        try {
          await context.read<ProfileCubit>().removeFollower(followerId);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Follower removed.'),
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
                content: Text('Failed to remove: $e'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        }
      },
    );
  }
}
