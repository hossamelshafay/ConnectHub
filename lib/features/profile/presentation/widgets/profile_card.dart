import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connecthub/core/utils/app_theme.dart';
import 'package:connecthub/core/widgets/user_avatar.dart';
import 'package:connecthub/features/portfolio/presentation/widgets/portfolio_switch_button.dart';
import 'package:connecthub/features/profile/data/models/user_model.dart';
import 'package:connecthub/features/profile/presentation/widgets/profile_social_links_bar.dart';
import 'package:connecthub/features/profile/presentation/widgets/profile_stat_bar.dart';
import 'package:connecthub/features/profile/presentation/widgets/profile_tab_bar.dart';

/// Redesigned Profile Header Card matching the visual reference mockup:
/// - Horizontal top row with Avatar (with camera badge), Name + Verified Badge,
///   Headline, and Location.
/// - Sleek "Edit Profile" pill button on the top right.
/// - Bio paragraph with refined typography.
/// - Horizontal social links row with website pill and brand icon buttons.
/// - Segmented statistics bar (Posts · Followers · Following).
/// - Pill segmented tab switcher ("Posts" / "Liked").
class ProfileCard extends StatelessWidget {
  final User user;
  final int postCount;
  final int totalLikes;
  final int followersCount;
  final int followingCount;
  final String? displayName;
  final String? username;
  final String? headline;
  final String? location;
  final String? bio;
  final SocialLinksModel? socialLinks;
  final String? profileImage;
  final DateTime? joinedDate;
  final bool isCurrentUser;
  final bool websiteGenerated;
  final String? websiteUrl;
  final VoidCallback? onEditProfile;
  final VoidCallback? onLikedPosts;
  final VoidCallback? onFollowersTap;
  final VoidCallback? onFollowingTap;
  final VoidCallback? onSwitchToPortfolio;
  final int selectedTabIndex;
  final ValueChanged<int>? onTabChanged;

  const ProfileCard({
    super.key,
    required this.user,
    required this.postCount,
    this.totalLikes = 0,
    this.followersCount = 0,
    this.followingCount = 0,
    this.displayName,
    this.username,
    this.headline,
    this.location,
    this.bio,
    this.socialLinks,
    this.profileImage,
    this.joinedDate,
    this.isCurrentUser = true,
    this.websiteGenerated = false,
    this.websiteUrl,
    this.onEditProfile,
    this.onLikedPosts,
    this.onFollowersTap,
    this.onFollowingTap,
    this.onSwitchToPortfolio,
    this.selectedTabIndex = 0,
    this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveName = displayName?.trim().isNotEmpty == true
        ? displayName!.trim()
        : (user.displayName?.trim().isNotEmpty == true
            ? user.displayName!.trim()
            : 'User');

    final effectiveHeadline = headline?.trim().isNotEmpty == true
        ? headline!.trim()
        : '';

    final effectiveLocation = location?.trim().isNotEmpty == true
        ? location!.trim()
        : '';

    final effectiveBio = bio?.trim().isNotEmpty == true
        ? bio!.trim()
        : '';

    final effectiveSocialLinks = socialLinks ?? const SocialLinksModel();
    final imageUrl = profileImage ?? user.photoURL;

    final editBtnBg = AppColors.isDark
        ? const Color(0x352E2B27)
        : const Color(0xFFEFE8DE);
    final editBtnBorder = AppColors.isDark
        ? const Color(0x28FFFFFF)
        : const Color(0xFFDFD6C8);
    final editBtnText = AppColors.isDark
        ? AppColors.primary
        : const Color(0xFF5A4D3F);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header Row: Avatar + Info + Edit Profile Button ─────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar with camera/action badge
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 76,
                    height: 76,
                    padding: const EdgeInsets.all(2.5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.isDark
                            ? const Color(0x35FFFFFF)
                            : const Color(0xFFE2D9CC),
                        width: 1.5,
                      ),
                    ),
                    child: UserAvatar(
                      name: effectiveName,
                      imageUrl: imageUrl,
                      size: 71,
                    ),
                  ),
                  if (isCurrentUser)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: GestureDetector(
                        onTap: onEditProfile,
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.isDark
                                ? const Color(0xFF2E2B27)
                                : const Color(0xFFEFE8DE),
                            border: Border.all(
                              color: AppColors.isDark
                                  ? const Color(0x50FFFFFF)
                                  : const Color(0xFFDFD6C8),
                              width: 1.2,
                            ),
                          ),
                          child: Icon(
                            Icons.camera_alt_rounded,
                            size: 13,
                            color: editBtnText,
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(width: 14),

              // Name, Headline, Location
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            effectiveName,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.3,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Icon(
                          Icons.verified,
                          size: 17,
                          color: AppColors.isDark
                              ? AppColors.primary
                              : const Color(0xFFA67C52),
                        ),
                      ],
                    ),
                    if (effectiveHeadline.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        effectiveHeadline,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                          letterSpacing: -0.1,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (effectiveLocation.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 13.5,
                            color: AppColors.textMuted,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              effectiveLocation,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: AppColors.textMuted,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Edit Profile Pill Button
              if (isCurrentUser && onEditProfile != null) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: onEditProfile,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 7.5,
                    ),
                    decoration: BoxDecoration(
                      color: editBtnBg,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: editBtnBorder),
                    ),
                    child: Text(
                      'Edit Profile',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: editBtnText,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),

          // ── Bio ─────────────────────────────────────────────────────
          if (effectiveBio.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              effectiveBio,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13.5,
                height: 1.45,
                color: AppColors.textSecondary,
              ),
            ),
          ],

          // ── Social Links Row ────────────────────────────────────────
          if (effectiveSocialLinks.isNotEmpty ||
              (websiteUrl != null && websiteUrl!.isNotEmpty)) ...[
            const SizedBox(height: 14),
            ProfileSocialLinksBar(
              socialLinks: effectiveSocialLinks,
              websiteUrl: websiteUrl,
            ),
          ],

          // ── Portfolio Switch Button (if enabled) ─────────────────────
          if (isCurrentUser && onSwitchToPortfolio != null) ...[
            const SizedBox(height: 12),
            PortfolioSwitchButton(
              target: ProfileSwitchTarget.portfolio,
              onPressed: onSwitchToPortfolio!,
              isDarkTheme: AppColors.isDark,
            ),
          ],

          const SizedBox(height: 16),

          // ── Statistics Bar (Posts · Followers · Following) ──────────
          ProfileStatBar(
            postCount: postCount,
            followersCount: followersCount,
            followingCount: followingCount,
            onFollowersTap: onFollowersTap,
            onFollowingTap: onFollowingTap,
          ),

          const SizedBox(height: 16),

          // ── Pill Tab Switcher ("Posts" / "Liked") ────────────────────
          if (onTabChanged != null)
            ProfileTabBar(
              selectedIndex: selectedTabIndex,
              onTabSelected: onTabChanged!,
              firstTabLabel: 'Posts',
              secondTabLabel: 'Liked',
            ),
        ],
      ),
    );
  }
}
