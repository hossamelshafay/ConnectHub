import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connecthub/core/utils/app_theme.dart';
import 'package:connecthub/core/utils/mention_helper.dart';
import 'package:connecthub/features/profile/presentation/views/profile_view.dart';
import 'package:connecthub/features/profile/presentation/views/user_profile_view.dart';

/// Centralized helper for opening user profiles consistently across the app.
class ProfileNavigationHelper {
  /// Opens a user profile by [userId].
  ///
  /// - If [userId] is the authenticated user, opens [ProfileView] with a back button.
  /// - Otherwise, opens the full [UserProfileView].
  static void openUserProfile(
    BuildContext context, {
    required String userId,
    String? userName,
  }) {
    if (userId.isEmpty) return;

    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    if (currentUserId != null && userId == currentUserId) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const ProfileView(showBackButton: true),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => UserProfileView(
            userId: userId,
            userName: (userName != null && userName.trim().isNotEmpty)
                ? userName.trim()
                : 'User',
          ),
        ),
      );
    }
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
