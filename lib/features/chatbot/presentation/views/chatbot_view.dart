import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connecthub/core/utils/app_theme.dart';
import 'package:connecthub/features/chatbot/presentation/manager/cubit/chatbot_cubit.dart';
import 'package:connecthub/features/chatbot/presentation/manager/cubit/chatbot_state.dart';
import 'package:connecthub/features/chatbot/presentation/widgets/chat_bubble.dart';
import 'package:connecthub/features/chatbot/presentation/widgets/chatbot_input_bar.dart';
import 'package:connecthub/features/chatbot/presentation/widgets/chatbot_landing_view.dart';
import 'package:connecthub/features/chatbot/presentation/widgets/chatbot_top_bar.dart';
import 'package:connecthub/features/chatbot/presentation/widgets/typing_indicator.dart';
import 'package:connecthub/features/chat/presentation/widgets/chat_themed_background.dart';

class ChatbotView extends StatefulWidget {
  const ChatbotView({super.key});

  @override
  State<ChatbotView> createState() => _ChatbotViewState();
}

class _ChatbotViewState extends State<ChatbotView> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      });
    }
  }

  void _sendMessage([String? prefilledText]) {
    final text = prefilledText ?? _messageController.text.trim();
    if (text.isEmpty) return;
    HapticFeedback.lightImpact();
    context.read<ChatbotCubit>().sendMessage(text);
    if (prefilledText == null) {
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: ChatThemedBackground(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const ChatbotTopBar(),
              Divider(color: AppColors.divider, height: 1),

                // Chat Messages or Flagship Landing View
                Expanded(
                  child: BlocConsumer<ChatbotCubit, ChatbotState>(
                    listener: (context, state) {
                      if (state is ChatbotLoaded) {
                        _scrollToBottom();
                      }
                    },
                    builder: (context, state) {
                      if (state is ChatbotLoaded) {
                        if (state.messages.isEmpty) {
                          return ChatbotLandingView(
                            onSelectSuggestion: _sendMessage,
                          );
                        }

                        return ListView.builder(
                          controller: _scrollController,
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          itemCount:
                              state.messages.length + (state.isTyping ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == state.messages.length &&
                                state.isTyping) {
                              return const TypingIndicator();
                            }
                            final msg = state.messages[index];
                            return ChatBubble(message: msg);
                          },
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),

                ChatbotInputBar(
                  controller: _messageController,
                  onSend: () => _sendMessage(),
                ),
              ],
            ),
          ),
        ),
      );
  }
}
