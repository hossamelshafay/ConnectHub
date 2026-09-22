import 'package:flutter/material.dart';
import 'package:connecthub/core/utils/app_theme.dart';
import 'package:connecthub/core/utils/app_widgets.dart';
import 'package:connecthub/core/utils/mention_text.dart';
import 'package:connecthub/core/utils/profile_navigation_helper.dart';

class CommentTile extends StatelessWidget {
  final String? commentId;
  final String? userId;
  final String userName;
  final String text;
  final DateTime createdAt;
  final DateTime? lastEditedAt;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool isProcessing;

  const CommentTile({
    super.key,
    this.commentId,
    this.userId,
    required this.userName,
    required this.text,
    required this.createdAt,
    this.lastEditedAt,
    this.onEdit,
    this.onDelete,
    this.isProcessing = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  final id = userId;
                  if (id != null && id.isNotEmpty) {
                    ProfileNavigationHelper.openUserProfile(
                      context,
                      userId: id,
                      userName: userName,
                    );
                  } else {
                    ProfileNavigationHelper.openProfileByUsername(
                      context,
                      userName,
                    );
                  }
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    UserAvatar(name: userName, size: 32),
                    const SizedBox(width: 10),
                    Text(
                      userName,
                      style: AppTextStyles.body2
                          .copyWith(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                _timeAgo(createdAt),
                style: AppTextStyles.caption,
              ),
              if (lastEditedAt != null) ...[
                const SizedBox(width: 4),
                const Text('•', style: AppTextStyles.caption),
                const SizedBox(width: 4),
                Text(
                  'Edited',
                  style: AppTextStyles.caption
                      .copyWith(fontStyle: FontStyle.italic),
                ),
              ],
              if (onEdit != null || onDelete != null) ...[
                const SizedBox(width: 4),
                PopupMenuButton<String>(
                  enabled: !isProcessing,
                  icon: const Icon(Icons.more_vert,
                      color: AppColors.textSecondary, size: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.zero,
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
                                size: 18, color: AppColors.textPrimary),
                            SizedBox(width: 10),
                            Text('Edit Comment'),
                          ],
                        ),
                      ),
                    if (onDelete != null)
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline,
                                size: 18, color: AppColors.error),
                            SizedBox(width: 10),
                            Text('Delete Comment',
                                style: TextStyle(color: AppColors.error)),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          MentionText(
            text: text,
            style: AppTextStyles.body1.copyWith(fontSize: 14),
          ),
        ],
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 0) return '${diff.inDays}d';
    if (diff.inHours > 0) return '${diff.inHours}h';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m';
    return 'now';
  }
}
