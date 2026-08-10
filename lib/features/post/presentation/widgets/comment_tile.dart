import 'package:flutter/material.dart';
import 'package:connecthub/core/utils/app_theme.dart';
import 'package:connecthub/core/utils/app_widgets.dart';

class CommentTile extends StatelessWidget {
  final String userName;
  final String text;
  final DateTime createdAt;

  const CommentTile({
    super.key,
    required this.userName,
    required this.text,
    required this.createdAt,
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
              UserAvatar(name: userName, size: 32),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  userName,
                  style: AppTextStyles.body2
                      .copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              Text(
                _timeAgo(createdAt),
                style: AppTextStyles.caption,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(text, style: AppTextStyles.body1.copyWith(fontSize: 14)),
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
