import 'package:flutter/material.dart';
import 'package:connecthub/core/utils/app_theme.dart';
import 'package:connecthub/core/utils/app_widgets.dart';
import 'package:connecthub/features/profile/presentation/views/user_profile_view.dart';

/// A single user result tile for the Search screen.
///
/// Reuses [UserAvatar] from app_widgets.dart.
/// Navigates to [UserProfileView] on tap.
class UserSearchTile extends StatelessWidget {
  final Map<String, dynamic> user;

  const UserSearchTile({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final name = user['name'] as String? ?? 'Unknown';
    final username = user['username'] as String? ?? '';
    final bio = user['bio'] as String? ?? '';
    final profileImage = user['profileImage'] as String?;
    final id = user['id'] as String? ?? '';

    final usernameDisplay =
        username.isNotEmpty ? (username.startsWith('@') ? username : '@$username') : null;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => UserProfileView(userId: id, userName: name),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            UserAvatar(name: name, size: 48, imageUrl: profileImage),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: AppTextStyles.body1.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (usernameDisplay != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      usernameDisplay,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                  if (bio.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      bio,
                      style: AppTextStyles.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textHint,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
