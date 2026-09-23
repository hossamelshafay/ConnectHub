import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connecthub/features/chat/data/models/conversation_model.dart';
import 'package:connecthub/features/chat/data/models/message_model.dart';
import 'package:connecthub/features/chat/data/repos/chat_repo.dart';
import 'package:connecthub/features/home/data/models/post_model.dart';

class ChatRepoImp implements ChatRepo {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _conversations =>
      _firestore.collection('conversations');

  CollectionReference _messages(String conversationId) =>
      _conversations.doc(conversationId).collection('messages');

  DocumentReference _presenceDoc(String userId) =>
      _firestore.collection('users').doc(userId).collection('presence').doc('status');

  // ── Helper: deterministic conversation ID ─────────────────────────────────

  String _conversationId(String uid1, String uid2) {
    final sorted = [uid1, uid2]..sort();
    return '${sorted[0]}_${sorted[1]}';
  }

  // ── Conversations ─────────────────────────────────────────────────────────

  @override
  Stream<List<ConversationModel>> getConversationsStream(String myUid) {
    return _conversations
        .where('participants', arrayContains: myUid)
        .snapshots()
        .map((snap) {
      final list = snap.docs
          .map(ConversationModel.fromDoc)
          .where((c) => !c.isHiddenFor(myUid))
          .toList();
      list.sort((a, b) {
        final timeA = a.lastMessageAt ?? a.createdAt;
        final timeB = b.lastMessageAt ?? b.createdAt;
        return timeB.compareTo(timeA);
      });
      return list;
    });
  }

  @override
  Future<String> getOrCreateConversation({
    required String myUid,
    required String myName,
    required String? myPhoto,
    required String otherUid,
    required String otherName,
    required String? otherPhoto,
  }) async {
    final convId = _conversationId(myUid, otherUid);
    final docRef = _conversations.doc(convId);
    final snapshot = await docRef.get();

    if (snapshot.exists) {
      return convId;
    }

    final participants = [myUid, otherUid]..sort();
    await docRef.set({
      'participants': participants,
      'participantNames': {myUid: myName, otherUid: otherName},
      'participantPhotos': {myUid: myPhoto, otherUid: otherPhoto},
      'lastMessage': '',
      'lastMessageAt': FieldValue.serverTimestamp(),
      'lastMessageSenderId': '',
      'lastMessageType': 'text',
      'unreadCount': {myUid: 0, otherUid: 0},
      'typingUsers': {myUid: false, otherUid: false},
      'createdAt': FieldValue.serverTimestamp(),
    });

    return convId;
  }

  // ── Messages ──────────────────────────────────────────────────────────────

  @override
  Stream<List<MessageModel>> getMessagesStream(
    String conversationId, {
    int limit = 30,
    String? currentUid,
  }) {
    return _messages(conversationId)
        .orderBy('sentAt', descending: false)
        .limitToLast(limit)
        .snapshots()
        .map((snap) {
      final all = snap.docs.map(MessageModel.fromDoc);
      if (currentUid != null && currentUid.isNotEmpty) {
        return all.where((m) => !m.isDeletedFor(currentUid)).toList();
      }
      return all.toList();
    });
  }

  @override
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
  }) async {
    // Repository-level security: validate conversation participation.
    final convSnap = await _conversations.doc(conversationId).get();
    if (!convSnap.exists) {
      throw Exception('Conversation not found.');
    }
    final convData = convSnap.data() as Map<String, dynamic>;
    final participants = List<String>.from(convData['participants'] ?? []);
    if (!participants.contains(senderId)) {
      throw Exception('permission-denied');
    }

    final msgRef = _messages(conversationId).doc();
    final batch = _firestore.batch();

    // Add message document.
    final msgData = <String, dynamic>{
      'senderId': senderId,
      'senderName': senderName,
      'text': text,
      'type': type,
      'sentAt': FieldValue.serverTimestamp(),
      'seenBy': [senderId],
      'isForwarded': isForwarded,
    };
    if (replyToId != null) msgData['replyToId'] = replyToId;
    if (replyToText != null) msgData['replyToText'] = replyToText;
    if (replyToSenderName != null) {
      msgData['replyToSenderName'] = replyToSenderName;
    }

    batch.set(msgRef, msgData);

    // Update conversation metadata + unread counts, and unhide for both participants.
    final preview = text.length > 100 ? '${text.substring(0, 100)}…' : text;
    batch.update(_conversations.doc(conversationId), {
      'lastMessage': preview,
      'lastMessageAt': FieldValue.serverTimestamp(),
      'lastMessageSenderId': senderId,
      'lastMessageType': type,
      'unreadCount.$receiverId': FieldValue.increment(1),
      'unreadCount.$senderId': 0,
      'hiddenFor': FieldValue.arrayRemove([receiverId, senderId]),
    });

    await batch.commit();
  }

  @override
  Future<void> markMessagesRead(String conversationId, String myUid) async {
    // Repository-level security check.
    final convSnap = await _conversations.doc(conversationId).get();
    if (!convSnap.exists) return;
    final convData = convSnap.data() as Map<String, dynamic>;
    final participants = List<String>.from(convData['participants'] ?? []);
    if (!participants.contains(myUid)) return;

    // Query messages not sent by me and not yet seen by me.
    final snap = await _messages(conversationId)
        .where('senderId', isNotEqualTo: myUid)
        .get();

    final unseenDocs = snap.docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>? ?? {};
      final seenBy = List<String>.from(data['seenBy'] ?? []);
      return !seenBy.contains(myUid);
    }).toList();

    if (unseenDocs.isEmpty) {
      // Still reset unread count in case it's out of sync.
      await _conversations.doc(conversationId).update({
        'unreadCount.$myUid': 0,
      });
      return;
    }

    final batch = _firestore.batch();
    for (final doc in unseenDocs) {
      batch.update(doc.reference, {
        'seenBy': FieldValue.arrayUnion([myUid]),
      });
    }
    batch.update(_conversations.doc(conversationId), {
      'unreadCount.$myUid': 0,
    });

    await batch.commit();
  }

  @override
  Future<void> setTyping(
      String conversationId, String myUid, bool isTyping) async {
    try {
      await _conversations.doc(conversationId).update({
        'typingUsers.$myUid': isTyping,
      });
    } catch (_) {
      // Typing is non-critical; suppress errors silently.
    }
  }

  @override
  Future<void> forwardMessage({
    required MessageModel message,
    required String targetConversationId,
    required String myUid,
    required String myName,
    required String receiverId,
  }) async {
    await sendMessage(
      conversationId: targetConversationId,
      senderId: myUid,
      senderName: myName,
      text: message.text,
      type: 'text',
      isForwarded: true,
      receiverId: receiverId,
    );
  }

  @override
  Future<void> sharePost({
    required String conversationId,
    required PostModel post,
    required String myUid,
    required String myName,
  }) async {
    final convSnap = await _conversations.doc(conversationId).get();
    if (!convSnap.exists) {
      throw Exception('Conversation not found.');
    }
    final convData = convSnap.data() as Map<String, dynamic>;
    final participants = List<String>.from(convData['participants'] ?? []);
    if (!participants.contains(myUid)) {
      throw Exception('permission-denied');
    }

    final receiverId =
        participants.firstWhere((p) => p != myUid, orElse: () => '');

    String? authorPhoto;
    if (post.userId == myUid) {
      authorPhoto = FirebaseAuth.instance.currentUser?.photoURL;
    }
    if (authorPhoto == null && post.userId.isNotEmpty) {
      try {
        final authorDoc =
            await _firestore.collection('users').doc(post.userId).get();
        if (authorDoc.exists) {
          final aData = authorDoc.data();
          authorPhoto = (aData?['profileImage'] as String?) ??
              (aData?['photoURL'] as String?);
        }
      } catch (_) {}
    }

    final sharedPostPreview = <String, dynamic>{
      'postId': post.id,
      'title': post.title,
      'description': post.description,
      'imageUrl': post.imageUrl,
      'authorId': post.userId,
      'authorName': post.userName,
      'authorPhoto': authorPhoto,
      'createdAt': Timestamp.fromDate(post.createdAt),
    };

    final msgRef = _messages(conversationId).doc();
    final batch = _firestore.batch();

    final msgData = <String, dynamic>{
      'senderId': myUid,
      'senderName': myName,
      'text': post.title.isNotEmpty ? post.title : 'Shared a post',
      'type': 'post_share',
      'sentAt': FieldValue.serverTimestamp(),
      'seenBy': [myUid],
      'isForwarded': false,
      'sharedPostId': post.id,
      'sharedPostPreview': sharedPostPreview,
    };

    batch.set(msgRef, msgData);

    final updateData = <String, dynamic>{
      'lastMessage': '📄 Shared a post',
      'lastMessageAt': FieldValue.serverTimestamp(),
      'lastMessageSenderId': myUid,
      'lastMessageType': 'post_share',
      'unreadCount.$myUid': 0,
      'hiddenFor': FieldValue.arrayRemove(
          [myUid, if (receiverId.isNotEmpty) receiverId]),
    };
    if (receiverId.isNotEmpty) {
      updateData['unreadCount.$receiverId'] = FieldValue.increment(1);
    }

    batch.update(_conversations.doc(conversationId), updateData);

    await batch.commit();
  }

  @override
  Future<void> editMessage({
    required String conversationId,
    required String messageId,
    required String senderId,
    required String newText,
  }) async {
    final trimmedNew = newText.trim();
    if (trimmedNew.isEmpty) {
      throw Exception('Message cannot be empty.');
    }

    await _firestore.runTransaction((tx) async {
      final convRef = _conversations.doc(conversationId);
      final msgRef = _messages(conversationId).doc(messageId);

      final convSnap = await tx.get(convRef);
      if (!convSnap.exists) {
        throw Exception('Conversation deleted or not found.');
      }
      final convData = convSnap.data() as Map<String, dynamic>;
      final participants = List<String>.from(convData['participants'] ?? []);
      if (!participants.contains(senderId)) {
        throw Exception('permission-denied: You are not a participant in this conversation.');
      }

      final msgSnap = await tx.get(msgRef);
      if (!msgSnap.exists) {
        throw Exception('Message deleted or not found.');
      }
      final msgData = msgSnap.data() as Map<String, dynamic>;

      if (msgData['senderId'] != senderId) {
        throw Exception('permission-denied: Only the sender can edit this message.');
      }
      if (msgData['isDeleted'] == true) {
        throw Exception('Cannot edit a deleted message.');
      }

      final oldText = (msgData['text'] as String? ?? '').trim();
      if (oldText == trimmedNew) {
        // Zero Firestore writes if identical
        return;
      }

      tx.update(msgRef, {
        'text': trimmedNew,
        'isEdited': true,
        'editedAt': FieldValue.serverTimestamp(),
      });

      final lastMsg = convData['lastMessage'] as String?;
      final lastMsgSender = convData['lastMessageSenderId'] as String?;
      final oldPreview = oldText.length > 100 ? '${oldText.substring(0, 100)}…' : oldText;
      if (lastMsgSender == senderId && (lastMsg == oldPreview || lastMsg == oldText)) {
        final newPreview = trimmedNew.length > 100 ? '${trimmedNew.substring(0, 100)}…' : trimmedNew;
        tx.update(convRef, {
          'lastMessage': newPreview,
        });
      }
    });
  }

  @override
  Future<void> deleteMessageForMe({
    required String conversationId,
    required String messageId,
    required String myUid,
  }) async {
    final convSnap = await _conversations.doc(conversationId).get();
    if (!convSnap.exists) {
      throw Exception('Conversation deleted or not found.');
    }
    final convData = convSnap.data() as Map<String, dynamic>;
    final participants = List<String>.from(convData['participants'] ?? []);
    if (!participants.contains(myUid)) {
      throw Exception('permission-denied: You are not a participant in this conversation.');
    }

    final msgRef = _messages(conversationId).doc(messageId);
    final msgSnap = await msgRef.get();
    if (!msgSnap.exists) {
      throw Exception('Message deleted or not found.');
    }

    await msgRef.update({
      'deletedFor': FieldValue.arrayUnion([myUid]),
    });
  }

  @override
  Future<void> deleteMessageForEveryone({
    required String conversationId,
    required String messageId,
    required String senderId,
  }) async {
    await _firestore.runTransaction((tx) async {
      final convRef = _conversations.doc(conversationId);
      final msgRef = _messages(conversationId).doc(messageId);

      final convSnap = await tx.get(convRef);
      if (!convSnap.exists) {
        throw Exception('Conversation deleted or not found.');
      }
      final convData = convSnap.data() as Map<String, dynamic>;
      final participants = List<String>.from(convData['participants'] ?? []);
      if (!participants.contains(senderId)) {
        throw Exception('permission-denied: You are not a participant in this conversation.');
      }

      final msgSnap = await tx.get(msgRef);
      if (!msgSnap.exists) {
        throw Exception('Message deleted or not found.');
      }
      final msgData = msgSnap.data() as Map<String, dynamic>;

      if (msgData['senderId'] != senderId) {
        throw Exception('permission-denied: Only the sender can delete for everyone.');
      }

      final oldText = (msgData['text'] as String? ?? '').trim();

      tx.update(msgRef, {
        'isDeleted': true,
        'text': '',
        'isForwarded': false,
        'replyToId': FieldValue.delete(),
        'replyToText': FieldValue.delete(),
        'replyToSenderName': FieldValue.delete(),
      });

      final lastMsg = convData['lastMessage'] as String?;
      final lastMsgSender = convData['lastMessageSenderId'] as String?;
      final oldPreview = oldText.length > 100 ? '${oldText.substring(0, 100)}…' : oldText;
      if (lastMsgSender == senderId && (lastMsg == oldPreview || lastMsg == oldText)) {
        tx.update(convRef, {
          'lastMessage': '🚫 This message was deleted',
        });
      }
    });
  }

  @override
  Future<void> deleteConversationForMe({
    required String conversationId,
    required String myUid,
  }) async {
    final convRef = _conversations.doc(conversationId);
    final convSnap = await convRef.get();
    if (!convSnap.exists) {
      return; // Already deleted
    }
    final convData = convSnap.data() as Map<String, dynamic>;
    final participants = List<String>.from(convData['participants'] ?? []);
    if (participants.isNotEmpty && !participants.contains(myUid)) {
      throw Exception('permission-denied: You are not a participant in this conversation.');
    }

    final hiddenFor = List<String>.from(convData['hiddenFor'] ?? []);
    if (!hiddenFor.contains(myUid)) {
      hiddenFor.add(myUid);
    }

    // If both participants have hidden it, delete it completely for everyone
    if (participants.isNotEmpty && hiddenFor.toSet().containsAll(participants.toSet())) {
      await deleteConversationForEveryone(
        conversationId: conversationId,
        myUid: myUid,
      );
    } else {
      await convRef.update({
        'hiddenFor': FieldValue.arrayUnion([myUid]),
      });
    }
  }

  @override
  Future<void> deleteConversationForEveryone({
    required String conversationId,
    required String myUid,
  }) async {
    final convRef = _conversations.doc(conversationId);
    final convSnap = await convRef.get();
    if (!convSnap.exists) {
      return; // Already deleted
    }
    final convData = convSnap.data() as Map<String, dynamic>;
    final participants = List<String>.from(convData['participants'] ?? []);
    if (participants.isNotEmpty && !participants.contains(myUid)) {
      throw Exception('permission-denied: You are not a participant in this conversation.');
    }

    // Delete the conversation document first so it immediately disappears for all users
    await convRef.delete();

    // Clean up subcollection messages (max 100 per batch)
    try {
      while (true) {
        final snap = await _messages(conversationId).limit(100).get();
        if (snap.docs.isEmpty) break;
        final batch = _firestore.batch();
        for (final doc in snap.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();
        if (snap.docs.length < 100) break;
      }
    } catch (_) {
      // Subcollection cleanup is best-effort once the conversation document is deleted
    }
  }

  // ── Presence ──────────────────────────────────────────────────────────────

  @override
  Stream<Map<String, dynamic>> getPresenceStream(String userId) {
    return _presenceDoc(userId).snapshots().map((snap) {
      if (!snap.exists) return <String, dynamic>{'isOnline': false};
      return snap.data() as Map<String, dynamic>? ?? {};
    });
  }

  @override
  Future<void> setPresence(String userId, bool isOnline) async {
    try {
      final data = <String, dynamic>{'isOnline': isOnline};
      if (!isOnline) {
        data['lastSeen'] = FieldValue.serverTimestamp();
      }
      await _presenceDoc(userId).set(data, SetOptions(merge: true));
    } catch (_) {
      // Presence is non-critical; suppress errors silently.
    }
  }
}
