import 'package:cloud_firestore/cloud_firestore.dart';

/// Supported message content types.
/// Only 'text' is implemented in Phase 1 & 2.
/// Other values are reserved for future phases.
enum MessageType {
  text,
  image,
  audio,
  postShare,
  profileShare,
  location,
  ai;

  String get value {
    switch (this) {
      case MessageType.text:
        return 'text';
      case MessageType.image:
        return 'image';
      case MessageType.audio:
        return 'audio';
      case MessageType.postShare:
        return 'post_share';
      case MessageType.profileShare:
        return 'profile_share';
      case MessageType.location:
        return 'location';
      case MessageType.ai:
        return 'ai';
    }
  }

  static MessageType fromString(String value) {
    switch (value) {
      case 'image':
        return MessageType.image;
      case 'audio':
        return MessageType.audio;
      case 'post_share':
        return MessageType.postShare;
      case 'profile_share':
        return MessageType.profileShare;
      case 'location':
        return MessageType.location;
      case 'ai':
        return MessageType.ai;
      default:
        return MessageType.text;
    }
  }
}

class MessageModel {
  final String id;
  final String senderId;
  final String senderName;
  final String text;
  final MessageType type;
  final DateTime sentAt;
  final List<String> seenBy;
  final String? replyToId;
  final String? replyToText;
  final String? replyToSenderName;
  final bool isForwarded;
  final bool isEdited;
  final DateTime? editedAt;
  final bool isDeleted;
  final List<String> deletedFor;

  // ── Post sharing ────────────────────────────────────────────────────────────
  final String? sharedPostId;
  final Map<String, dynamic>? sharedPostPreview;

  const MessageModel({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.type,
    required this.sentAt,
    required this.seenBy,
    this.replyToId,
    this.replyToText,
    this.replyToSenderName,
    required this.isForwarded,
    this.isEdited = false,
    this.editedAt,
    this.isDeleted = false,
    this.deletedFor = const [],
    this.sharedPostId,
    this.sharedPostPreview,
  });

  bool isDeletedFor(String uid) => deletedFor.contains(uid);

  factory MessageModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return MessageModel(
      id: doc.id,
      senderId: data['senderId'] as String? ?? '',
      senderName: data['senderName'] as String? ?? 'User',
      text: data['text'] as String? ?? '',
      type: MessageType.fromString(data['type'] as String? ?? 'text'),
      sentAt: (data['sentAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      seenBy: List<String>.from(data['seenBy'] ?? []),
      replyToId: data['replyToId'] as String?,
      replyToText: data['replyToText'] as String?,
      replyToSenderName: data['replyToSenderName'] as String?,
      isForwarded: data['isForwarded'] as bool? ?? false,
      isEdited: data['isEdited'] as bool? ?? false,
      editedAt: (data['editedAt'] as Timestamp?)?.toDate(),
      isDeleted: data['isDeleted'] as bool? ?? false,
      deletedFor: List<String>.from(data['deletedFor'] ?? []),
      sharedPostId: data['sharedPostId'] as String?,
      sharedPostPreview: data['sharedPostPreview'] != null
          ? Map<String, dynamic>.from(data['sharedPostPreview'] as Map)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'senderId': senderId,
      'senderName': senderName,
      'text': text,
      'type': type.value,
      'sentAt': FieldValue.serverTimestamp(),
      'seenBy': seenBy,
      'replyToId': replyToId,
      'replyToText': replyToText,
      'replyToSenderName': replyToSenderName,
      'isForwarded': isForwarded,
      'isEdited': isEdited,
      'editedAt': editedAt != null ? Timestamp.fromDate(editedAt!) : null,
      'isDeleted': isDeleted,
      'deletedFor': deletedFor,
    };
    if (sharedPostId != null) map['sharedPostId'] = sharedPostId;
    if (sharedPostPreview != null) map['sharedPostPreview'] = sharedPostPreview;
    return map;
  }
}
