import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connecthub/core/utils/app_theme.dart';
import 'package:connecthub/core/utils/app_widgets.dart';
import 'package:connecthub/features/chat/data/repos/chat_repo_imp.dart';
import 'package:connecthub/features/chat/presentation/manager/cubit/conversations_cubit.dart';
import 'package:connecthub/features/chat/presentation/manager/cubit/conversations_state.dart';
import 'package:connecthub/features/chat/presentation/views/chat_view.dart';
import 'package:connecthub/features/chat/presentation/widgets/conversation_tile.dart';
import 'package:connecthub/features/chat/presentation/widgets/delete_conversation_dialog.dart';
import 'package:connecthub/features/chat/data/models/conversation_model.dart';

/// Displays all conversations for the current user with real-time updates.
/// Includes an in-memory search bar filtering by peer display name.
class ConversationsView extends StatefulWidget {
  const ConversationsView({super.key});

  @override
  State<ConversationsView> createState() => _ConversationsViewState();
}

class _ConversationsViewState extends State<ConversationsView> {
  final _searchController = TextEditingController();
  bool _showSearch = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 0),
              child: Row(
                children: [
                  Text('Messages', style: AppTextStyles.headline2),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      _showSearch ? Icons.close_rounded : Icons.search_rounded,
                      color: AppColors.textPrimary,
                    ),
                    onPressed: () {
                      setState(() {
                        _showSearch = !_showSearch;
                        if (!_showSearch) {
                          _searchController.clear();
                          context.read<ConversationsCubit>().clearSearch();
                        }
                      });
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_rounded,
                        color: AppColors.textPrimary),
                    tooltip: 'New message',
                    onPressed: () => _startNewChat(context),
                  ),
                ],
              ),
            ),

            // Animated search bar
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _showSearch
                  ? Padding(
                      key: const ValueKey('search_bar'),
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: TextField(
                          controller: _searchController,
                          autofocus: true,
                          style: AppTextStyles.body1,
                          decoration: InputDecoration(
                            hintText: 'Search conversations…',
                            hintStyle: AppTextStyles.body2
                                .copyWith(color: AppColors.textHint),
                            prefixIcon: const Icon(Icons.search_rounded,
                                color: AppColors.textHint, size: 22),
                            filled: false,
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                          ),
                          onChanged: (q) =>
                              context.read<ConversationsCubit>().search(q),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(key: ValueKey('no_search_bar')),
            ),

            const SizedBox(height: 8),

            // List
            Expanded(
              child: BlocBuilder<ConversationsCubit, ConversationsState>(
                builder: (context, state) {
                  if (state is ConversationsLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.primary),
                    );
                  }

                  if (state is ConversationsError) {
                    return _ErrorState(
                      message: state.message,
                      onRetry: () {
                        final uid =
                            FirebaseAuth.instance.currentUser?.uid;
                        if (uid != null) {
                          context
                              .read<ConversationsCubit>()
                              .listenToConversations(uid);
                        }
                      },
                    );
                  }

                  if (state is ConversationsLoaded) {
                    final myUid =
                        FirebaseAuth.instance.currentUser?.uid ?? '';
                    final list = state.filtered;

                    if (list.isEmpty) {
                      return state.query.isEmpty
                          ? _EmptyState(
                              onNewChat: () => _startNewChat(context))
                          : _NoResultsState(query: state.query);
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.only(bottom: 24),
                      itemCount: list.length,
                      separatorBuilder: (context, index) => const Divider(
                        color: AppColors.divider,
                        height: 1,
                        indent: 82,
                        endIndent: 16,
                      ),
                      itemBuilder: (context, index) {
                        final conv = list[index];
                        return ConversationTile(
                          conversation: conv,
                          myUid: myUid,
                          onTap: () => _openChat(
                            context,
                            conv.id,
                            conv.otherParticipantId(myUid),
                            conv.otherParticipantName(myUid),
                            conv.otherParticipantPhoto(myUid),
                          ),
                          onDelete: () =>
                              _confirmDeleteConversation(context, conv),
                          onLongPress: () =>
                              _confirmDeleteConversation(context, conv),
                        );
                      },
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDeleteConversation(
    BuildContext context,
    ConversationModel conv,
  ) async {
    final myUid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final peerName = conv.otherParticipantName(myUid);
    final action = await showDialog<DeleteConversationAction>(
      context: context,
      builder: (_) => DeleteConversationDialog(peerName: peerName),
    );
    if (action == null || !context.mounted) return;

    final cubit = context.read<ConversationsCubit>();
    final messenger = ScaffoldMessenger.of(context);

    try {
      if (action == DeleteConversationAction.deleteForEveryone) {
        await cubit.deleteConversationForEveryone(conv.id);
      } else {
        await cubit.deleteConversationForMe(conv.id);
      }
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Failed to delete chat: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _openChat(
    BuildContext context,
    String conversationId,
    String peerId,
    String peerName,
    String? peerPhoto,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatView(
          conversationId: conversationId,
          peerId: peerId,
          peerName: peerName,
          peerPhoto: peerPhoto,
        ),
      ),
    );
  }

  void _startNewChat(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const _UserPickerView()),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// User picker — search Firestore users to start a new conversation
// ─────────────────────────────────────────────────────────────────────────────

class _UserPickerView extends StatefulWidget {
  const _UserPickerView();

  @override
  State<_UserPickerView> createState() => _UserPickerViewState();
}

class _UserPickerViewState extends State<_UserPickerView> {
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
          .map((d) => {
                'id': d.id,
                ...d.data(),
              })
          .toList();
      if (mounted) setState(() => _results = results);
    } catch (_) {
      if (mounted) setState(() => _results = []);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('New Message'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextField(
                controller: _controller,
                autofocus: true,
                style: AppTextStyles.body1,
                decoration: InputDecoration(
                  hintText: 'Search people…',
                  hintStyle:
                      AppTextStyles.body2.copyWith(color: AppColors.textHint),
                  prefixIcon: const Icon(Icons.search_rounded,
                      color: AppColors.textHint, size: 22),
                  filled: false,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                ),
                onChanged: _search,
              ),
            ),
          ),
          if (_loading)
            const LinearProgressIndicator(
              color: AppColors.primary,
              minHeight: 2,
            ),
          Expanded(
            child: _results.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.person_search_rounded,
                            size: 64,
                            color:
                                AppColors.textHint.withValues(alpha: 0.4)),
                        const SizedBox(height: 16),
                        Text(
                          _controller.text.isEmpty
                              ? 'Search for a person to start chatting'
                              : 'No users found',
                          style: AppTextStyles.body2
                              .copyWith(color: AppColors.textHint),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _results.length,
                    separatorBuilder: (context, index) => const Divider(
                      color: AppColors.divider,
                      height: 1,
                      indent: 78,
                    ),
                    itemBuilder: (context, index) {
                      final user = _results[index];
                      final name = user['name'] as String? ?? 'User';
                      final photo = user['profileImage'] as String?;
                      final uid = user['id'] as String? ?? '';
                      return ListTile(
                        leading: UserAvatar(
                            name: name, size: 44, imageUrl: photo),
                        title: Text(name, style: AppTextStyles.body1),
                        onTap: _starting
                            ? null
                            : () => _openOrCreateChat(
                                context, uid, name, photo),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _openOrCreateChat(
    BuildContext context,
    String peerId,
    String peerName,
    String? peerPhoto,
  ) async {
    if (_starting || peerId.isEmpty) return;
    setState(() => _starting = true);

    final myUser = FirebaseAuth.instance.currentUser;
    if (myUser == null) {
      setState(() => _starting = false);
      return;
    }

    try {
      final repo = ChatRepoImp();
      String myName = (myUser.displayName ?? '').trim();
      if (myName.isEmpty) {
        myName = myUser.email?.split('@').first ?? 'User';
      }

      final convId = await repo.getOrCreateConversation(
        myUid: myUser.uid,
        myName: myName,
        myPhoto: myUser.photoURL,
        otherUid: peerId,
        otherName: peerName,
        otherPhoto: peerPhoto,
      );

      if (!context.mounted) return;
      Navigator.pop(context); // close picker
      Navigator.push(
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
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to open conversation.'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _starting = false);
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Supplemental states
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final VoidCallback onNewChat;
  const _EmptyState({required this.onNewChat});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.chat_bubble_outline_rounded,
              size: 72,
              color: AppColors.textHint.withValues(alpha: 0.4)),
          const SizedBox(height: 16),
          Text('No conversations yet',
              style: AppTextStyles.headline3
                  .copyWith(color: AppColors.textHint)),
          const SizedBox(height: 8),
          Text(
            'Start chatting by tapping the pencil icon above.',
            style: AppTextStyles.body2,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onNewChat,
            icon: const Icon(Icons.edit_rounded, size: 18),
            label: const Text('New Message'),
          ),
        ],
      ),
    );
  }
}

class _NoResultsState extends StatelessWidget {
  final String query;
  const _NoResultsState({required this.query});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('No results for "$query"',
          style: AppTextStyles.body2.copyWith(color: AppColors.textHint)),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline,
              size: 48, color: AppColors.textHint),
          const SizedBox(height: 12),
          Text(message,
              style: AppTextStyles.body2, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
