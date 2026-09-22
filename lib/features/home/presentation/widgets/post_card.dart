import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connecthub/core/utils/app_theme.dart';
import 'package:connecthub/core/utils/app_widgets.dart';
import 'package:connecthub/core/utils/mention_text.dart';
import 'package:connecthub/features/home/data/models/post_model.dart';
import 'package:connecthub/features/post/presentation/views/post_details_view.dart';
import 'package:connecthub/core/utils/profile_navigation_helper.dart';

class PostCard extends StatelessWidget {
  final PostModel post;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool isOwnPost;

  const PostCard({
    super.key,
    required this.post,
    required this.onLike,
    required this.onComment,
    this.onEdit,
    this.onDelete,
    this.isOwnPost = false,
  });

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final isLiked = post.likes.contains(currentUserId);
    final timeAgo = _getTimeAgo(post.createdAt);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => PostDetailsView(postId: post.id)),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: isOwnPost
              ? Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  width: 2,
                )
              : null,
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isOwnPost)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.accent],
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(18),
                    topRight: Radius.circular(18),
                  ),
                ),
                child: const Center(
                  child: Text(
                    'Your Post',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => ProfileNavigationHelper.openUserProfile(
                            context,
                            userId: post.userId,
                            userName: post.userName,
                          ),
                          child: Row(
                            children: [
                              UserAvatar(name: post.userName, size: 44),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      post.userName,
                                      style: AppTextStyles.body1.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Text(timeAgo, style: AppTextStyles.caption),
                                        if (post.lastEditedAt != null) ...[
                                          const SizedBox(width: 4),
                                          const Text('•', style: AppTextStyles.caption),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Edited',
                                            style: AppTextStyles.caption.copyWith(
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (isOwnPost && (onEdit != null || onDelete != null))
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert,
                              color: AppColors.textSecondary),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          onSelected: (value) {
                            if (value == 'edit') {
                              onEdit?.call();
                            } else if (value == 'delete') {
                              onDelete?.call();
                            }
                          },
                          itemBuilder: (context) => [
                            if (onEdit != null)
                              const PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit_outlined,
                                        size: 20, color: AppColors.textPrimary),
                                    SizedBox(width: 12),
                                    Text('Edit Post'),
                                  ],
                                ),
                              ),
                            if (onDelete != null)
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete_outline,
                                        size: 20, color: AppColors.error),
                                    SizedBox(width: 12),
                                    Text('Delete Post',
                                        style: TextStyle(color: AppColors.error)),
                                  ],
                                ),
                              ),
                          ],
                        )
                      else if (!isOwnPost)
                        const Icon(
                          Icons.chevron_right,
                          size: 16,
                          color: AppColors.textHint,
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(post.title, style: AppTextStyles.headline3),
                  const SizedBox(height: 8),
                  MentionText(
                    text: post.description,
                    style: AppTextStyles.body2,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (post.imageUrl != null && post.imageUrl!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: CachedNetworkImage(
                        imageUrl: post.imageUrl!,
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                        placeholder: (_, _) => Container(
                          height: 200,
                          color: AppColors.surfaceVariant,
                          child: const Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        errorWidget: (_, _, _) => Container(
                          height: 200,
                          color: AppColors.surfaceVariant,
                          child: const Icon(
                            Icons.broken_image_outlined,
                            color: AppColors.textHint,
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  const Divider(color: AppColors.divider, height: 1),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _ActionButton(
                        icon: isLiked ? Icons.favorite : Icons.favorite_border,
                        label: '${post.likeCount}',
                        color: isLiked ? AppColors.accent : AppColors.textHint,
                        onTap: onLike,
                      ),
                      const SizedBox(width: 20),
                      _ActionButton(
                        icon: Icons.chat_bubble_outline,
                        label: '${post.commentCount}',
                        color: AppColors.textHint,
                        onTap: onComment,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inDays > 7) {
      return DateFormat('MMM d').format(dateTime);
    } else if (diff.inDays > 0) {
      return '${diff.inDays}d ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h ago';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.body2.copyWith(
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
