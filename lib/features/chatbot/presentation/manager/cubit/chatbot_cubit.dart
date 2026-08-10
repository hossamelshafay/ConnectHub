import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connecthub/features/chatbot/data/models/chat_message.dart';
import 'package:connecthub/features/chatbot/data/repos/chatbot_repo.dart';
import 'package:connecthub/features/chatbot/data/repos/chatbot_repo_imp.dart';
import 'package:connecthub/features/chatbot/presentation/manager/cubit/chatbot_state.dart';

class ChatbotCubit extends Cubit<ChatbotState> {
  final ChatbotRepo _chatbotRepo;
  final List<ChatMessage> _messages = [];

  ChatbotCubit({ChatbotRepo? chatbotRepo})
      : _chatbotRepo = chatbotRepo ?? ChatbotRepoImp(),
        super(ChatbotInitial()) {
    _messages.add(ChatMessage(
      text:
          "Hi! 👋 I'm your AI post idea generator. Tell me what topic you're interested in, and I'll help you come up with engaging social media post ideas!",
      isUser: false,
    ));
    emit(ChatbotLoaded(messages: List.from(_messages)));
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    _messages.add(ChatMessage(text: text.trim(), isUser: true));
    emit(ChatbotLoaded(messages: List.from(_messages), isTyping: true));

    final response = await _chatbotRepo.sendMessage(text.trim());

    _messages.add(ChatMessage(text: response, isUser: false));
    emit(ChatbotLoaded(messages: List.from(_messages), isTyping: false));
  }
}
