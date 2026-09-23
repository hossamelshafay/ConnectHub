import 'package:flutter/material.dart';
import 'package:connecthub/core/utils/app_theme.dart';

/// Compact bar shown above the input field when the user is composing a reply.
class ReplyPreviewBar extends StatelessWidget {
  final String senderName;
  final String messageText;
  final VoidCallback onCancel;

  const ReplyPreviewBar({
    super.key,
    required this.senderName,
    required this.messageText,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final firstLine = messageText.split('\n').first;
    final preview = firstLine.length > 80
        ? '${firstLine.substring(0, 80)}…'
        : firstLine;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        border: Border(
          top: BorderSide(color: AppColors.divider, width: 1),
          left: BorderSide(color: AppColors.primary, width: 3),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Replying to $senderName',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  preview,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded,
                size: 20, color: AppColors.textHint),
            onPressed: onCancel,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ),
    );
  }
}
