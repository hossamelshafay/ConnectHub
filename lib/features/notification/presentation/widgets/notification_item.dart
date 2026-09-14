import 'package:flutter/material.dart';
import 'package:connecthub/core/utils/app_theme.dart';
import 'package:connecthub/core/utils/app_widgets.dart';
import 'package:connecthub/features/notification/data/models/notification_model.dart';

class NotificationItem extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const NotificationItem({
    super.key,
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: notification.isRead
              ? Colors.transparent
              : AppColors.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar
            UserAvatar(
              name: notification.senderName,
              size: 46,
              imageUrl: notification.senderPhoto,
            ),
            const SizedBox(width: 12),

            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sender name + action
                  RichText(
                    text: TextSpan(
                      style: AppTextStyles.body2.copyWith(
                        color: AppColors.textPrimary,
                        height: 1.5,
                      ),
                      children: [
                        TextSpan(
                          text: notification.senderName,
                          style: AppTextStyles.body2.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        TextSpan(text: ' ${_actionText(notification.type)}'),
                      ],
                    ),
                  ),

                  // Username
                  if (notification.senderUsername.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      _formatUsername(notification.senderUsername),
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ],

                  const SizedBox(height: 4),

                  // Relative time
                  Text(
                    _relativeTime(notification.createdAt),
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),

            // Unread indicator dot
            if (!notification.isRead) ...[
              const SizedBox(width: 8),
              Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.only(top: 6),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.accent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatUsername(String username) {
    return username.startsWith('@') ? username : '@$username';
  }

  String _actionText(NotificationType type) {
    switch (type) {
      case NotificationType.like:
        return 'liked your post.';
      case NotificationType.comment:
        return 'commented on your post.';
      case NotificationType.follow:
        return 'started following you.';
      case NotificationType.mention:
        return 'mentioned you in a post.';
    }
  }

  String _relativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 6) {
      final d = dt;
      return '${d.day}/${d.month}/${d.year}';
    } else if (diff.inDays >= 2) {
      return '${diff.inDays}d ago';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inHours >= 1) {
      return '${diff.inHours}h ago';
    } else if (diff.inMinutes >= 1) {
      return '${diff.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
