import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connecthub/features/home/data/models/post_model.dart';

abstract class ProfileRepo {
  User? get currentUser;
  Stream<List<PostModel>> getUserPostsStream(String userId);
  Stream<QuerySnapshot> getUserPostsRawStream(String userId);
}

