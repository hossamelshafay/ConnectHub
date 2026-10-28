import 'package:flutter/material.dart';
import 'package:connecthub/core/utils/app_theme.dart';

/// Remove Photo card matching Mockup Screen 3:
/// - Red trash icon
/// - "Remove Photo" red heading
/// - "Remove your profile photo and restore the default image." subtitle
/// - Soft rounded tinted card
class EditProfileRemovePhotoTile extends StatelessWidget {
  final VoidCallback onTap;

  const EditProfileRemovePhotoTile({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark;
    final bg = isDark ? const Color(0x28EF4444) : const Color(0xFFFDF2F2);
    final border = isDark ? const Color(0x40EF4444) : const Color(0xFFFCE1E1);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: border),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark ? const Color(0x35EF4444) : const Color(0xFFFDE8E8),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.delete_outline_rounded,
                size: 20,
                color: Color(0xFFEF4444),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Remove Photo',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFEF4444),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Remove your profile photo and restore the default image.',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: isDark ? const Color(0xFFFCA5A5) : const Color(0xFF7F6E6E),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
