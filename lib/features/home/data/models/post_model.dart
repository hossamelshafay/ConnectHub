import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String id;
  final String userId;
  final String userName;
  final String title;
  final String description;
  final String? imageUrl;
  final String? deleteHash;
  final List<String> likes;
  final int likeCount;
  final int commentCount;
  final DateTime createdAt;
  final DateTime? lastEditedAt;

  PostModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.title,
    required this.description,
    this.imageUrl,
    this.deleteHash,
    required this.likes,
    required this.likeCount,
    required this.commentCount,
    required this.createdAt,
    this.lastEditedAt,
  });

  factory PostModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return PostModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? 'Unknown',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'],
      deleteHash: data['deleteHash'],
      likes: List<String>.from(data['likes'] ?? []),
      likeCount: data['likeCount'] ?? 0,
      commentCount: data['commentCount'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastEditedAt: (data['lastEditedAt'] as Timestamp?)?.toDate(),
    );
  }
}

