import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connecthub/features/chat/data/models/message_model.dart';
import 'package:connecthub/features/chat/data/repos/chat_repo.dart';
import 'package:connecthub/features/chat/data/repos/chat_repo_imp.dart';
import 'package:connecthub/features/chat/presentation/manager/cubit/chat_state.dart';
import 'package:connecthub/features/home/data/models/post_model.dart';

class ChatCubit extends Cubit<ChatState> {
  final ChatRepo _repo;

  StreamSubscription<List<MessageModel>>? _subscription;
  Timer? _typingTimer;
  bool _isTyping = false;

  String _conversationId = '';
  String _myUid = '';
  String _receiverId = '';
  String _myName = '';

  /// Callback invoked after a message is sent so the view can scroll to bottom.
  VoidCallback? onMessageSent;

  ChatCubit({ChatRepo? repo})
      : _repo = repo ?? ChatRepoImp(),
        super(ChatInitial());

  /// Starts listening to messages in [conversationId] and marks them as read.
  void loadChat({
    required String conversationId,
    required String myUid,
    required String receiverId,
    required String myName,
  }) {
    _conversationId = conversationId;
    _myUid = myUid;
    _receiverId = receiverId;
    _myName = myName;

    emit(ChatLoading());
    _subscription?.cancel();
    _subscription = _repo
        .getMessagesStream(conversationId, limit: 30, currentUid: myUid)
        .listen(
          (messages) {
            final isSending = state is ChatLoaded
                ? (state as ChatLoaded).isSending
                : false;
            emit(ChatLoaded(messages: messages, isSending: isSending));
          },
          onError: (Object e) {
            emit(ChatError(_friendlyError(e)));
          },
        );

    // Mark unread messages as read on open.
    _markRead();
  }

  /// Marks all unread messages as read. Called on open and on resume.
  Future<void> markRead() => _markRead();

  Future<void> _markRead() async {
    if (_conversationId.isEmpty || _myUid.isEmpty) return;
    try {
      await _repo.markMessagesRead(_conversationId, _myUid);
    } catch (_) {
      // Non-critical; suppress.
    }
  }

  /// Sends a new text message.
  Future<void> sendMessage({
    required String text,
    String? replyToId,
    String? replyToText,
    String? replyToSenderName,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final current = state;
    if (current is ChatLoaded) {
      emit(current.copyWith(isSending: true));
    }

    // Clear typing immediately on send.
    _clearTyping();

    try {
      await _repo.sendMessage(
        conversationId: _conversationId,
        senderId: _myUid,
        senderName: _myName,
        text: trimmed,
        replyToId: replyToId,
        replyToText: replyToText,
        replyToSenderName: replyToSenderName,
        receiverId: _receiverId,
      );
      onMessageSent?.call();
    } catch (e) {
      final current2 = state;
      if (current2 is ChatLoaded) {
        emit(current2.copyWith(isSending: false));
      }
      rethrow;
    }

    final current3 = state;
    if (current3 is ChatLoaded) {
      emit(current3.copyWith(isSending: false));
    }
  }

  /// Forwards [message] to [targetConversationId].
  Future<void> forwardMessage({
    required MessageModel message,
    required String targetConversationId,
    required String receiverId,
  }) async {
    await _repo.forwardMessage(
      message: message,
      targetConversationId: targetConversationId,
      myUid: _myUid,
      myName: _myName,
      receiverId: receiverId,
    );
  }

  /// Shares [post] to [targetConversationId].
  Future<void> sharePost({
    required PostModel post,
    required String targetConversationId,
  }) async {
    await _repo.sharePost(
      conversationId: targetConversationId,
      post: post,
      myUid: currentUid,
      myName: _myName,
    );
  }

  /// Edits an existing message.
  Future<void> editMessage(String messageId, String newText) async {
    await _repo.editMessage(
      conversationId: _conversationId,
      messageId: messageId,
      senderId: _myUid,
      newText: newText,
    );
  }

  /// Current user ID with fallback to FirebaseAuth.
  String get currentUid {
    if (_myUid.isNotEmpty) return _myUid;
    return FirebaseAuth.instance.currentUser?.uid ?? '';
  }

  /// Deletes a message only for the current user.
  Future<void> deleteMessageForMe(String messageId) async {
    final uid = currentUid;
    if (uid.isEmpty) throw Exception('User not authenticated.');
    await _repo.deleteMessageForMe(
      conversationId: _conversationId,
      messageId: messageId,
      myUid: uid,
    );
  }

  /// Deletes a message for everyone (soft delete).
  Future<void> deleteMessageForEveryone(String messageId) async {
    final uid = currentUid;
    if (uid.isEmpty) throw Exception('User not authenticated.');
    await _repo.deleteMessageForEveryone(
      conversationId: _conversationId,
      messageId: messageId,
      senderId: uid,
    );
  }

  /// Deletes a conversation for the current user.
  Future<void> deleteConversationForMe() async {
    final uid = currentUid;
    if (uid.isEmpty) throw Exception('User not authenticated.');
    await _repo.deleteConversationForMe(
      conversationId: _conversationId,
      myUid: uid,
    );
  }

  /// Deletes a conversation and its messages for everyone.
  Future<void> deleteConversationForEveryone() async {
    final uid = currentUid;
    if (uid.isEmpty) throw Exception('User not authenticated.');
    await _repo.deleteConversationForEveryone(
      conversationId: _conversationId,
      myUid: uid,
    );
  }

  /// Called when the user is typing. Debounces the Firestore write to avoid
  /// spamming: sets typing=true immediately, then typing=false after 3 s of
  /// silence.
  void onTypingChanged(bool isTyping) {
    if (_conversationId.isEmpty || _myUid.isEmpty) return;

    if (isTyping && !_isTyping) {
      _isTyping = true;
      _repo.setTyping(_conversationId, _myUid, true);
    }

    if (isTyping) {
      _typingTimer?.cancel();
      _typingTimer = Timer(const Duration(seconds: 3), _clearTyping);
    } else {
      _clearTyping();
    }
  }

  void _clearTyping() {
    _typingTimer?.cancel();
    if (_isTyping) {
      _isTyping = false;
      _repo.setTyping(_conversationId, _myUid, false);
    }
  }

  /// Real-time presence stream for [userId].
  Stream<Map<String, dynamic>> presenceStream(String userId) =>
      _repo.getPresenceStream(userId);

  String _friendlyError(Object e) {
    final msg = e.toString();
    if (msg.contains('permission-denied')) {
      return 'You don\'t have permission to view this conversation.';
    }
    if (msg.contains('unavailable') || msg.contains('network')) {
      return 'No internet connection. Check your network.';
    }
    if (msg.contains('not-found') || msg.contains('not found')) {
      return 'This conversation no longer exists.';
    }
    return 'Failed to load messages.';
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    _typingTimer?.cancel();
    if (_isTyping && _conversationId.isNotEmpty) {
      _repo.setTyping(_conversationId, _myUid, false);
    }
    return super.close();
  }
}

/// Typedef matching Flutter's VoidCallback for convenience.
typedef VoidCallback = void Function();
