import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connecthub/features/home/data/models/post_model.dart';
import 'package:connecthub/features/home/data/repos/posts_repo.dart';

class PostsRepoImp implements PostsRepo {
  final CollectionReference _postsCollection =
      FirebaseFirestore.instance.collection('posts');

  @override
  Stream<List<PostModel>> getPostsStream() {
    return _postsCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => PostModel.fromDoc(doc)).toList());
  }

  @override
  Stream<List<PostModel>> getUserPostsStream(String userId) {
    return _postsCollection
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final posts =
          snapshot.docs.map((doc) => PostModel.fromDoc(doc)).toList();
      posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return posts;
    });
  }

  @override
  Stream<QuerySnapshot> getUserPostsRawStream(String userId) {
    return _postsCollection.where('userId', isEqualTo: userId).snapshots();
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
}
