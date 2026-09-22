import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class PostRepo {
  Future<String> createPost({
    required String title,
    required String description,
    File? image,
  });

  Future<void> updatePost({
    required String postId,
    required String title,
    required String description,
    File? newImage,
    bool removeImage = false,
    String? oldDeleteHash,
    String? oldDescription,
  });

  Future<void> deletePost({
    required String postId,
    String? deleteHash,
  });

  Stream<DocumentSnapshot> getPostStream(String postId);
  Stream<QuerySnapshot> getCommentsStream(String postId);
  Future<String> addComment(String postId, Map<String, dynamic> data);

  Future<void> updateComment({
    required String postId,
    required String commentId,
    required String text,
    String? oldText,
  });

  Future<void> deleteComment({
    required String postId,
    required String commentId,
  });

  Future<void> toggleLike(String postId, String userId);
  Future<DocumentSnapshot> getUser(String userId);
}


