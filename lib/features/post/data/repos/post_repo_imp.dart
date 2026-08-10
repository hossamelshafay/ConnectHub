import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connecthub/core/services/image_bb_service.dart';
import 'package:connecthub/features/post/data/repos/post_repo.dart';

class PostRepoImp implements PostRepo {
  final CollectionReference _postsCollection =
      FirebaseFirestore.instance.collection('posts');

  @override
  Future<void> createPost({
    required String title,
    required String description,
    File? image,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('You must be logged in to create a post.');
    }

    String userName = (user.displayName ?? '').trim();
    if (userName.isEmpty) {
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (userDoc.exists && userDoc.data() != null) {
          final data = userDoc.data() as Map<String, dynamic>;
          userName = data['name'] ?? '';
        }
      } catch (_) {}
    }
    if (userName.isEmpty) {
      userName = user.email?.split('@').first ?? 'User';
    }

    String? imageUrl;

    if (image != null) {
      final bytes = await image.readAsBytes();
      final base64Image = base64Encode(bytes);
      imageUrl = await ImageBBService.uploadImage(base64Image);
      if (imageUrl == null) {
        throw Exception('Failed to upload image. Please try again.');
      }
    }

    try {
      await _postsCollection.add({
        'userId': user.uid,
        'userName': userName,
        'title': title.trim(),
        'description': description.trim(),
        'imageUrl': imageUrl,
        'likes': [],
        'likeCount': 0,
        'commentCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw Exception(
            'Firestore permission denied. Please log out and sign in again.');
      }
      throw Exception(e.message ?? 'Failed to create post.');
    }
  }

  @override
  Stream<DocumentSnapshot> getPostStream(String postId) {
    return _postsCollection.doc(postId).snapshots();
  }

  @override
  Stream<QuerySnapshot> getCommentsStream(String postId) {
    return _postsCollection
        .doc(postId)
        .collection('comments')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  @override
  Future<void> addComment(String postId, Map<String, dynamic> data) async {
    _postsCollection.doc(postId).update({
      'commentCount': FieldValue.increment(1),
    });
    await _postsCollection.doc(postId).collection('comments').add(data);
  }

  @override
  Future<void> toggleLike(String postId, String userId) async {
    final postRef = _postsCollection.doc(postId);
    final doc = await postRef.get();
    final data = doc.data() as Map<String, dynamic>;
    final likes = List<String>.from(data['likes'] ?? []);

    if (likes.contains(userId)) {
      likes.remove(userId);
    } else {
      likes.add(userId);
    }

    await postRef.update({'likes': likes, 'likeCount': likes.length});
  }

  @override
  Future<DocumentSnapshot> getUser(String userId) {
    return FirebaseFirestore.instance.collection('users').doc(userId).get();
  }
}
