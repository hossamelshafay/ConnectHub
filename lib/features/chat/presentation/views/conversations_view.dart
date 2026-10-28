import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connecthub/core/utils/app_theme.dart';
import 'package:connecthub/core/utils/app_widgets.dart';
import 'package:connecthub/features/chat/data/models/conversation_model.dart';
import 'package:connecthub/features/chat/presentation/manager/cubit/conversations_cubit.dart';
import 'package:connecthub/features/chat/presentation/manager/cubit/conversations_state.dart';
import 'package:connecthub/features/chat/presentation/views/chat_view.dart';
import 'package:connecthub/features/chat/presentation/views/chat_user_picker_view.dart';
import 'package:connecthub/features/chat/presentation/widgets/chat_ai_assistant_tile.dart';
import 'package:connecthub/features/chat/presentation/widgets/conversation_tile.dart';
import 'package:connecthub/features/chat/presentation/widgets/conversations_loading_shimmer.dart';
import 'package:connecthub/features/chat/presentation/widgets/conversations_search_bar.dart';
import 'package:connecthub/features/chat/presentation/widgets/delete_conversation_dialog.dart';
import 'package:connecthub/features/chatbot/presentation/views/chatbot_entry_view.dart';

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
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Navigator.canPop(context)
            ? Center(
                child: AppIconButton(
                  icon: Icons.arrow_back_ios_new,
                  size: 18,
                  onPressed: () => Navigator.pop(context),
                ),
              )
            : null,
        title: Text('Messages', style: AppTextStyles.headline3),
        centerTitle: true,
        actions: [
          AppIconButton(
            icon: _showSearch ? Icons.close_rounded : Icons.search_rounded,
            size: 20,
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
          const SizedBox(width: 8),
          AppIconButton(
            icon: Icons.edit_outlined,
            size: 20,
            onPressed: () => _startNewChat(context),
          ),
          const SizedBox(width: 14),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Animated search bar
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _showSearch
                  ? ConversationsSearchBar(
                      key: const ValueKey('search_bar'),
                      controller: _searchController,
                      onChanged: (q) => context.read<ConversationsCubit>().search(q),
                    )
                  : const SizedBox.shrink(key: ValueKey('no_search_bar')),
            ),

            // Main List
            Expanded(
              child: BlocBuilder<ConversationsCubit, ConversationsState>(
                builder: (context, state) {
                  if (state is ConversationsLoading) {
                    return const ConversationsLoadingShimmer();
                  }

                  if (state is ConversationsError) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.error_outline_rounded,
                              size: 48, color: AppColors.textHint),
                          const SizedBox(height: 12),
                          Text(state.message, style: AppTextStyles.body2),
                          const SizedBox(height: 16),
                          SecondaryButton(
                            text: 'Retry',
                            width: 120,
                            onPressed: () {
                              final uid = FirebaseAuth.instance.currentUser?.uid;
                              if (uid != null) {
                                context.read<ConversationsCubit>().listenToConversations(uid);
                              }
                            },
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is ConversationsLoaded) {
                    final myUid = FirebaseAuth.instance.currentUser?.uid ?? '';
                    final list = state.filtered;

                    return ListView(
                      padding: const EdgeInsets.only(bottom: 24),
                      children: [
                        // Pinned AI Assistant tile
                        if (state.query.isEmpty) ...[
                          ChatAiAssistantTile(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ChatbotEntryView(),
                                ),
                              );
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: Divider(color: AppColors.divider),
                          ),
                        ],

                        if (list.isEmpty && state.query.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.all(32),
                            child: Center(
                              child: Text(
                                'No conversations matching "${state.query}"',
                                style: AppTextStyles.body2,
                              ),
                            ),
                          )
                        else if (list.isEmpty)
                          Padding(
                            padding: const EdgeInsets.all(32),
                            child: Center(
                              child: EmptyStateWidget(
                                icon: Icons.chat_bubble_outline_rounded,
                                title: 'No messages yet',
                                subtitle:
                                    'Connect and direct message your friends and peers.',
                                actionText: 'Start a Chat',
                                onAction: () => _startNewChat(context),
                              ),
                            ),
                          )
                        else
                          ...list.map((conv) => ConversationTile(
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
                              )),
                      ],
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
          backgroundColor: AppColors.surfaceVariant,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppColors.error, width: 1),
          ),
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
      MaterialPageRoute(builder: (_) => const ChatUserPickerView()),
    );
  }
}
