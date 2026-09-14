import 'package:cloud_firestore/cloud_firestore.dart';

/// Supported notification types.
enum NotificationType { like, comment, follow, mention }

extension NotificationTypeX on NotificationType {
  String get value {
    switch (this) {
      case NotificationType.like:
        return 'like';
      case NotificationType.comment:
        return 'comment';
      case NotificationType.follow:
        return 'follow';
      case NotificationType.mention:
        return 'mention';
    }
  }

  static NotificationType fromString(String value) {
    switch (value) {
      case 'like':
        return NotificationType.like;
      case 'comment':
        return NotificationType.comment;
      case 'follow':
        return NotificationType.follow;
      case 'mention':
        return NotificationType.mention;
      default:
        return NotificationType.like;
    }
  }
}

class NotificationModel {
  final String id;
  final String senderId;
  final String senderName;
  final String senderUsername;
  final String? senderPhoto;
  final String receiverId;
  final NotificationType type;
  final String? postId;
  final String? commentId;
  final DateTime createdAt;
  final bool isRead;

  const NotificationModel({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.senderUsername,
    this.senderPhoto,
    required this.receiverId,
    required this.type,
    this.postId,
    this.commentId,
    required this.createdAt,
    required this.isRead,
  });

  factory NotificationModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificationModel(
      id: doc.id,
      senderId: data['senderId'] as String? ?? '',
      senderName: data['senderName'] as String? ?? 'Unknown',
      senderUsername: data['senderUsername'] as String? ?? '',
      senderPhoto: data['senderPhoto'] as String?,
      receiverId: data['receiverId'] as String? ?? '',
      type: NotificationTypeX.fromString(data['type'] as String? ?? 'like'),
      postId: data['postId'] as String?,
      commentId: data['commentId'] as String?,
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: data['isRead'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderName': senderName,
      'senderUsername': senderUsername,
      'senderPhoto': senderPhoto,
      'receiverId': receiverId,
      'type': type.value,
      'postId': postId,
      'commentId': commentId,
      'createdAt': FieldValue.serverTimestamp(),
      'isRead': isRead,
    };
  }
}
