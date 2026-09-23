import 'package:flutter/material.dart';
import 'package:connecthub/core/utils/app_theme.dart';
import 'package:connecthub/core/utils/app_widgets.dart';
import 'package:connecthub/features/chat/data/models/conversation_model.dart';
import 'package:connecthub/features/chat/data/repos/chat_repo.dart';
import 'package:connecthub/features/chat/data/repos/chat_repo_imp.dart';
import 'package:connecthub/features/home/data/models/post_model.dart';

/// Modal bottom sheet that lists all conversations for sharing a post.
class SharePostSheet extends StatefulWidget {
  final PostModel post;
  final String myUid;
  final String myName;
  final ChatRepo repo;

  SharePostSheet({
    super.key,
    required this.post,
    required this.myUid,
    required this.myName,
    ChatRepo? repo,
  }) : repo = repo ?? ChatRepoImp();

  static Future<void> show(
    BuildContext context, {
    required PostModel post,
    required String myUid,
    required String myName,
    ChatRepo? repo,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => SharePostSheet(
        post: post,
        myUid: myUid,
        myName: myName,
        repo: repo,
      ),
    );
  }

  @override
  State<SharePostSheet> createState() => _SharePostSheetState();
}

class _SharePostSheetState extends State<SharePostSheet> {
  bool _isSharing = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
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
              child: Row(
                children: [
                  Text('Share Post', style: AppTextStyles.headline3),
                  const Spacer(),
                  if (_isSharing)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    ),
                ],
              ),
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
                        child:
                            CircularProgressIndicator(color: AppColors.primary),
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
                      final peerPhoto =
                          conv.otherParticipantPhoto(widget.myUid);

                      return ListTile(
                        leading: UserAvatar(
                          name: peerName,
                          size: 44,
                          imageUrl: peerPhoto,
                        ),
                        title: Text(peerName, style: AppTextStyles.body1),
                        subtitle: conv.lastMessage.isNotEmpty
                            ? Text(
                                conv.lastMessage,
                                style: AppTextStyles.caption,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              )
                            : null,
                        trailing: const Icon(
                          Icons.send_rounded,
                          size: 20,
                          color: AppColors.primary,
                        ),
                        onTap:
                            _isSharing ? null : () => _share(context, conv.id),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Future<void> _share(BuildContext context, String conversationId) async {
    setState(() => _isSharing = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await widget.repo.sharePost(
        conversationId: conversationId,
        post: widget.post,
        myUid: widget.myUid,
        myName: widget.myName,
      );
      if (context.mounted) {
        Navigator.pop(context);
        messenger.showSnackBar(
          SnackBar(
            content: const Text('Post shared successfully.'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: const Text('Failed to share post.'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }
}
