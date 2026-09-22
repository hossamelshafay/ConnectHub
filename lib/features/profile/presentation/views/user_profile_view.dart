import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connecthub/core/utils/app_theme.dart';
import 'package:connecthub/features/follow/presentation/manager/cubit/follow_cubit.dart';
import 'package:connecthub/features/follow/presentation/manager/cubit/follow_state.dart';
import 'package:connecthub/features/follow/presentation/widgets/follow_button.dart';
import 'package:connecthub/features/home/presentation/manager/cubit/posts_cubit.dart';
import 'package:connecthub/features/home/presentation/manager/cubit/posts_state.dart';
import 'package:connecthub/features/profile/presentation/manager/cubit/profile_cubit.dart';
import 'package:connecthub/features/profile/presentation/views/followers_view.dart';
import 'package:connecthub/features/profile/presentation/views/following_view.dart';
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
                _UserProfileHeader(userName: userName, userId: userId),
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
/// Mirrors [ProfileCard]'s visual style, displays Posts count, Followers, and Following.
class _UserProfileHeader extends StatelessWidget {
  final String userName;
  final String userId;

  const _UserProfileHeader({
    required this.userName,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FollowCubit, FollowState>(
      builder: (context, followState) {
        final followersCount =
            followState is FollowLoaded ? followState.followersCount : 0;
        final followingCount =
            followState is FollowLoaded ? followState.followingCount : 0;
        final profileImage =
            followState is FollowLoaded ? followState.profileImage : null;
        final customUsername =
            followState is FollowLoaded ? followState.username : null;
        final bio = followState is FollowLoaded ? followState.bio : null;

        final usernameStr = customUsername?.trim().isNotEmpty == true
            ? (customUsername!.startsWith('@')
                ? customUsername
                : '@$customUsername')
            : null;

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
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.2),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.6),
                    width: 2.5,
                  ),
                ),
                child: ClipOval(
                  child: (profileImage != null && profileImage.isNotEmpty)
                      ? CachedNetworkImage(
                          imageUrl: profileImage,
                          width: 76,
                          height: 76,
                          fit: BoxFit.cover,
                          placeholder: (_, _) => Container(
                            color: Colors.white.withValues(alpha: 0.2),
                            child: const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                          ),
                          errorWidget: (_, _, _) => _buildFallback(),
                        )
                      : _buildFallback(),
                ),
              ),
              const SizedBox(height: 12),

              // Name
              Text(
                userName,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),

              // Username (@username)
              if (usernameStr != null) ...[
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    usernameStr,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ),
              ],

              // Bio
              if (bio != null && bio.trim().isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  bio.trim(),
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              const SizedBox(height: 16),

              // Stats row: Posts · Followers · Following
              BlocBuilder<PostsCubit, PostsState>(
                builder: (context, postsState) {
                  final postCount =
                      postsState is PostsLoaded ? postsState.posts.length : 0;

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      StatItem(
                        count: postCount.toString(),
                        label: 'Posts',
                      ),
                      Container(
                        width: 1,
                        height: 30,
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BlocProvider(
                                create: (_) => ProfileCubit(),
                                child: FollowersView(
                                  userId: userId,
                                  userName: userName,
                                ),
                              ),
                            ),
                          );
                        },
                        child: StatItem(
                          count: followersCount.toString(),
                          label: 'Followers',
                          isClickable: true,
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 30,
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BlocProvider(
                                create: (_) => ProfileCubit(),
                                child: FollowingView(
                                  userId: userId,
                                  userName: userName,
                                ),
                              ),
                            ),
                          );
                        },
                        child: StatItem(
                          count: followingCount.toString(),
                          label: 'Following',
                          isClickable: true,
                        ),
                      ),
                    ],
                  );
                },
              ),

              // Follow / Unfollow button (never shown for own profile)
              if (FirebaseAuth.instance.currentUser?.uid != userId) ...[
                const SizedBox(height: 16),
                const FollowButton(),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildFallback() {
    return Center(
      child: Text(
        userName.isNotEmpty ? userName[0].toUpperCase() : '?',
        style: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}

