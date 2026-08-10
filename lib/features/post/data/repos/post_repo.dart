import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class PostRepo {
  Future<void> createPost({
    required String title,
    required String description,
    File? image,
  });

  Stream<DocumentSnapshot> getPostStream(String postId);
  Stream<QuerySnapshot> getCommentsStream(String postId);
  Future<void> addComment(String postId, Map<String, dynamic> data);
  Future<void> toggleLike(String postId, String userId);
  Future<DocumentSnapshot> getUser(String userId);
}

