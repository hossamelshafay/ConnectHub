import 'package:connecthub/core/services/ai_chat_service.dart';
import 'package:connecthub/features/chatbot/data/repos/chatbot_repo.dart';

class ChatbotRepoImp implements ChatbotRepo {
  @override
  Future<String> sendMessage(String message) async {
    return AIChatService.sendMessage(message);
  }
}
