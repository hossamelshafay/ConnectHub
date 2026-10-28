import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connecthub/core/utils/app_theme.dart';
import 'package:connecthub/core/utils/app_widgets.dart';
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text('Liked Posts', style: AppTextStyles.headline3),
        centerTitle: true,
        leading: Center(
          child: AppIconButton(
            icon: Icons.arrow_back_ios_new,
            size: 18,
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: StreamBuilder<List<PostModel>>(
        stream: cubit.getLikedPostsStream(targetUserId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: 3,
              itemBuilder: (context, index) => const Padding(
                padding: EdgeInsets.symmetric(vertical: 6),
                child: PostShimmerCard(),
              ),
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
              child: EmptyStateWidget(
                icon: Icons.favorite_border_rounded,
                title: 'No liked posts yet',
                subtitle: 'Posts you like across the platform will appear here.',
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
