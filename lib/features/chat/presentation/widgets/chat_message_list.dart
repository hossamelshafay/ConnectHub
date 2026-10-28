import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:connecthub/core/utils/app_theme.dart';
import 'package:connecthub/features/chat/data/models/message_model.dart';
import 'package:connecthub/features/chat/presentation/manager/cubit/chat_cubit.dart';
import 'package:connecthub/features/chat/presentation/widgets/message_bubble.dart';
import 'package:connecthub/features/chat/presentation/widgets/forward_message_sheet.dart';
import 'package:connecthub/features/chat/presentation/widgets/typing_indicator.dart';

class ChatMessageList extends StatelessWidget {
  final List<MessageModel> messages;
  final String myUid;
  final String myName;
  final String peerId;
  final String peerName;
  final String? peerPhoto;
  final ScrollController scrollController;
  final Map<String, GlobalKey> messageKeys;
  final String conversationId;
  final ChatCubit cubit;
  final void Function(MessageModel) onReply;
  final void Function(MessageModel) onEdit;
  final void Function(MessageModel) onDelete;
  final void Function(String messageId) onScrollToMessage;

  const ChatMessageList({
    super.key,
    required this.messages,
    required this.myUid,
    required this.myName,
    required this.peerId,
    required this.peerName,
    this.peerPhoto,
    required this.scrollController,
    required this.messageKeys,
    required this.conversationId,
    required this.cubit,
    required this.onReply,
    required this.onEdit,
    required this.onDelete,
    required this.onScrollToMessage,
  });

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.waving_hand_rounded,
                size: 56,
                color: AppColors.textHint.withValues(alpha: 0.4)),
            const SizedBox(height: 12),
            Text('Say hello!',
                style: AppTextStyles.body2
                    .copyWith(color: AppColors.textHint)),
          ],
        ),
      );
    }

    // Find the last outgoing message for seen indicator.
    int lastOutgoingIndex = -1;
    for (int i = messages.length - 1; i >= 0; i--) {
      if (messages[i].senderId == myUid) {
        lastOutgoingIndex = i;
        break;
      }
    }

    // Typing indicator stream from conversation doc.
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('conversations')
          .doc(conversationId)
          .snapshots(),
      builder: (context, convSnap) {
        bool isPeerTyping = false;
        if (convSnap.hasData && convSnap.data!.exists) {
          final data =
              convSnap.data!.data() as Map<String, dynamic>? ?? {};
          final typingUsers =
              data['typingUsers'] as Map<String, dynamic>? ?? {};
          isPeerTyping = typingUsers[peerId] as bool? ?? false;
        }

        return ListView.builder(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(0, 12, 0, 12),
          itemCount: messages.length + (isPeerTyping ? 1 : 0),
          itemBuilder: (context, index) {
            // Typing indicator at the end
            if (isPeerTyping && index == messages.length) {
              return const TypingIndicator();
            }

            final msg = messages[index];
            final isMe = msg.senderId == myUid;
            final isLastOutgoing = index == lastOutgoingIndex;
            final isSeen = msg.seenBy.contains(peerId);

            // Register GlobalKey for scroll-to-reply.
            messageKeys.putIfAbsent(msg.id, () => GlobalKey());

            return KeyedSubtree(
              key: messageKeys[msg.id],
              child: MessageBubble(
                message: msg,
                isMe: isMe,
                showSeenIndicator: isMe && isLastOutgoing,
                isLastSeen: isLastOutgoing && isSeen,
                onReply: () => onReply(msg),
                onForward: () => _showForwardSheet(context, msg),
                onEdit: isMe && !msg.isDeleted ? () => onEdit(msg) : null,
                onDelete: () => onDelete(msg),
                onTapReply: msg.replyToId != null
                    ? () => onScrollToMessage(msg.replyToId!)
                    : null,
              ),
            );
          },
        );
      },
    );
  }

  void _showForwardSheet(BuildContext context, MessageModel msg) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => ForwardMessageSheet(
        message: msg,
        myUid: myUid,
        myName: myName,
      ),
    );
  }
}
