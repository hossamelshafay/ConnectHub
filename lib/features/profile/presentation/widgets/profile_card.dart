import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connecthub/core/utils/app_theme.dart';

class ProfileCard extends StatelessWidget {
  final User user;
  final int postCount;
  final int totalLikes;
  final int followersCount;
  final int followingCount;
  final String? displayName;
  final String? username;
  final String? bio;
  final String? profileImage;
  final DateTime? joinedDate;
  final bool isCurrentUser;
  final VoidCallback? onEditProfile;
  final VoidCallback? onLikedPosts;
  final VoidCallback? onFollowersTap;
  final VoidCallback? onFollowingTap;

  const ProfileCard({
    super.key,
    required this.user,
    required this.postCount,
    this.totalLikes = 0,
    this.followersCount = 0,
    this.followingCount = 0,
    this.displayName,
    this.username,
    this.bio,
    this.profileImage,
    this.joinedDate,
    this.isCurrentUser = true,
    this.onEditProfile,
    this.onLikedPosts,
    this.onFollowersTap,
    this.onFollowingTap,
  });

  Widget get _verticalDivider => Container(
        width: 1,
        height: 32,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        color: Colors.white.withValues(alpha: 0.25),
      );

  @override
  Widget build(BuildContext context) {
    final effectiveName = displayName?.trim().isNotEmpty == true
        ? displayName!
        : (user.displayName?.trim().isNotEmpty == true
            ? user.displayName!
            : 'User');

    final effectiveUsername = username?.trim().isNotEmpty == true
        ? (username!.startsWith('@') ? username! : '@$username')
        : '@${user.email?.split('@').first ?? 'user'}';

    final effectiveJoinedDate = joinedDate ??
        user.metadata.creationTime ??
        DateTime.now();
    final joinedString = DateFormat('MMMM yyyy').format(effectiveJoinedDate);

    final imageUrl = profileImage ?? user.photoURL;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.accent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Circular Profile Image
          Container(
            width: 86,
            height: 86,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.3),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.8),
                width: 2.5,
              ),
            ),
            child: ClipOval(
              child: (imageUrl != null && imageUrl.isNotEmpty)
                  ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      width: 80,
                      height: 80,
                      placeholder: (_, _) => Container(
                        color: Colors.white.withValues(alpha: 0.2),
                        child: const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                      ),
                      errorWidget: (_, _, _) => _buildAvatarFallback(effectiveName),
                    )
                  : _buildAvatarFallback(effectiveName),
            ),
          ),
          const SizedBox(height: 12),

          // Display Name
          Text(
            effectiveName,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: -0.3,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 3),

          // Username (@username)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              effectiveUsername,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.white.withValues(alpha: 0.95),
              ),
            ),
          ),

          // Bio
          if (bio != null && bio!.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                bio!.trim(),
                style: TextStyle(
                  fontSize: 14,
                  height: 1.35,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],

          const SizedBox(height: 10),

          // Joined Date
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.calendar_today_rounded,
                size: 13,
                color: Colors.white.withValues(alpha: 0.75),
              ),
              const SizedBox(width: 6),
              Text(
                'Joined $joinedString',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),
          Container(
            height: 1,
            color: Colors.white.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 14),

          // Stat Row: Posts · Followers · Following
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              StatItem(
                count: postCount.toString(),
                label: 'Posts',
              ),
              _verticalDivider,
              GestureDetector(
                onTap: onFollowersTap,
                behavior: HitTestBehavior.opaque,
                child: StatItem(
                  count: followersCount.toString(),
                  label: 'Followers',
                  isClickable: onFollowersTap != null,
                ),
              ),
              _verticalDivider,
              GestureDetector(
                onTap: onFollowingTap,
                behavior: HitTestBehavior.opaque,
                child: StatItem(
                  count: followingCount.toString(),
                  label: 'Following',
                  isClickable: onFollowingTap != null,
                ),
              ),
            ],
          ),

          // Action Buttons: Edit Profile & Liked Posts
          if (isCurrentUser) ...[
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onEditProfile,
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label: const Text(
                      'Edit Profile',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(
                        color: Colors.white.withValues(alpha: 0.85),
                        width: 1.5,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      backgroundColor: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onLikedPosts,
                    icon: const Icon(Icons.favorite_rounded, size: 16),
                    label: const Text(
                      'Liked Posts',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatarFallback(String name) {
    return Container(
      color: Colors.white.withValues(alpha: 0.2),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : 'U',
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class StatItem extends StatelessWidget {
  final String count;
  final String label;
  final bool isClickable;

  const StatItem({
    super.key,
    required this.count,
    required this.label,
    this.isClickable = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              count,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            if (isClickable) ...[
              const SizedBox(width: 3),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 10,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ],
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isClickable ? FontWeight.w600 : FontWeight.w400,
            color: Colors.white.withValues(alpha: isClickable ? 0.95 : 0.8),
            decoration:
                isClickable ? TextDecoration.underline : TextDecoration.none,
            decorationColor: Colors.white.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}
