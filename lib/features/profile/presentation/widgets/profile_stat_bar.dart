import 'package:flutter/material.dart';
import 'package:connecthub/core/utils/app_theme.dart';

/// Segmented statistics bar matching the mockup layout:
/// - Three columns: Posts, Followers, Following.
/// - Top number in bold modern font, bottom label in muted graphite.
/// - Followers and Following sections are interactive.
class ProfileStatBar extends StatelessWidget {
  final int postCount;
  final int followersCount;
  final int followingCount;
  final VoidCallback? onFollowersTap;
  final VoidCallback? onFollowingTap;

  const ProfileStatBar({
    super.key,
    required this.postCount,
    required this.followersCount,
    required this.followingCount,
    this.onFollowersTap,
    this.onFollowingTap,
  });

  Widget _buildItem({
    required BuildContext context,
    required String count,
    required String label,
    VoidCallback? onTap,
  }) {
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          count,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 12.5,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );

    if (onTap != null) {
      return Expanded(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: content,
          ),
        ),
      );
    }

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: content,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.isDark
            ? const Color(0x352E2B27)
            : const Color(0xFFFAF7F2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.isDark
              ? const Color(0x28FFFFFF)
              : const Color(0xFFE8E0D5),
        ),
      ),
      child: Row(
        children: [
          _buildItem(
            context: context,
            count: postCount.toString(),
            label: 'Posts',
          ),
          Container(
            width: 1,
            height: 28,
            color: AppColors.isDark
                ? const Color(0x20FFFFFF)
                : const Color(0xFFE2D9CC),
          ),
          _buildItem(
            context: context,
            count: followersCount.toString(),
            label: 'Followers',
            onTap: onFollowersTap,
          ),
          Container(
            width: 1,
            height: 28,
            color: AppColors.isDark
                ? const Color(0x20FFFFFF)
                : const Color(0xFFE2D9CC),
          ),
          _buildItem(
            context: context,
            count: followingCount.toString(),
            label: 'Following',
            onTap: onFollowingTap,
          ),
        ],
      ),
    );
  }
}
