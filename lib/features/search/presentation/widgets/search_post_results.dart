import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connecthub/core/utils/app_theme.dart';
import 'package:connecthub/features/home/presentation/manager/cubit/posts_cubit.dart';
import 'package:connecthub/features/home/presentation/widgets/post_card.dart';
import 'package:connecthub/features/post/presentation/views/post_details_view.dart';

class SearchPostResults extends StatelessWidget {
  final List posts;

  const SearchPostResults({super.key, required this.posts});

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) {
      return Center(
        child: Text('No posts found', style: AppTextStyles.body2),
      );
    }

    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        return PostCard(
          post: post,
          isOwnPost: post.userId == currentUserId,
          onLike: () => context.read<PostsCubit>().toggleLike(post.id, currentUserId),
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
  }
}
