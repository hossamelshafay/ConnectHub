import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connecthub/core/utils/app_theme.dart';
import 'package:connecthub/core/utils/app_widgets.dart';
import 'package:connecthub/features/home/presentation/manager/cubit/posts_cubit.dart';
import 'package:connecthub/features/home/presentation/manager/cubit/posts_state.dart';
import 'package:connecthub/features/home/presentation/widgets/home_feed_error_view.dart';
import 'package:connecthub/features/home/presentation/widgets/post_card.dart';
import 'package:connecthub/features/post/presentation/manager/cubit/post_action_cubit.dart';
import 'package:connecthub/features/post/presentation/views/edit_post_view.dart';
import 'package:connecthub/features/post/presentation/views/post_details_view.dart';
import 'package:connecthub/features/post/presentation/widgets/delete_post_dialog.dart';

/// Renders the feed sliver containing loading shimmers, error state,
/// empty state, or list of PostCards.
class HomeFeedSliver extends StatelessWidget {
  final String currentUserId;
  final VoidCallback onOpenCreatePost;

  const HomeFeedSliver({
    super.key,
    required this.currentUserId,
    required this.onOpenCreatePost,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PostsCubit, PostsState>(
      builder: (context, state) {
        if (state is PostsLoading) {
          return SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: PostShimmerCard(),
              ),
              childCount: 3,
            ),
          );
        }

        if (state is PostsError) {
          return SliverFillRemaining(
            hasScrollBody: false,
            child: HomeFeedErrorView(
              message: state.message,
              onRetry: () {
                context.read<PostsCubit>().loadPosts();
              },
            ),
          );
        }

        if (state is PostsLoaded) {
          if (state.posts.isEmpty) {
            return SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: EmptyStateWidget(
                  icon: Icons.article_outlined,
                  title: 'No posts yet',
                  subtitle:
                      'Connect with peers or share your first post to inspire others.',
                  actionText: 'Create Post',
                  onAction: onOpenCreatePost,
                ),
              ),
            );
          }

          return SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final post = state.posts[index];
                final isOwn = post.userId == currentUserId;
                return PostCard(
                  post: post,
                  isOwnPost: isOwn,
                  onLike: () {
                    context
                        .read<PostsCubit>()
                        .toggleLike(post.id, currentUserId);
                  },
                  onComment: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PostDetailsView(postId: post.id),
                      ),
                    );
                  },
                  onEdit: isOwn
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditPostView(
                                postId: post.id,
                                initialTitle: post.title,
                                initialDescription: post.description,
                                initialImageUrl: post.imageUrl,
                                initialDeleteHash: post.deleteHash,
                              ),
                            ),
                          );
                        }
                      : null,
                  onDelete: isOwn
                      ? () {
                          DeletePostDialog.show(
                            context,
                            description: post.description,
                            onConfirm: () async {
                              final cubit = PostActionCubit();
                              try {
                                await cubit.deletePost(
                                  postId: post.id,
                                  deleteHash: post.deleteHash,
                                );
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text(
                                          'Post deleted successfully'),
                                      backgroundColor:
                                          AppColors.surfaceVariant,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12),
                                        side: const BorderSide(
                                          color: AppColors.success,
                                          width: 1,
                                        ),
                                      ),
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(e.toString()),
                                      backgroundColor:
                                          AppColors.surfaceVariant,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12),
                                        side: const BorderSide(
                                          color: AppColors.error,
                                          width: 1,
                                        ),
                                      ),
                                    ),
                                  );
                                }
                              }
                            },
                          );
                        }
                      : null,
                );
              },
              childCount: state.posts.length,
            ),
          );
        }

        return const SliverToBoxAdapter(child: SizedBox.shrink());
      },
    );
  }
}
