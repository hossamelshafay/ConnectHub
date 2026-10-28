import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connecthub/core/utils/app_theme.dart';
import 'package:connecthub/features/chat/data/repos/chat_repo_imp.dart';
import 'package:connecthub/features/chat/presentation/views/chat_view.dart';

class MessageProfileButton extends StatefulWidget {
  final String userId;
  final String userName;
  final String? userPhoto;

  const MessageProfileButton({
    super.key,
    required this.userId,
    required this.userName,
    this.userPhoto,
  });

  @override
  State<MessageProfileButton> createState() => _MessageProfileButtonState();
}

class _MessageProfileButtonState extends State<MessageProfileButton> {
  bool _loading = false;

  Future<void> _startChat() async {
    final myUid = FirebaseAuth.instance.currentUser?.uid;
    if (myUid == null || _loading) return;

    setState(() => _loading = true);
    try {
      final repo = ChatRepoImp();
      final myUser = FirebaseAuth.instance.currentUser;
      final myName = (myUser?.displayName != null &&
              myUser!.displayName!.trim().isNotEmpty)
          ? myUser.displayName!.trim()
          : (myUser?.email?.split('@').first ?? 'User');
      final myPhoto = myUser?.photoURL;

      final convId = await repo.getOrCreateConversation(
        myUid: myUid,
        myName: myName,
        myPhoto: myPhoto,
        peerId: widget.userId,
        peerName: widget.userName,
        peerPhoto: widget.userPhoto,
      );

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatView(
            conversationId: convId,
            peerId: widget.userId,
            peerName: widget.userName,
            peerPhoto: widget.userPhoto,
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to open chat: $e'),
            backgroundColor: AppColors.surfaceVariant,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: AppColors.error, width: 1),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _loading ? null : _startChat,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.glass,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: _loading
            ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.chat_bubble_outline_rounded,
                    size: 16,
                    color: AppColors.textPrimary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Message',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
