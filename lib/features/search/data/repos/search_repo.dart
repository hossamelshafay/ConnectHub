import 'package:connecthub/features/home/data/models/post_model.dart';

abstract class SearchRepo {
  /// Searches users by display name or username prefix.
  /// Returns raw user maps (id, name, username, bio, profileImage).
  Future<List<Map<String, dynamic>>> searchUsers(String query);

  /// Searches posts by title or description prefix.
  /// Returns a list of [PostModel].
  Future<List<PostModel>> searchPosts(String query);
}
