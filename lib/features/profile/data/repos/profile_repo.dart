import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connecthub/features/home/data/models/post_model.dart';

abstract class ProfileRepo {
  User? get currentUser;
  Stream<List<PostModel>> getUserPostsStream(String userId);
  Stream<QuerySnapshot> getUserPostsRawStream(String userId);

  /// Real-time stream of the user's Firestore document (for follow counts).
  Stream<DocumentSnapshot> getUserStream(String userId);
}
