import 'package:flutter/material.dart';
import 'package:connecthub/core/utils/app_theme.dart';
import 'package:connecthub/core/utils/mention_helper.dart';
import 'package:connecthub/features/profile/presentation/views/profile_router.dart';

/// Centralized helper for opening user profiles consistently across the app.
class ProfileNavigationHelper {
  /// Opens a user profile by [userId] using the reusable [ProfileRouter].
  ///
  /// Dynamically determines whether the user is Personal or Professional
  /// and renders the appropriate view.
  static void openUserProfile(
    BuildContext context, {
    required String userId,
    String? userName,
  }) {
    if (userId.isEmpty) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProfileRouter(
          userId: userId,
          userName: userName,
          showBackButton: true,
        ),
      ),
    );
  }

  /// Resolves [username] using [MentionHelper.getUserByUsername] and opens the corresponding profile.
  static Future<void> openProfileByUsername(
    BuildContext context,
    String username,
  ) async {
    final cleanUsername = username.trim().replaceAll('@', '');
    if (cleanUsername.isEmpty) return;

    final user = await MentionHelper.getUserByUsername(cleanUsername);
    if (!context.mounted) return;

    if (user != null) {
      final id = user['id'] as String? ?? '';
      final rawName = (user['name'] as String? ?? '').trim();
      final name = rawName.isNotEmpty ? rawName : cleanUsername;

      if (id.isNotEmpty) {
        openUserProfile(context, userId: id, userName: name);
        return;
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('User @$cleanUsername not found.'),
        backgroundColor: AppColors.textSecondary,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
