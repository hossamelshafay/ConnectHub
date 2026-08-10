import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connecthub/features/home/data/models/post_model.dart';

abstract class PostsRepo {
  Stream<List<PostModel>> getPostsStream();
  Stream<List<PostModel>> getUserPostsStream(String userId);
  Stream<QuerySnapshot> getUserPostsRawStream(String userId);
  Future<void> toggleLike(String postId, String userId);
}
