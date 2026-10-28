import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connecthub/core/utils/app_theme.dart';
import 'package:connecthub/core/utils/app_widgets.dart';
import 'package:connecthub/features/post/presentation/widgets/comment_tile.dart';

class PostDetailsCommentsSection extends StatelessWidget {
  final AsyncSnapshot<QuerySnapshot> commSnap;
  final String currentUserId;
  final String postOwnerId;
  final bool isProcessing;
  final Function(String commentId, String commentText) onStartEditing;
  final Function(String commentId) onConfirmDelete;
  final VoidCallback onRetry;

  const PostDetailsCommentsSection({
    super.key,
    required this.commSnap,
    required this.currentUserId,
    required this.postOwnerId,
    required this.isProcessing,
    required this.onStartEditing,
    required this.onConfirmDelete,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text('Comments', style: AppTextStyles.headline3),
        const SizedBox(height: 12),
        if (commSnap.connectionState == ConnectionState.waiting && !commSnap.hasData)
          const CommentShimmer(itemCount: 3)
        else if (commSnap.hasError)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline_rounded, size: 32, color: AppColors.error),
                  const SizedBox(height: 8),
                  Text('Could not load comments.', style: AppTextStyles.body2),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh_rounded, size: 16),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),
          )
        else if (commSnap.data == null || commSnap.data!.docs.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 36),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.chat_bubble_outline_rounded,
                      color: AppColors.textHint,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No comments yet',
                    style: AppTextStyles.body1.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Be the first to share your thoughts!',
                    style: AppTextStyles.caption.copyWith(color: AppColors.textHint),
                  ),
                ],
              ),
            ),
          )
        else
          Builder(
            builder: (context) {
              final sortedComments = List<QueryDocumentSnapshot>.from(commSnap.data!.docs);
              sortedComments.sort((a, b) {
                final aData = a.data() as Map<String, dynamic>? ?? {};
                final bData = b.data() as Map<String, dynamic>? ?? {};
                final aDate = (aData['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
                final bDate = (bData['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
                return aDate.compareTo(bDate);
              });

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: sortedComments.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final commentDoc = sortedComments[index];
                  final commentId = commentDoc.id;
                  final comm = commentDoc.data() as Map<String, dynamic>;
                  final commentUserId = comm['userId'] as String? ?? '';
                  final commentText = comm['text'] as String? ?? '';
                  final commentCreatedAt = (comm['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
                  final commentLastEditedAt = (comm['lastEditedAt'] as Timestamp?)?.toDate();

                  final isCommentOwner = currentUserId.isNotEmpty && commentUserId == currentUserId;
                  final isPostOwner = currentUserId.isNotEmpty && postOwnerId == currentUserId;
                  final canEdit = isCommentOwner;
                  final canDelete = isCommentOwner || isPostOwner;

                  return CommentTile(
                    commentId: commentId,
                    userId: commentUserId,
                    userName: comm['userName'] ?? 'User',
                    text: commentText,
                    createdAt: commentCreatedAt,
                    lastEditedAt: commentLastEditedAt,
                    onEdit: canEdit ? () => onStartEditing(commentId, commentText) : null,
                    onDelete: canDelete ? () => onConfirmDelete(commentId) : null,
                    isProcessing: isProcessing,
                  );
                },
              );
            },
          ),
      ],
    );
  }
}
