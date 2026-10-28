import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connecthub/core/utils/app_theme.dart';
import 'package:connecthub/features/chat/presentation/widgets/share_post_sheet.dart';
import 'package:connecthub/features/home/data/models/post_model.dart';
import 'package:connecthub/features/post/data/repos/post_repo.dart';
import 'package:connecthub/features/post/presentation/widgets/liked_by_sheet.dart';

class PostDetailsActionsBar extends StatelessWidget {
  final String postId;
  final DocumentSnapshot postDoc;
  final bool isLiked;
  final int likeCount;
  final int commentCount;
  final List<String> serverLikes;
  final PostRepo postRepo;
  final VoidCallback onToggleLike;

  const PostDetailsActionsBar({
    super.key,
    required this.postId,
    required this.postDoc,
    required this.isLiked,
    required this.likeCount,
    required this.commentCount,
    required this.serverLikes,
    required this.postRepo,
    required this.onToggleLike,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onToggleLike,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  color: isLiked ? AppColors.accent : AppColors.textHint,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  '$likeCount',
                  style: AppTextStyles.body1.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _showLikedBySheet(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Liked By',
                style: AppTextStyles.body2.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const Spacer(),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.chat_bubble_outline, color: AppColors.textHint, size: 22),
              const SizedBox(width: 8),
              Text(
                '$commentCount',
                style: AppTextStyles.body1.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          InkWell(
            onTap: () {
              final user = FirebaseAuth.instance.currentUser;
              if (user == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Please log in to share posts.'),
                    backgroundColor: AppColors.error,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
                return;
              }
              final postObj = PostModel.fromDoc(postDoc);
              SharePostSheet.show(
                context,
                post: postObj,
                myUid: user.uid,
                myName: (user.displayName != null && user.displayName!.trim().isNotEmpty)
                    ? user.displayName!.trim()
                    : 'User',
              );
            },
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Row(
                children: [
                  Icon(Icons.share_outlined, color: AppColors.textHint, size: 22),
                  const SizedBox(width: 6),
                  Text(
                    'Share',
                    style: TextStyle(
                      color: AppColors.textHint,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLikedBySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => LikedBySheet(userIds: serverLikes, postRepo: postRepo),
    );
  }
}
