import 'package:connecthub/features/chat/data/models/conversation_model.dart';
import 'package:connecthub/features/chat/data/models/message_model.dart';
import 'package:connecthub/features/home/data/models/post_model.dart';

abstract class ChatRepo {
  // ── Conversations ────────────────────────────────────────────────────────────

  /// Real-time stream of all conversations for [myUid].
  Stream<List<ConversationModel>> getConversationsStream(String myUid);

  /// Returns the existing conversation ID, or creates a new conversation
  /// and returns its ID. Never creates duplicates.
  Future<String> getOrCreateConversation({
    required String myUid,
    required String myName,
    required String? myPhoto,
    required String otherUid,
    required String otherName,
    required String? otherPhoto,
  });

  // ── Messages ─────────────────────────────────────────────────────────────────

  /// Real-time stream of the most recent [limit] messages, ascending by sentAt.
  /// If [currentUid] is provided, messages hidden for that user are filtered out.
  Stream<List<MessageModel>> getMessagesStream(
    String conversationId, {
    int limit = 30,
    String? currentUid,
  });

  /// Sends a new message to [conversationId].
  Future<void> sendMessage({
    required String conversationId,
    required String senderId,
    required String senderName,
    required String text,
    String type = 'text',
    String? replyToId,
    String? replyToText,
    String? replyToSenderName,
    bool isForwarded = false,
    required String receiverId,
  });

  /// Edits an existing message sent by [senderId].
  Future<void> editMessage({
    required String conversationId,
    required String messageId,
    required String senderId,
    required String newText,
  });

  /// Hides a message only for [myUid] by adding [myUid] to [deletedFor].
  Future<void> deleteMessageForMe({
    required String conversationId,
    required String messageId,
    required String myUid,
  });

  /// Soft-deletes a message for everyone if [senderId] is the author.
  Future<void> deleteMessageForEveryone({
    required String conversationId,
    required String messageId,
    required String senderId,
  });

  /// Hides a conversation only for [myUid] by adding [myUid] to [hiddenFor].
  Future<void> deleteConversationForMe({
    required String conversationId,
    required String myUid,
  });

  /// Deletes a conversation and all its messages for both participants.
  Future<void> deleteConversationForEveryone({
    required String conversationId,
    required String myUid,
  });

  /// Marks all messages in [conversationId] that were not sent by [myUid]
  /// and are not yet seen by [myUid] as seen. Resets unread count to 0.
  Future<void> markMessagesRead(String conversationId, String myUid);

  /// Sets or clears the typing indicator for [myUid] in [conversationId].
  Future<void> setTyping(String conversationId, String myUid, bool isTyping);

  /// Forwards [message] to [targetConversationId] as [myUid].
  Future<void> forwardMessage({
    required MessageModel message,
    required String targetConversationId,
    required String myUid,
    required String myName,
    required String receiverId,
  });

  /// Shares [post] to [conversationId] as a rich preview message.
  Future<void> sharePost({
    required String conversationId,
    required PostModel post,
    required String myUid,
    required String myName,
  });

  // ── Presence ─────────────────────────────────────────────────────────────────

  /// Real-time stream of the presence document for [userId].
  /// Returns a map with keys: isOnline (bool), lastSeen (Timestamp?).
  Stream<Map<String, dynamic>> getPresenceStream(String userId);

  /// Sets the current user's online/offline status.
  Future<void> setPresence(String userId, bool isOnline);
}
