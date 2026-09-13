import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connecthub/core/utils/app_theme.dart';
import 'package:connecthub/core/utils/app_widgets.dart';
import 'package:connecthub/features/profile/presentation/manager/cubit/profile_cubit.dart';
import 'package:connecthub/features/profile/presentation/views/user_profile_view.dart';

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
      appBar: AppBar(
        title: Text(titleText),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: cubit.getFollowingStream(targetUserId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
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
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person_add_alt_1_rounded,
                      size: 40,
                      color: AppColors.textHint,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Not following anyone yet',
                      style: AppTextStyles.headline3),
                  const SizedBox(height: 6),
                  Text(
                    'Explore posts and follow creators to see them here.',
                    style:
                        AppTextStyles.body2.copyWith(color: AppColors.textHint),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: docs.length,
            separatorBuilder: (_, _) =>
                const Divider(height: 16, color: AppColors.divider),
            itemBuilder: (context, index) {
              final targetId = docs[index].id;
              return _FollowingItem(
                targetUserId: targetId,
                isOwnProfile: isOwnProfile,
                onUnfollow: () => _confirmUnfollow(context, targetUserId: targetId),
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
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Unfollow User'),
        content: const Text(
          'Are you sure you want to unfollow this user? Their posts will no longer appear in your feed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
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
            child: const Text(
              'Unfollow',
              style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FollowingItem extends StatelessWidget {
  final String targetUserId;
  final bool isOwnProfile;
  final VoidCallback onUnfollow;

  const _FollowingItem({
    required this.targetUserId,
    required this.isOwnProfile,
    required this.onUnfollow,
  });

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ProfileCubit>();

    return FutureBuilder<DocumentSnapshot>(
      future: cubit.getUserDoc(targetUserId),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const SizedBox(
            height: 60,
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }

        final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};
        final name = (data['name'] as String?)?.trim().isNotEmpty == true
            ? data['name'] as String
            : 'User';
        final usernameStr = (data['username'] as String?)?.trim().isNotEmpty == true
            ? '@${data['username']}'
            : '@${(data['email'] as String? ?? 'user').split('@').first}';
        final bio = (data['bio'] as String?)?.trim() ?? '';
        final profileImage = data['profileImage'] as String?;

        return InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => UserProfileView(
                  userId: targetUserId,
                  userName: name,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                UserAvatar(
                  name: name,
                  imageUrl: profileImage,
                  size: 50,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: AppTextStyles.body1.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        usernameStr,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (bio.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          bio,
                          style: AppTextStyles.caption,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                if (isOwnProfile) ...[
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: onUnfollow,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      side: BorderSide(
                        color: AppColors.textHint.withValues(alpha: 0.4),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Unfollow',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
