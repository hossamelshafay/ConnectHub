import 'package:connecthub/features/chatbot/data/models/chat_message.dart';

abstract class ChatbotState {}

class ChatbotInitial extends ChatbotState {}

class ChatbotLoaded extends ChatbotState {
  final List<ChatMessage> messages;
  final bool isTyping;

  ChatbotLoaded({
    required this.messages,
    this.isTyping = false,
  });
}
