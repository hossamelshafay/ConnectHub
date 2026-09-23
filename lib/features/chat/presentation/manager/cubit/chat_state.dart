import 'package:connecthub/features/chat/data/models/message_model.dart';

abstract class ChatState {}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatLoaded extends ChatState {
  final List<MessageModel> messages;
  final bool isSending;

  ChatLoaded({required this.messages, this.isSending = false});

  ChatLoaded copyWith({List<MessageModel>? messages, bool? isSending}) {
    return ChatLoaded(
      messages: messages ?? this.messages,
      isSending: isSending ?? this.isSending,
    );
  }
}

class ChatError extends ChatState {
  final String message;
  ChatError(this.message);
}
