import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connecthub/core/utils/app_theme.dart';
import 'package:connecthub/core/utils/app_widgets.dart';
import 'package:connecthub/features/chat/data/repos/chat_repo_imp.dart';
import 'package:connecthub/features/chat/presentation/views/chat_view.dart';

class ChatUserPickerView extends StatefulWidget {
  const ChatUserPickerView({super.key});

  @override
  State<ChatUserPickerView> createState() => _ChatUserPickerViewState();
}

class _ChatUserPickerViewState extends State<ChatUserPickerView> {
  final _controller = TextEditingController();
  List<Map<String, dynamic>> _results = [];
  bool _loading = false;
  bool _starting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _search(String query) async {
    final q = query.trim();
    if (q.isEmpty) {
      setState(() => _results = []);
      return;
    }
    setState(() => _loading = true);
    try {
      final myUid = FirebaseAuth.instance.currentUser?.uid ?? '';
      final snap = await FirebaseFirestore.instance
          .collection('users')
          .where('name', isGreaterThanOrEqualTo: q)
          .where('name', isLessThanOrEqualTo: '${q}z')
          .limit(20)
          .get();
      final results = snap.docs
          .where((d) => d.id != myUid)
          .map((d) => {'id': d.id, ...d.data()})
          .toList();
      if (mounted) setState(() => _results = results);
    } catch (_) {
      if (mounted) setState(() => _results = []);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _startChatWith(Map<String, dynamic> peer) async {
    final myUid = FirebaseAuth.instance.currentUser?.uid;
    if (myUid == null || _starting) return;
    setState(() => _starting = true);

    try {
      final repo = ChatRepoImp();
      final peerId = peer['id'] as String;
      final peerName = peer['name'] as String? ?? 'User';
      final peerPhoto = peer['profileImage'] as String?;

      final myDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(myUid)
          .get();
      final myName = myDoc.data()?['name'] as String? ?? 'Me';
      final myPhoto = myDoc.data()?['profileImage'] as String?;

      final convId = await repo.getOrCreateConversation(
        myUid: myUid,
        myName: myName,
        myPhoto: myPhoto,
        peerId: peerId,
        peerName: peerName,
        peerPhoto: peerPhoto,
      );

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ChatView(
            conversationId: convId,
            peerId: peerId,
            peerName: peerName,
            peerPhoto: peerPhoto,
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to start chat: $e'),
            backgroundColor: AppColors.surfaceVariant,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: AppColors.error, width: 1),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _starting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: AppIconButton(
          icon: Icons.arrow_back_ios_new,
          size: 18,
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('New Message', style: AppTextStyles.headline3),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.glass,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.glassBorder),
                ),
                child: TextField(
                  controller: _controller,
                  autofocus: true,
                  style: AppTextStyles.body1.copyWith(fontSize: 14.5),
                  decoration: InputDecoration(
                    hintText: 'Search people by name...',
                    hintStyle: AppTextStyles.body2.copyWith(
                      color: AppColors.textHint,
                    ),
                    prefixIcon: Icon(Icons.search_rounded,
                        color: AppColors.textHint, size: 20),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: false,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                  ),
                  onChanged: _search,
                ),
              ),
            ),
            Expanded(
              child: _loading
                  ? const ChatTileShimmer(itemCount: 6)
                  : _results.isEmpty
                      ? Center(
                          child: Text(
                            _controller.text.isEmpty
                                ? 'Search for people to start a chat'
                                : 'No people found',
                            style: AppTextStyles.body2,
                          ),
                        )
                      : ListView.builder(
                      itemCount: _results.length,
                      itemBuilder: (context, index) {
                        final peer = _results[index];
                        final name = peer['name'] as String? ?? 'User';
                        final photo = peer['profileImage'] as String?;
                        final username = peer['username'] as String?;
                        return ListTile(
                          leading: UserAvatar(
                            name: name,
                            imageUrl: photo,
                            size: 46,
                          ),
                          title: Text(name, style: AppTextStyles.body1),
                          subtitle: username != null && username.isNotEmpty
                              ? Text(
                                  username.startsWith('@')
                                      ? username
                                      : '@$username',
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.primary,
                                  ),
                                )
                              : null,
                          onTap: _starting ? null : () => _startChatWith(peer),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
