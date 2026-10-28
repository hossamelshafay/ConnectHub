import 'package:flutter/material.dart';
import 'package:connecthub/core/utils/app_theme.dart';
import 'package:connecthub/features/chat/data/models/message_model.dart';

class ChatMessageOptionsSheet extends StatelessWidget {
  final MessageModel message;
  final bool isMe;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback onReply;
  final VoidCallback onForward;
  final VoidCallback onCopy;

  const ChatMessageOptionsSheet({
    super.key,
    required this.message,
    required this.isMe,
    this.onEdit,
    this.onDelete,
    required this.onReply,
    required this.onForward,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    final isDeleted = message.isDeleted;

    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.glassBorder, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.16),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            if (isDeleted) ...[
              if (onDelete != null)
                _OptionTile(
                  icon: Icons.delete_outline_rounded,
                  label: 'Delete for me',
                  color: AppColors.error,
                  onTap: onDelete!,
                ),
            ] else ...[
              if (isMe && onEdit != null && message.type == MessageType.text)
                _OptionTile(
                  icon: Icons.edit_rounded,
                  label: 'Edit',
                  color: AppColors.accent,
                  onTap: onEdit!,
                ),
              _OptionTile(
                icon: Icons.reply_rounded,
                label: 'Reply',
                onTap: onReply,
              ),
              _OptionTile(
                icon: Icons.copy_rounded,
                label: 'Copy',
                onTap: onCopy,
              ),
              _OptionTile(
                icon: Icons.forward_rounded,
                label: 'Forward',
                onTap: onForward,
              ),
              if (onDelete != null)
                _OptionTile(
                  icon: Icons.delete_outline_rounded,
                  label: isMe ? 'Delete' : 'Delete for me',
                  color: AppColors.error,
                  onTap: onDelete!,
                ),
            ],
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _OptionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final tint = color ?? AppColors.primary;
    return ListTile(
      leading: Icon(icon, color: tint),
      title: Text(
        label,
        style: AppTextStyles.body1.copyWith(
          color: color,
          fontWeight: color != null ? FontWeight.w600 : null,
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
