import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connecthub/core/utils/app_theme.dart';
import 'package:connecthub/core/utils/app_widgets.dart';
import 'package:connecthub/features/follow/presentation/manager/cubit/follow_cubit.dart';
import 'package:connecthub/features/follow/presentation/manager/cubit/follow_state.dart';
import 'package:connecthub/features/home/presentation/manager/cubit/posts_cubit.dart';
import 'package:connecthub/features/home/presentation/manager/cubit/posts_state.dart';
import 'package:connecthub/features/profile/presentation/widgets/user_post_tile.dart';
import 'package:connecthub/features/profile/presentation/widgets/user_profile_header.dart';

class UserProfileView extends StatelessWidget {
  final String userId;
  final String userName;
  final VoidCallback? onSwitchToPortfolio;

  const UserProfileView({
    super.key,
    required this.userId,
    required this.userName,
    this.onSwitchToPortfolio,
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
                backgroundColor: AppColors.surfaceVariant,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: AppColors.error, width: 1),
                ),
              ),
            );
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: Center(
              child: AppIconButton(
                icon: Icons.arrow_back_ios_new,
                size: 18,
                onPressed: () => Navigator.pop(context),
              ),
            ),
            title: Text(userName, style: AppTextStyles.headline3),
            centerTitle: true,
          ),
          body: SafeArea(
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsets.only(bottom: 32),
              children: [
                UserProfileHeader(
                  userName: userName,
                  userId: userId,
                  onSwitchToPortfolio: onSwitchToPortfolio,
                ),
                const SizedBox(height: 18),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text('Posts', style: AppTextStyles.headline3),
                ),
                const SizedBox(height: 10),
                BlocBuilder<PostsCubit, PostsState>(
                  builder: (context, state) {
                    if (state is PostsLoading) {
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: 3,
                        itemBuilder: (context, index) => const Padding(
                          padding: EdgeInsets.only(bottom: 10),
                          child: ShimmerBox(
                            width: double.infinity,
                            height: 84,
                            borderRadius: 16,
                          ),
                        ),
                      );
                    }
                    if (state is PostsError) {
                      return Padding(
                        padding: const EdgeInsets.all(24),
                        child: Center(
                          child: Text(state.message, style: AppTextStyles.body2),
                        ),
                      );
                    }
                    if (state is PostsLoaded) {
                      if (state.posts.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.all(32),
                          child: Center(
                            child: EmptyStateWidget(
                              icon: Icons.article_outlined,
                              title: 'No posts yet',
                              subtitle: '$userName hasn\'t posted anything yet.',
                            ),
                          ),
                        );
                      }
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: state.posts.length,
                          itemBuilder: (context, index) {
                            final post = state.posts[index];
                            final authorName = (post.userName.isNotEmpty &&
                                    post.userName != 'Unknown')
                                ? post.userName
                                : userName;
                            return UserPostTile(
                              postId: post.id,
                              userId: post.userId.isNotEmpty ? post.userId : userId,
                              userName: authorName,
                              title: post.title,
                              description: post.description,
                              imageUrl: post.imageUrl,
                              deleteHash: post.deleteHash,
                              likeCount: post.likeCount,
                              commentCount: post.commentCount,
                              createdAt: post.createdAt,
                              lastEditedAt: post.lastEditedAt,
                            );
                          },
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
