import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connecthub/core/utils/app_theme.dart';
import 'package:connecthub/features/follow/presentation/manager/cubit/follow_cubit.dart';
import 'package:connecthub/features/follow/presentation/manager/cubit/follow_state.dart';
import 'package:connecthub/features/follow/presentation/widgets/follow_button.dart';
import 'package:connecthub/features/home/presentation/manager/cubit/posts_cubit.dart';
import 'package:connecthub/features/home/presentation/manager/cubit/posts_state.dart';
import 'package:connecthub/features/profile/presentation/widgets/profile_card.dart';
import 'package:connecthub/features/profile/presentation/widgets/user_post_tile.dart';

/// Displays another user's public profile with follow/unfollow functionality.
/// Provides its own [FollowCubit] and a scoped [PostsCubit] so neither
/// interferes with the global feed [PostsCubit] in [HomeView].
class UserProfileView extends StatelessWidget {
  final String userId;
  final String userName;

  const UserProfileView({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => FollowCubit(targetUserId: userId)..loadFollowStatus(),
        ),
        BlocProvider(create: (_) => PostsCubit()..loadUserPosts(userId)),
      ],
      child: BlocListener<FollowCubit, FollowState>(
        listener: (context, state) {
          if (state is FollowError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text(userName),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                _UserProfileHeader(userName: userName),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Text('Posts', style: AppTextStyles.headline3),
                      const Spacer(),
                      const Icon(
                        Icons.grid_view_rounded,
                        color: AppColors.textHint,
                        size: 22,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: BlocBuilder<PostsCubit, PostsState>(
                    builder: (context, state) {
                      if (state is PostsLoading) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        );
                      }
                      if (state is PostsError) {
                        return Center(
                          child: Text(
                            state.message,
                            style: AppTextStyles.body2,
                          ),
                        );
                      }
                      if (state is PostsLoaded) {
                        if (state.posts.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.article_outlined,
                                  size: 48,
                                  color: AppColors.textHint.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'No posts yet',
                                  style: AppTextStyles.body2.copyWith(
                                    color: AppColors.textHint,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          itemCount: state.posts.length,
                          itemBuilder: (context, index) {
                            final post = state.posts[index];
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
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Gradient header card for a public user profile.
/// Mirrors [ProfileCard]'s visual style without requiring a Firebase [User] object.
class _UserProfileHeader extends StatelessWidget {
  final String userName;

  const _UserProfileHeader({required this.userName});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.accent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.2),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.5),
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            userName,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          // Followers / Following counts (live via FollowCubit)
          BlocBuilder<FollowCubit, FollowState>(
            builder: (context, state) {
              final followersCount = state is FollowLoaded
                  ? state.followersCount
                  : 0;
              final followingCount = state is FollowLoaded
                  ? state.followingCount
                  : 0;

              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  StatItem(
                    count: followersCount.toString(),
                    label: 'Followers',
                  ),
                  Container(
                    width: 1,
                    height: 30,
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                  StatItem(
                    count: followingCount.toString(),
                    label: 'Following',
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          // Follow / Unfollow button (hidden for own profile via FollowInitial)
          const FollowButton(),
        ],
      ),
    );
  }
}
