import 'package:cloud_firestore/cloud_firestore.dart';

class ConversationModel {
  final String id;
  final List<String> participants;
  final Map<String, String> participantNames;
  final Map<String, String?> participantPhotos;
  final String lastMessage;
  final DateTime? lastMessageAt;
  final String lastMessageSenderId;
  final String lastMessageType;
  final Map<String, int> unreadCount;
  final Map<String, bool> typingUsers;
  final List<String> hiddenFor;
  final DateTime createdAt;

  const ConversationModel({
    required this.id,
    required this.participants,
    required this.participantNames,
    required this.participantPhotos,
    required this.lastMessage,
    this.lastMessageAt,
    required this.lastMessageSenderId,
    required this.lastMessageType,
    required this.unreadCount,
    required this.typingUsers,
    this.hiddenFor = const [],
    required this.createdAt,
  });

  factory ConversationModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    final rawNames = data['participantNames'] as Map<String, dynamic>? ?? {};
    final rawPhotos = data['participantPhotos'] as Map<String, dynamic>? ?? {};
    final rawUnread = data['unreadCount'] as Map<String, dynamic>? ?? {};
    final rawTyping = data['typingUsers'] as Map<String, dynamic>? ?? {};

    return ConversationModel(
      id: doc.id,
      participants: List<String>.from(data['participants'] ?? []),
      participantNames: rawNames.map((k, v) => MapEntry(k, (v as String?) ?? '')),
      participantPhotos: rawPhotos.map((k, v) => MapEntry(k, v as String?)),
      lastMessage: data['lastMessage'] as String? ?? '',
      lastMessageAt: (data['lastMessageAt'] as Timestamp?)?.toDate(),
      lastMessageSenderId: data['lastMessageSenderId'] as String? ?? '',
      lastMessageType: data['lastMessageType'] as String? ?? 'text',
      unreadCount: rawUnread.map((k, v) => MapEntry(k, (v as int?) ?? 0)),
      typingUsers: rawTyping.map((k, v) => MapEntry(k, (v as bool?) ?? false)),
      hiddenFor: List<String>.from(data['hiddenFor'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  bool isHiddenFor(String myUid) => hiddenFor.contains(myUid);

  /// Returns the peer's uid given the current user's uid.
  String otherParticipantId(String myUid) =>
      participants.firstWhere((uid) => uid != myUid, orElse: () => '');

  /// Returns the peer's display name.
  String otherParticipantName(String myUid) {
    final peerId = otherParticipantId(myUid);
    return participantNames[peerId] ?? 'User';
  }

  /// Returns the peer's photo URL (nullable).
  String? otherParticipantPhoto(String myUid) {
    final peerId = otherParticipantId(myUid);
    return participantPhotos[peerId];
  }

  /// Returns the current user's unread count.
  int myUnreadCount(String myUid) => unreadCount[myUid] ?? 0;

  /// Returns true if the peer is currently typing.
  bool isPeerTyping(String myUid) {
    final peerId = otherParticipantId(myUid);
    return typingUsers[peerId] ?? false;
  }
}
