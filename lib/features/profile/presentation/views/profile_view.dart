import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connecthub/core/utils/app_theme.dart';
import 'package:connecthub/features/auth/presentation/manager/cubit/auth_cubit.dart';
import 'package:connecthub/features/auth/presentation/views/login_view.dart';
import 'package:connecthub/features/profile/presentation/manager/cubit/profile_cubit.dart';
import 'package:connecthub/features/profile/presentation/manager/cubit/profile_state.dart';
import 'package:connecthub/features/profile/presentation/widgets/profile_card.dart';
import 'package:connecthub/features/profile/presentation/widgets/user_post_tile.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProfileCubit()..loadProfile(),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Text('Profile', style: AppTextStyles.headline2),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          title: const Text('Sign Out'),
                          content: const Text(
                              'Are you sure you want to sign out?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(ctx);
                                context.read<AuthCubit>().signOut();
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                      builder: (_) => const LoginView()),
                                  (route) => false,
                                );
                              },
                              child: const Text('Sign Out',
                                  style: TextStyle(color: AppColors.error)),
                            ),
                          ],
                        ),
                      );
                    },
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.logout_rounded,
                          color: AppColors.textSecondary, size: 22),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: BlocBuilder<ProfileCubit, ProfileState>(
                builder: (context, state) {
                  if (state is ProfileLoading) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    );
                  }
                  if (state is ProfileError) {
                    return Center(
                      child: Text(state.message, style: AppTextStyles.body2),
                    );
                  }
                  if (state is ProfileLoaded) {
                    return Column(
                      children: [
                        ProfileCard(
                          user: state.user,
                          postCount: state.userPosts.length,
                          totalLikes: state.totalLikes,
                        ),
                        const SizedBox(height: 24),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Row(
                            children: [
                              Text('Your Posts', style: AppTextStyles.headline3),
                              const Spacer(),
                              const Icon(Icons.grid_view_rounded,
                                  color: AppColors.textHint, size: 22),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: state.userPosts.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.article_outlined,
                                          size: 48,
                                          color: AppColors.textHint
                                              .withValues(alpha: 0.5)),
                                      const SizedBox(height: 12),
                                      Text('No posts yet',
                                          style: AppTextStyles.body2
                                              .copyWith(color: AppColors.textHint)),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 4),
                                  itemCount: state.userPosts.length,
                                  itemBuilder: (context, index) {
                                    final post = state.userPosts[index];
                                    return UserPostTile(
                                      postId: post.id,
                                      title: post.title,
                                      description: post.description,
                                      imageUrl: post.imageUrl,
                                      likeCount: post.likeCount,
                                      commentCount: post.commentCount,
                                      createdAt: post.createdAt,
                                    );
                                  },
                                ),
                        ),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
