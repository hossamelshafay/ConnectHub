import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connecthub/core/utils/app_theme.dart';
import 'package:connecthub/features/home/data/models/post_model.dart';
import 'package:connecthub/features/home/presentation/manager/cubit/posts_cubit.dart';
import 'package:connecthub/features/home/presentation/widgets/post_card.dart';
import 'package:connecthub/features/post/presentation/views/post_details_view.dart';
import 'package:connecthub/features/profile/presentation/manager/cubit/profile_cubit.dart';

class LikedPostsView extends StatelessWidget {
  final String? userId;

  const LikedPostsView({super.key, this.userId});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ProfileCubit>();
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final targetUserId = userId ?? currentUserId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Liked Posts'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<List<PostModel>>(
        stream: cubit.getLikedPostsStream(targetUserId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Failed to load liked posts: ${snapshot.error}',
                style: AppTextStyles.body2.copyWith(color: AppColors.error),
              ),
            );
          }

          final posts = snapshot.data ?? [];
          if (posts.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      color: AppColors.surfaceVariant,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.favorite_border_rounded,
                      size: 40,
                      color: AppColors.textHint,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('No liked posts yet', style: AppTextStyles.headline3),
                  const SizedBox(height: 6),
                  Text(
                    'Posts you like will be saved here.',
                    style:
                        AppTextStyles.body2.copyWith(color: AppColors.textHint),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return PostCard(
                post: post,
                isOwnPost: post.userId == currentUserId,
                onLike: () {
                  context.read<PostsCubit>().toggleLike(post.id, currentUserId);
                },
                onComment: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PostDetailsView(postId: post.id),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
