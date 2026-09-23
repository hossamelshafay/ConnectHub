import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connecthub/features/chat/data/models/conversation_model.dart';
import 'package:connecthub/features/chat/data/repos/chat_repo.dart';
import 'package:connecthub/features/chat/data/repos/chat_repo_imp.dart';
import 'package:connecthub/features/chat/presentation/manager/cubit/conversations_state.dart';

class ConversationsCubit extends Cubit<ConversationsState> {
  final ChatRepo _repo;
  StreamSubscription<List<ConversationModel>>? _subscription;
  String _myUid = '';
  String _currentQuery = '';

  ConversationsCubit({ChatRepo? repo})
      : _repo = repo ?? ChatRepoImp(),
        super(ConversationsInitial());

  /// Returns the total unread message count across all conversations.
  int get totalUnread {
    final state = this.state;
    if (state is ConversationsLoaded) {
      return state.all.fold(0, (sum, c) => sum + c.myUnreadCount(_myUid));
    }
    return 0;
  }

  /// Starts listening to conversations for [myUid].
  /// Safe to call multiple times — cancels the previous subscription first.
  void listenToConversations(String myUid) {
    _myUid = myUid;
    emit(ConversationsLoading());
    _subscription?.cancel();
    _subscription = _repo.getConversationsStream(myUid).listen(
      (conversations) {
        _emitLoaded(conversations, _currentQuery);
      },
      onError: (Object e) {
        emit(ConversationsError(_friendlyError(e)));
      },
    );
  }

  /// Filters conversations by peer display name (in-memory, no extra reads).
  void search(String query) {
    _currentQuery = query;
    final state = this.state;
    if (state is ConversationsLoaded) {
      _emitLoaded(state.all, query);
    }
  }

  /// Clears the search filter.
  void clearSearch() => search('');

  /// Current user ID with fallback to FirebaseAuth.
  String get currentUid {
    if (_myUid.isNotEmpty) return _myUid;
    return FirebaseAuth.instance.currentUser?.uid ?? '';
  }

  /// Hides a conversation for the current user.
  Future<void> deleteConversationForMe(String conversationId) async {
    final uid = currentUid;
    if (uid.isEmpty) throw Exception('User not authenticated.');
    await _repo.deleteConversationForMe(
      conversationId: conversationId,
      myUid: uid,
    );
  }

  /// Deletes a conversation and all its messages for both participants.
  Future<void> deleteConversationForEveryone(String conversationId) async {
    final uid = currentUid;
    if (uid.isEmpty) throw Exception('User not authenticated.');
    await _repo.deleteConversationForEveryone(
      conversationId: conversationId,
      myUid: uid,
    );
  }

  void _emitLoaded(List<ConversationModel> all, String query) {
    final q = query.trim().toLowerCase();
    final filtered = q.isEmpty
        ? all
        : all.where((c) {
            final name = c.otherParticipantName(_myUid).toLowerCase();
            return name.contains(q);
          }).toList();
    emit(ConversationsLoaded(all: all, filtered: filtered, query: query));
  }

  String _friendlyError(Object e) {
    final msg = e.toString();
    if (msg.contains('permission-denied')) {
      return 'You don\'t have permission to view messages.';
    }
    if (msg.contains('unavailable') || msg.contains('network')) {
      return 'No internet connection. Check your network.';
    }
    return 'Failed to load conversations.';
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
