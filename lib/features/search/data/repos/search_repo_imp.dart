import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connecthub/features/home/data/models/post_model.dart';
import 'package:connecthub/features/search/data/repos/search_repo.dart';

class SearchRepoImp implements SearchRepo {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _users => _firestore.collection('users');
  CollectionReference get _posts => _firestore.collection('posts');

  /// Firestore prefix-match on the `name` field.
  /// Results are additionally filtered in-memory against `username`
  /// so a single query covers both fields — no composite index required.
  @override
  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return [];

    final end = normalized.substring(0, normalized.length - 1) +
        String.fromCharCode(normalized.codeUnitAt(normalized.length - 1) + 1);

    final snapshot = await _users
        .where('name', isGreaterThanOrEqualTo: normalized)
        .where('name', isLessThan: end)
        .limit(30)
        .get();

    final results = <Map<String, dynamic>>[];
    final seenIds = <String>{};

    for (final doc in snapshot.docs) {
      if (seenIds.contains(doc.id)) continue;
      seenIds.add(doc.id);
      final data = doc.data() as Map<String, dynamic>;
      results.add({
        'id': doc.id,
        'name': data['name'] ?? '',
        'username': data['username'] ?? '',
        'bio': data['bio'] ?? '',
        'profileImage': data['profileImage'],
      });
    }

    // Secondary in-memory pass: also match against username.
    final usernameSnapshot = await _users
        .where('username', isGreaterThanOrEqualTo: normalized)
        .where('username', isLessThan: end)
        .limit(30)
        .get();

    for (final doc in usernameSnapshot.docs) {
      if (seenIds.contains(doc.id)) continue;
      seenIds.add(doc.id);
      final data = doc.data() as Map<String, dynamic>;
      results.add({
        'id': doc.id,
        'name': data['name'] ?? '',
        'username': data['username'] ?? '',
        'bio': data['bio'] ?? '',
        'profileImage': data['profileImage'],
      });
    }

    return results.take(20).toList();
  }

  /// Firestore prefix-match on the `title` field.
  /// Results are additionally filtered in-memory against `description`.
  @override
  Future<List<PostModel>> searchPosts(String query) async {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return [];

    final end = normalized.substring(0, normalized.length - 1) +
        String.fromCharCode(normalized.codeUnitAt(normalized.length - 1) + 1);

    final snapshot = await _posts
        .where('title', isGreaterThanOrEqualTo: normalized)
        .where('title', isLessThan: end)
        .orderBy('title')
        .limit(20)
        .get();

    final results = snapshot.docs.map(PostModel.fromDoc).toList();

    // In-memory pass: also include posts whose description contains the query.
    final allSnapshot = await _posts
        .orderBy('createdAt', descending: true)
        .limit(50)
        .get();

    final seenIds = results.map((p) => p.id).toSet();
    for (final doc in allSnapshot.docs) {
      if (seenIds.contains(doc.id)) continue;
      final data = doc.data() as Map<String, dynamic>;
      final title = (data['title'] as String? ?? '').toLowerCase();
      final description = (data['description'] as String? ?? '').toLowerCase();
      if (title.contains(normalized) || description.contains(normalized)) {
        results.add(PostModel.fromDoc(doc));
        seenIds.add(doc.id);
      }
    }

    return results.take(20).toList();
  }
}
