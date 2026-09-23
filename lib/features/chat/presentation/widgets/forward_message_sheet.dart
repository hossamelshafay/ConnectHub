import 'package:flutter/material.dart';
import 'package:connecthub/core/utils/app_theme.dart';
import 'package:connecthub/core/utils/app_widgets.dart';
import 'package:connecthub/features/chat/data/models/conversation_model.dart';
import 'package:connecthub/features/chat/data/models/message_model.dart';
import 'package:connecthub/features/chat/data/repos/chat_repo.dart';
import 'package:connecthub/features/chat/data/repos/chat_repo_imp.dart';

/// Bottom sheet that lists all conversations for forwarding a message.
class ForwardMessageSheet extends StatefulWidget {
  final MessageModel message;
  final String myUid;
  final String myName;
  final ChatRepo repo;

  ForwardMessageSheet({
    super.key,
    required this.message,
    required this.myUid,
    required this.myName,
    ChatRepo? repo,
  }) : repo = repo ?? ChatRepoImp();

  @override
  State<ForwardMessageSheet> createState() => _ForwardMessageSheetState();
}

class _ForwardMessageSheetState extends State<ForwardMessageSheet> {
  bool _isForwarding = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text('Forward to', style: AppTextStyles.headline3),
          ),
          const SizedBox(height: 8),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.5,
            ),
            child: StreamBuilder<List<ConversationModel>>(
              stream: widget.repo.getConversationsStream(widget.myUid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    ),
                  );
                }

                final conversations = snapshot.data ?? [];
                if (conversations.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: Text(
                        'No conversations yet.',
                        style: AppTextStyles.body2,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: conversations.length,
                  itemBuilder: (context, index) {
                    final conv = conversations[index];
                    final peerName = conv.otherParticipantName(widget.myUid);
                    final peerPhoto = conv.otherParticipantPhoto(widget.myUid);
                    final peerId = conv.otherParticipantId(widget.myUid);

                    return ListTile(
                      leading: UserAvatar(
                          name: peerName, size: 44, imageUrl: peerPhoto),
                      title: Text(peerName, style: AppTextStyles.body1),
                      onTap: _isForwarding
                          ? null
                          : () => _forward(context, conv.id, peerId),
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Future<void> _forward(
      BuildContext context, String conversationId, String receiverId) async {
    setState(() => _isForwarding = true);
    try {
      await widget.repo.forwardMessage(
        message: widget.message,
        targetConversationId: conversationId,
        myUid: widget.myUid,
        myName: widget.myName,
        receiverId: receiverId,
      );
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Message forwarded'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to forward message.'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isForwarding = false);
    }
  }
}
