import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connecthub/features/home/data/models/post_model.dart';
import 'package:connecthub/features/profile/data/repos/profile_repo.dart';

class ProfileRepoImp implements ProfileRepo {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CollectionReference _postsCollection = FirebaseFirestore.instance
      .collection('posts');

  @override
  User? get currentUser => _auth.currentUser;

  @override
  Stream<List<PostModel>> getUserPostsStream(String userId) {
    return _postsCollection.where('userId', isEqualTo: userId).snapshots().map((
      snapshot,
    ) {
      final posts = snapshot.docs.map((doc) => PostModel.fromDoc(doc)).toList();
      posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return posts;
    });
  }

  @override
  Stream<QuerySnapshot> getUserPostsRawStream(String userId) {
    return _postsCollection.where('userId', isEqualTo: userId).snapshots();
  }

  @override
  Stream<DocumentSnapshot> getUserStream(String userId) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .snapshots();
  }
}
