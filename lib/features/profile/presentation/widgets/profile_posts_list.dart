import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connecthub/core/utils/app_theme.dart';
import 'package:connecthub/core/utils/app_widgets.dart';
import 'package:connecthub/features/home/data/models/post_model.dart';
import 'package:connecthub/features/profile/presentation/widgets/user_post_tile.dart';
import 'package:connecthub/features/post/presentation/views/edit_post_view.dart';
import 'package:connecthub/features/post/presentation/widgets/delete_post_dialog.dart';
import 'package:connecthub/features/post/presentation/manager/cubit/post_action_cubit.dart';
import 'package:connecthub/features/profile/presentation/manager/cubit/profile_cubit.dart';

class ProfilePostsList extends StatelessWidget {
  final List<PostModel> posts;
  final String? userName;
  final String? userPhoto;

  const ProfilePostsList({
    super.key,
    required this.posts,
    this.userName,
    this.userPhoto,
  });

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Center(
          child: EmptyStateWidget(
            icon: Icons.article_outlined,
            title: 'No posts yet',
            subtitle: 'Share your insights, projects, and achievements.',
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          return UserPostTile(
            postId: post.id,
            userId: post.userId,
            title: post.title,
            description: post.description,
            imageUrl: post.imageUrl,
            deleteHash: post.deleteHash,
            likeCount: post.likeCount,
            commentCount: post.commentCount,
            createdAt: post.createdAt,
            lastEditedAt: post.lastEditedAt,
            userName: (post.userName.isNotEmpty && post.userName != 'Unknown')
                ? post.userName
                : userName,
            userPhoto: userPhoto,
            onEdit: () {
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
            },
            onDelete: () {
              DeletePostDialog.show(
                context,
                description: post.description,
                onConfirm: () async {
                  final postActionCubit = PostActionCubit();
                  try {
                    await postActionCubit.deletePost(
                      postId: post.id,
                      deleteHash: post.deleteHash,
                    );
                    if (context.mounted) {
                      context.read<ProfileCubit>().loadProfile();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Post deleted successfully'),
                          backgroundColor: AppColors.surfaceVariant,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
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
                          backgroundColor: AppColors.surfaceVariant,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
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
            },
          );
        },
      ),
    );
  }
}
