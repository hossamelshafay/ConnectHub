import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:connecthub/core/utils/app_theme.dart';
import 'package:connecthub/core/utils/app_widgets.dart';
import 'package:connecthub/features/chat/data/models/message_model.dart';
import 'package:connecthub/features/chat/data/repos/chat_repo_imp.dart';
import 'package:connecthub/features/chat/presentation/manager/cubit/chat_cubit.dart';
import 'package:connecthub/features/chat/presentation/manager/cubit/chat_state.dart';
import 'package:connecthub/features/chat/presentation/widgets/chat_input_bar.dart';
import 'package:connecthub/features/chat/presentation/widgets/forward_message_sheet.dart';
import 'package:connecthub/features/chat/presentation/widgets/message_bubble.dart';
import 'package:connecthub/features/chat/presentation/widgets/reply_preview_bar.dart';
import 'package:connecthub/features/chat/presentation/widgets/edit_preview_bar.dart';
import 'package:connecthub/features/chat/presentation/widgets/delete_message_dialog.dart';
import 'package:connecthub/features/chat/presentation/widgets/delete_conversation_dialog.dart';
import 'package:connecthub/features/chat/presentation/widgets/typing_indicator.dart';
import 'package:connecthub/core/utils/profile_navigation_helper.dart';

/// The main chat screen for a single conversation.
class ChatView extends StatefulWidget {
  final String conversationId;
  final String peerId;
  final String peerName;
  final String? peerPhoto;

  const ChatView({
    super.key,
    required this.conversationId,
    required this.peerId,
    required this.peerName,
    this.peerPhoto,
  });

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> with WidgetsBindingObserver {
  late final ChatCubit _cubit;
  final _inputController = TextEditingController();
  final _inputFocusNode = FocusNode();
  final _scrollController = ScrollController();
  final _messageKeys = <String, GlobalKey>{};

  MessageModel? _replyTarget;
  MessageModel? _editingMessage;
  bool _isNearBottom = true;

  String get _myUid => FirebaseAuth.instance.currentUser?.uid ?? '';
  String get _myName {
    final user = FirebaseAuth.instance.currentUser;
    final name = (user?.displayName ?? '').trim();
    return name.isNotEmpty ? name : user?.email?.split('@').first ?? 'User';
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _cubit = ChatCubit(repo: ChatRepoImp());
    _cubit.onMessageSent = _scrollToBottom;
    _cubit.loadChat(
      conversationId: widget.conversationId,
      myUid: _myUid,
      receiverId: widget.peerId,
      myName: _myName,
    );

    _scrollController.addListener(_onScroll);

    // Set presence online
    ChatRepoImp().setPresence(_myUid, true);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        ChatRepoImp().setPresence(_myUid, true);
        _cubit.markRead();
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        ChatRepoImp().setPresence(_myUid, false);
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    ChatRepoImp().setPresence(_myUid, false);
    _cubit.close();
    _inputController.dispose();
    _inputFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    _isNearBottom =
        pos.pixels >= pos.maxScrollExtent - 120;
  }

  void _scrollToBottom({bool animated = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        if (animated) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        } else {
          _scrollController.jumpTo(
              _scrollController.position.maxScrollExtent);
        }
      }
    });
  }

  void _scrollToMessage(String messageId) {
    final key = _messageKeys[messageId];
    if (key?.currentContext != null) {
      Scrollable.ensureVisible(
        key!.currentContext!,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        alignment: 0.5,
      );
    }
  }

  void _startEdit(MessageModel message) {
    setState(() {
      _replyTarget = null;
      _editingMessage = message;
      _inputController.text = message.text;
      _inputController.selection = TextSelection.fromPosition(
        TextPosition(offset: _inputController.text.length),
      );
    });
    _inputFocusNode.requestFocus();
  }

  void _cancelEdit() {
    setState(() {
      _editingMessage = null;
      _inputController.clear();
    });
  }

  Future<void> _confirmDeleteMessage(MessageModel message) async {
    final isSender = message.senderId == _myUid;
    final action = await showDialog<DeleteMessageAction>(
      context: context,
      builder: (_) => DeleteMessageDialog(isSender: isSender),
    );
    if (action == null || !mounted) return;

    try {
      if (action == DeleteMessageAction.deleteForEveryone) {
        await _cubit.deleteMessageForEveryone(message.id);
      } else {
        await _cubit.deleteMessageForMe(message.id);
      }
      if (_editingMessage?.id == message.id) {
        _cancelEdit();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_friendlyError(e)),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _confirmDeleteConversation() async {
    final action = await showDialog<DeleteConversationAction>(
      context: context,
      builder: (_) => DeleteConversationDialog(peerName: widget.peerName),
    );
    if (action == null || !mounted) return;

    try {
      if (action == DeleteConversationAction.deleteForEveryone) {
        await _cubit.deleteConversationForEveryone();
      } else {
        await _cubit.deleteConversationForMe();
      }
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete chat: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _send() async {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;

    if (_editingMessage != null) {
      final editing = _editingMessage!;
      final originalText = editing.text.trim();

      if (text == originalText) {
        _cancelEdit();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('No changes were made.'),
            backgroundColor: AppColors.textSecondary,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        return;
      }

      _cancelEdit();
      try {
        await _cubit.editMessage(editing.id, text);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_friendlyError(e)),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
      return;
    }

    final reply = _replyTarget;
    setState(() => _replyTarget = null);
    _inputController.clear();
    setState(() {});
    try {
      await _cubit.sendMessage(
        text: text,
        replyToId: reply?.id,
        replyToText: reply?.text,
        replyToSenderName: reply?.senderName,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_friendlyError(e)),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  String _friendlyError(Object e) {
    final msg = e.toString();
    if (msg.contains('permission-denied')) {
      return 'You don\'t have permission to send messages here.';
    }
    if (msg.contains('unavailable') || msg.contains('network')) {
      return 'No internet connection.';
    }
    return 'Failed to send message.';
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ChatCubit>.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          leadingWidth: 40,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded),
            onPressed: () => Navigator.pop(context),
            padding: EdgeInsets.zero,
          ),
          title: _AppBarTitle(
            peerId: widget.peerId,
            peerName: widget.peerName,
            peerPhoto: widget.peerPhoto,
            presenceStream: _cubit.presenceStream(widget.peerId),
          ),
          actions: [
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert_rounded),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              onSelected: (val) {
                if (val == 'delete') {
                  _confirmDeleteConversation();
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
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        body: Column(
          children: [
            // Messages
            Expanded(
              child: BlocConsumer<ChatCubit, ChatState>(
                listener: (context, state) {
                  if (state is ChatLoaded && _isNearBottom) {
                    _scrollToBottom();
                  }
                },
                builder: (context, state) {
                  if (state is ChatLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.primary),
                    );
                  }

                  if (state is ChatError) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error_outline,
                              size: 48, color: AppColors.textHint),
                          const SizedBox(height: 12),
                          Text(state.message,
                              style: AppTextStyles.body2,
                              textAlign: TextAlign.center),
                        ],
                      ),
                    );
                  }

                  if (state is ChatLoaded) {
                    return _MessageList(
                      messages: state.messages,
                      myUid: _myUid,
                      peerId: widget.peerId,
                      peerName: widget.peerName,
                      peerPhoto: widget.peerPhoto,
                      scrollController: _scrollController,
                      messageKeys: _messageKeys,
                      conversationId: widget.conversationId,
                      cubit: _cubit,
                      onReply: (msg) => setState(() => _replyTarget = msg),
                      onEdit: _startEdit,
                      onDelete: _confirmDeleteMessage,
                      onScrollToMessage: _scrollToMessage,
                      myName: _myName,
                      myUid2: _myUid,
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),

            // Preview bar (editing or replying)
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _editingMessage != null
                  ? EditPreviewBar(
                      key: const ValueKey('edit_preview'),
                      originalText: _editingMessage!.text,
                      onCancel: _cancelEdit,
                    )
                  : (_replyTarget != null
                      ? ReplyPreviewBar(
                          key: const ValueKey('reply_preview'),
                          senderName: _replyTarget!.senderId == _myUid
                              ? 'yourself'
                              : widget.peerName,
                          messageText: _replyTarget!.text,
                          onCancel: () => setState(() => _replyTarget = null),
                        )
                      : const SizedBox.shrink(key: ValueKey('no_preview'))),
            ),

            // Input bar
            BlocBuilder<ChatCubit, ChatState>(
              builder: (context, state) {
                final isSending =
                    state is ChatLoaded ? state.isSending : false;
                return ChatInputBar(
                  controller: _inputController,
                  focusNode: _inputFocusNode,
                  isSending: isSending,
                  onSend: _send,
                  onChanged: (text) {
                    _cubit.onTypingChanged(text.isNotEmpty);
                    setState(() {});
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// App bar title with presence
// ─────────────────────────────────────────────────────────────────────────────

class _AppBarTitle extends StatelessWidget {
  final String peerId;
  final String peerName;
  final String? peerPhoto;
  final Stream<Map<String, dynamic>> presenceStream;

  const _AppBarTitle({
    required this.peerId,
    required this.peerName,
    this.peerPhoto,
    required this.presenceStream,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => ProfileNavigationHelper.openUserProfile(
        context,
        userId: peerId,
        userName: peerName,
      ),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Row(
          children: [
            UserAvatar(name: peerName, size: 38, imageUrl: peerPhoto),
            const SizedBox(width: 10),
            Expanded(
              child: StreamBuilder<Map<String, dynamic>>(
                stream: presenceStream,
                builder: (context, snap) {
                  final data = snap.data ?? {};
                  final isOnline = data['isOnline'] as bool? ?? false;
                  final lastSeenTs = data['lastSeen'];
                  String subtitle;
                  if (isOnline) {
                    subtitle = 'Online';
                  } else if (lastSeenTs != null) {
                    final dt = lastSeenTs is Timestamp
                        ? lastSeenTs.toDate()
                        : DateTime.now();
                    subtitle = 'Last seen ${_formatLastSeen(dt)}';
                  } else {
                    subtitle = '';
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        peerName,
                        style: AppTextStyles.body1.copyWith(
                            fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (subtitle.isNotEmpty)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isOnline)
                              Container(
                                width: 7,
                                height: 7,
                                margin: const EdgeInsets.only(right: 4),
                                decoration: const BoxDecoration(
                                  color: AppColors.success,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            Text(
                              subtitle,
                              style: AppTextStyles.caption.copyWith(
                                color: isOnline
                                    ? AppColors.success
                                    : AppColors.textHint,
                              ),
                            ),
                          ],
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatLastSeen(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return DateFormat('MMM d').format(dt);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Messages list
// ─────────────────────────────────────────────────────────────────────────────

class _MessageList extends StatelessWidget {
  final List<MessageModel> messages;
  final String myUid;
  final String myUid2;
  final String peerId;
  final String peerName;
  final String? peerPhoto;
  final String myName;
  final ScrollController scrollController;
  final Map<String, GlobalKey> messageKeys;
  final String conversationId;
  final ChatCubit cubit;
  final void Function(MessageModel) onReply;
  final void Function(MessageModel) onEdit;
  final void Function(MessageModel) onDelete;
  final void Function(String messageId) onScrollToMessage;

  const _MessageList({
    required this.messages,
    required this.myUid,
    required this.myUid2,
    required this.peerId,
    required this.peerName,
    required this.peerPhoto,
    required this.myName,
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
        myUid: myUid2,
        myName: myName,
      ),
    );
  }
}
