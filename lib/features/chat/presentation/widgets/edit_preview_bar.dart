import 'package:flutter/material.dart';
import 'package:connecthub/core/utils/app_theme.dart';

/// Compact bar shown above the input field when the user is editing an existing message.
class EditPreviewBar extends StatelessWidget {
  final String originalText;
  final VoidCallback onCancel;

  const EditPreviewBar({
    super.key,
    required this.originalText,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final firstLine = originalText.split('\n').first;
    final preview = firstLine.length > 80
        ? '${firstLine.substring(0, 80)}…'
        : firstLine;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        border: const Border(
          top: BorderSide(color: AppColors.divider, width: 1),
          left: BorderSide(color: AppColors.accent, width: 3),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.edit_rounded,
            size: 18,
            color: AppColors.accent,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Editing message',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.accent,
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
            icon: const Icon(Icons.close_rounded, size: 18),
            color: AppColors.textHint,
            onPressed: onCancel,
            tooltip: 'Cancel edit',
          ),
        ],
      ),
    );
  }
}
