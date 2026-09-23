import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:connecthub/core/utils/app_theme.dart';
import 'package:connecthub/core/utils/app_widgets.dart';
import 'package:connecthub/features/chat/data/models/conversation_model.dart';

class ConversationTile extends StatelessWidget {
  final ConversationModel conversation;
  final String myUid;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onDelete;

  const ConversationTile({
    super.key,
    required this.conversation,
    required this.myUid,
    required this.onTap,
    this.onLongPress,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final peerName = conversation.otherParticipantName(myUid);
    final peerPhoto = conversation.otherParticipantPhoto(myUid);
    final unread = conversation.myUnreadCount(myUid);
    final lastMsg = conversation.lastMessage;
    final isMyMessage =
        conversation.lastMessageSenderId == myUid && lastMsg.isNotEmpty;
    final preview = isMyMessage ? 'You: $lastMsg' : lastMsg;
    final time = _formatTime(conversation.lastMessageAt);

    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress ?? onDelete,
      onSecondaryTap: onDelete,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Avatar
            UserAvatar(name: peerName, size: 52, imageUrl: peerPhoto),
            const SizedBox(width: 14),

            // Name + preview
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          peerName,
                          style: AppTextStyles.body1.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (time.isNotEmpty)
                        Text(
                          time,
                          style: AppTextStyles.caption.copyWith(
                            color: unread > 0
                                ? AppColors.primary
                                : AppColors.textHint,
                            fontWeight: unread > 0
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          preview.isEmpty ? 'No messages yet' : preview,
                          style: AppTextStyles.body2.copyWith(
                            color: unread > 0
                                ? AppColors.textPrimary
                                : AppColors.textHint,
                            fontWeight: unread > 0
                                ? FontWeight.w500
                                : FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (unread > 0)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            unread > 99 ? '99+' : '$unread',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              height: 1,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            if (onDelete != null)
              PopupMenuButton<String>(
                icon: const Icon(
                  Icons.more_vert_rounded,
                  color: AppColors.textHint,
                  size: 20,
                ),
                tooltip: 'Chat options',
                padding: EdgeInsets.zero,
                splashRadius: 20,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                onSelected: (val) {
                  if (val == 'delete') {
                    onDelete!();
                  }
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline_rounded,
                            color: AppColors.error, size: 20),
                        SizedBox(width: 10),
                        Text(
                          'Delete chat',
                          style: TextStyle(
                            color: AppColors.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime? dt) {
    if (dt == null) return '';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final msgDay = DateTime(dt.year, dt.month, dt.day);
    if (msgDay == today) return DateFormat('HH:mm').format(dt);
    if (now.year == dt.year) return DateFormat('MMM d').format(dt);
    return DateFormat('MMM d, yyyy').format(dt);
  }
}
