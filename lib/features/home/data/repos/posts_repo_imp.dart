import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connecthub/features/home/data/models/post_model.dart';
import 'package:connecthub/features/home/data/repos/posts_repo.dart';
import 'package:connecthub/features/notification/data/models/notification_model.dart';
import 'package:connecthub/features/notification/data/repos/notification_repo_imp.dart';

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
    final postOwnerId = data['userId'] as String? ?? '';

    final wasLiked = likes.contains(userId);
    if (wasLiked) {
      likes.remove(userId);
    } else {
      likes.add(userId);
    }

    await postRef.update({'likes': likes, 'likeCount': likes.length});

    // Fire notification only when adding a like, not removing, and not self.
    if (!wasLiked && userId != postOwnerId && postOwnerId.isNotEmpty) {
      try {
        final senderDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();
        final Map<String, dynamic> senderData =
            senderDoc.data() ?? {};
        await NotificationRepoImp().createNotification(
          NotificationModel(
            id: '',
            senderId: userId,
            senderName: senderData['name'] as String? ?? 'Someone',
            senderUsername: senderData['username'] as String? ?? '',
            senderPhoto: senderData['profileImage'] as String?,
            receiverId: postOwnerId,
            type: NotificationType.like,
            postId: postId,
            createdAt: DateTime.now(),
            isRead: false,
          ),
        );
      } catch (_) {
        // Notification failure must not break the like action.
      }
    }
  }
}
