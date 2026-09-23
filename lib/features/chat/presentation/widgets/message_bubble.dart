import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:connecthub/core/utils/app_theme.dart';
import 'package:connecthub/core/utils/app_widgets.dart';
import 'package:connecthub/features/chat/data/models/message_model.dart';
import 'package:connecthub/features/post/presentation/views/post_details_view.dart';

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
                    ? const LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: message.isDeleted
                    ? AppColors.surfaceVariant.withValues(alpha: 0.6)
                    : (isMe ? null : AppColors.surfaceVariant),
                border: message.isDeleted
                    ? Border.all(
                        color: AppColors.divider.withValues(alpha: 0.8),
                        width: 1,
                      )
                    : null,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft:
                      isMe ? const Radius.circular(20) : const Radius.circular(4),
                  bottomRight:
                      isMe ? const Radius.circular(4) : const Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
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
                    _ReplyQuote(
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
                                const Icon(
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
                          _SharedPostCard(message: message, isMe: isMe)
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
      builder: (_) => _MessageOptionsSheet(
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

// ─────────────────────────────────────────────────────────────────────────────
// Reply quote inside a bubble
// ─────────────────────────────────────────────────────────────────────────────

class _ReplyQuote extends StatelessWidget {
  final String senderName;
  final String text;
  final bool isMe;
  final VoidCallback? onTap;

  const _ReplyQuote({
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

// ─────────────────────────────────────────────────────────────────────────────
// Options bottom sheet
// ─────────────────────────────────────────────────────────────────────────────

class _MessageOptionsSheet extends StatelessWidget {
  final MessageModel message;
  final bool isMe;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback onReply;
  final VoidCallback onForward;
  final VoidCallback onCopy;

  const _MessageOptionsSheet({
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
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
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

// ─────────────────────────────────────────────────────────────────────────────
// Shared post preview card inside a message bubble
// ─────────────────────────────────────────────────────────────────────────────

class _SharedPostCard extends StatelessWidget {
  final MessageModel message;
  final bool isMe;

  const _SharedPostCard({
    required this.message,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    final preview = message.sharedPostPreview ?? {};
    final postId = message.sharedPostId ?? (preview['postId'] as String? ?? '');
    final title = (preview['title'] as String? ?? '').trim();
    final description = (preview['description'] as String? ?? '').trim();
    final imageUrl = preview['imageUrl'] as String?;
    final authorName = (preview['authorName'] as String? ?? 'User').trim();
    final authorPhoto = preview['authorPhoto'] as String?;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: postId.isNotEmpty
            ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PostDetailsView(postId: postId),
                  ),
                );
              }
            : null,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 250,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isMe
                ? Colors.white.withValues(alpha: 0.12)
                : AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isMe
                  ? Colors.white.withValues(alpha: 0.25)
                  : AppColors.divider,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Badge + Author Row
              Row(
                children: [
                  UserAvatar(
                    name: authorName,
                    size: 26,
                    imageUrl: authorPhoto,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      authorName,
                      style: AppTextStyles.body2.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isMe ? Colors.white : AppColors.textPrimary,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isMe
                          ? Colors.white.withValues(alpha: 0.2)
                          : AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.article_outlined,
                          size: 11,
                          color: isMe ? Colors.white : AppColors.primary,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          'Shared Post',
                          style: AppTextStyles.caption.copyWith(
                            color: isMe ? Colors.white : AppColors.primary,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (imageUrl != null && imageUrl.isNotEmpty) ...[
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    height: 130,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (_, _) => Container(
                      height: 130,
                      color: AppColors.surfaceVariant,
                      child: const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    errorWidget: (_, _, _) => Container(
                      height: 130,
                      color: AppColors.surfaceVariant,
                      child: const Icon(
                        Icons.broken_image_outlined,
                        color: AppColors.textHint,
                      ),
                    ),
                  ),
                ),
              ],
              if (title.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  title,
                  style: AppTextStyles.body1.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isMe ? Colors.white : AppColors.textPrimary,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (description.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AppTextStyles.body2.copyWith(
                    color: isMe
                        ? Colors.white.withValues(alpha: 0.85)
                        : AppColors.textSecondary,
                    fontSize: 12,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
