import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:connecthub/core/utils/app_theme.dart';
import 'package:connecthub/features/chat/data/models/message_model.dart';
import 'package:connecthub/features/chat/presentation/widgets/chat_message_options_sheet.dart';
import 'package:connecthub/features/chat/presentation/widgets/chat_reply_quote.dart';
import 'package:connecthub/features/chat/presentation/widgets/chat_shared_post_card.dart';

/// A single chat message bubble.
///
/// - Own messages are right-aligned with a primary gradient.
/// - Peer messages are left-aligned with a surface-variant background.
/// - Shows reply quote, forwarded label, timestamp, and seen indicator.
/// - Overflow menu (⋮) provides Copy, Reply, Forward actions.
class MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMe;
  final bool showSeenIndicator;
  final bool isLastSeen;
  final VoidCallback onReply;
  final VoidCallback onForward;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onTapReply;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    required this.showSeenIndicator,
    required this.isLastSeen,
    required this.onReply,
    required this.onForward,
    this.onEdit,
    this.onDelete,
    this.onTapReply,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: isMe ? 60 : 8,
        right: isMe ? 8 : 60,
        top: 2,
        bottom: 2,
      ),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // Forwarded label
          if (message.isForwarded && !message.isDeleted)
            Padding(
              padding: EdgeInsets.only(
                left: isMe ? 0 : 4,
                right: isMe ? 4 : 0,
                bottom: 2,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.forward_rounded,
                      size: 13, color: AppColors.textHint),
                  const SizedBox(width: 3),
                  Text(
                    'Forwarded',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textHint,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),

          // Bubble
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onLongPress: () => _showOptions(context),
            onSecondaryTap: () => _showOptions(context),
            onDoubleTap: () => _showOptions(context),
            child: Container(
              decoration: BoxDecoration(
                gradient: (isMe && !message.isDeleted)
                    ? LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: message.isDeleted
                    ? AppColors.surfaceVariant.withValues(alpha: 0.4)
                    : (isMe ? null : AppColors.surfaceVariant.withValues(alpha: 0.75)),
                border: Border.all(
                  color: isMe
                      ? Colors.white.withValues(alpha: 0.15)
                      : (message.isDeleted
                          ? AppColors.divider.withValues(alpha: 0.5)
                          : AppColors.glassBorder),
                  width: 0.8,
                ),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft:
                      isMe ? const Radius.circular(18) : const Radius.circular(4),
                  bottomRight:
                      isMe ? const Radius.circular(4) : const Radius.circular(18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isMe ? AppColors.primaryDark : Colors.black)
                        .withValues(alpha: isMe ? 0.08 : 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 1.5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Reply quote (only if not deleted)
                  if (!message.isDeleted &&
                      message.replyToId != null &&
                      message.replyToText != null)
                    ChatReplyQuote(
                      senderName: message.replyToSenderName ?? '',
                      text: message.replyToText!,
                      isMe: isMe,
                      onTap: onTapReply,
                    ),

                  // Message text + timestamp row
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (message.isDeleted)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 2),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.block_rounded,
                                  size: 14,
                                  color: AppColors.textHint,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'This message was deleted',
                                  style: AppTextStyles.body2.copyWith(
                                    color: AppColors.textHint,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else if (message.type == MessageType.postShare)
                          ChatSharedPostCard(message: message, isMe: isMe)
                        else
                          Text(
                            message.text,
                            style: AppTextStyles.body1.copyWith(
                              color: isMe ? Colors.white : AppColors.textPrimary,
                              height: 1.4,
                            ),
                          ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!message.isDeleted && message.isEdited) ...[
                              Text(
                                'edited • ',
                                style: AppTextStyles.caption.copyWith(
                                  color: isMe
                                      ? Colors.white.withValues(alpha: 0.75)
                                      : AppColors.textHint,
                                  fontSize: 10,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                            Text(
                              DateFormat('HH:mm').format(message.sentAt),
                              style: AppTextStyles.caption.copyWith(
                                color: (isMe && !message.isDeleted)
                                    ? Colors.white.withValues(alpha: 0.7)
                                    : AppColors.textHint,
                                fontSize: 11,
                              ),
                            ),
                            if (isMe &&
                                !message.isDeleted &&
                                showSeenIndicator) ...[
                              const SizedBox(width: 4),
                              Icon(
                                isLastSeen
                                    ? Icons.done_all_rounded
                                    : Icons.done_rounded,
                                size: 14,
                                color: isLastSeen
                                    ? Colors.white
                                    : Colors.white.withValues(alpha: 0.6),
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
        ],
      ),
    );
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => ChatMessageOptionsSheet(
        message: message,
        isMe: isMe,
        onEdit: onEdit != null
            ? () {
                Navigator.pop(context);
                onEdit!();
              }
            : null,
        onDelete: onDelete != null
            ? () {
                Navigator.pop(context);
                onDelete!();
              }
            : null,
        onReply: () {
          Navigator.pop(context);
          onReply();
        },
        onForward: () {
          Navigator.pop(context);
          onForward();
        },
        onCopy: () {
          Navigator.pop(context);
          String copyText = message.text;
          if (message.type == MessageType.postShare &&
              message.sharedPostPreview != null) {
            final p = message.sharedPostPreview!;
            final title = p['title'] as String? ?? '';
            final desc = p['description'] as String? ?? '';
            copyText = title.isNotEmpty ? '$title\n$desc' : desc;
          }
          Clipboard.setData(ClipboardData(text: copyText));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Message copied'),
              backgroundColor: AppColors.textSecondary,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        },
      ),
    );
  }
}
