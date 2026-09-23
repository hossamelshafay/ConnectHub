import 'package:connecthub/features/chat/data/models/conversation_model.dart';

abstract class ConversationsState {}

class ConversationsInitial extends ConversationsState {}

class ConversationsLoading extends ConversationsState {}

class ConversationsLoaded extends ConversationsState {
  final List<ConversationModel> all;
  final List<ConversationModel> filtered;
  final String query;

  ConversationsLoaded({
    required this.all,
    required this.filtered,
    required this.query,
  });
}

class ConversationsError extends ConversationsState {
  final String message;
  ConversationsError(this.message);
}
