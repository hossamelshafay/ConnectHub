import 'package:flutter/material.dart';
import 'package:connecthub/core/utils/app_theme.dart';

class ChatReplyQuote extends StatelessWidget {
  final String senderName;
  final String text;
  final bool isMe;
  final VoidCallback? onTap;

  const ChatReplyQuote({
    super.key,
    required this.senderName,
    required this.text,
    required this.isMe,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final firstLine = text.split('\n').first;
    final preview =
        firstLine.length > 60 ? '${firstLine.substring(0, 60)}…' : firstLine;
    final quoteColor = isMe
        ? Colors.white.withValues(alpha: 0.15)
        : AppColors.primary.withValues(alpha: 0.08);
    final borderColor =
        isMe ? Colors.white.withValues(alpha: 0.5) : AppColors.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(8, 8, 8, 0),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: quoteColor,
          border: Border(left: BorderSide(color: borderColor, width: 3)),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(12),
            bottomRight: Radius.circular(12),
            bottomLeft: Radius.circular(4),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              senderName,
              style: AppTextStyles.caption.copyWith(
                color: isMe ? Colors.white : AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              preview,
              style: AppTextStyles.caption.copyWith(
                color: isMe
                    ? Colors.white.withValues(alpha: 0.8)
                    : AppColors.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
