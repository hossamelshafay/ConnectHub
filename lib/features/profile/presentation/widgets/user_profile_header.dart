import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connecthub/core/utils/app_theme.dart';
import 'package:connecthub/core/widgets/user_avatar.dart';
import 'package:connecthub/features/follow/presentation/manager/cubit/follow_cubit.dart';
import 'package:connecthub/features/follow/presentation/manager/cubit/follow_state.dart';
import 'package:connecthub/features/follow/presentation/widgets/follow_button.dart';
import 'package:connecthub/features/home/presentation/manager/cubit/posts_cubit.dart';
import 'package:connecthub/features/home/presentation/manager/cubit/posts_state.dart';
import 'package:connecthub/features/profile/presentation/manager/cubit/profile_cubit.dart';
import 'package:connecthub/features/profile/presentation/views/followers_view.dart';
import 'package:connecthub/features/profile/presentation/views/following_view.dart';
import 'package:connecthub/features/portfolio/presentation/widgets/portfolio_switch_button.dart';
import 'package:connecthub/features/profile/presentation/widgets/message_profile_button.dart';
import 'package:connecthub/features/profile/presentation/widgets/profile_social_links_bar.dart';
import 'package:connecthub/features/profile/presentation/widgets/profile_stat_bar.dart';

/// Redesigned UserProfileHeader matching the mockup visual structure:
/// - Horizontal top row with Avatar, Name + Verified Badge, Headline, and Location.
/// - Bio paragraph.
/// - Social links bar with website pill and brand icon buttons.
/// - Stats bar (Posts · Followers · Following).
/// - Follow and Message action row.
class UserProfileHeader extends StatelessWidget {
  final String userName;
  final String userId;
  final VoidCallback? onSwitchToPortfolio;

  const UserProfileHeader({
    super.key,
    required this.userName,
    required this.userId,
    this.onSwitchToPortfolio,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FollowCubit, FollowState>(
      builder: (context, followState) {
        final followersCount =
            followState is FollowLoaded ? followState.followersCount : 0;
        final followingCount =
            followState is FollowLoaded ? followState.followingCount : 0;
        final profileImage =
            followState is FollowLoaded ? followState.profileImage : null;
        final bio = followState is FollowLoaded ? followState.bio : null;
        final headline =
            followState is FollowLoaded ? followState.headline : null;
        final location =
            followState is FollowLoaded ? followState.location : null;
        final socialLinks = followState is FollowLoaded
            ? followState.socialLinks
            : null;
        final websiteUrl =
            followState is FollowLoaded ? followState.websiteUrl : null;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header Row: Avatar + Info + Action ──────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                      name: userName,
                      imageUrl: profileImage,
                      size: 71,
                    ),
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
                                userName,
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
                        if (headline != null && headline.trim().isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Text(
                            headline.trim(),
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
                        if (location != null && location.trim().isNotEmpty) ...[
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
                                  location.trim(),
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
                ],
              ),

              // ── Bio ─────────────────────────────────────────────────────
              if (bio != null && bio.trim().isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  bio.trim(),
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13.5,
                    height: 1.45,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],

              // ── Social Links Row ────────────────────────────────────────
              if (socialLinks != null && socialLinks.isNotEmpty) ...[
                const SizedBox(height: 14),
                ProfileSocialLinksBar(
                  socialLinks: socialLinks,
                  websiteUrl: websiteUrl,
                ),
              ],

              const SizedBox(height: 16),

              // ── Statistics Bar ──────────────────────────────────────────
              BlocBuilder<PostsCubit, PostsState>(
                builder: (context, postsState) {
                  final postCount =
                      postsState is PostsLoaded ? postsState.posts.length : 0;

                  return ProfileStatBar(
                    postCount: postCount,
                    followersCount: followersCount,
                    followingCount: followingCount,
                    onFollowersTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BlocProvider(
                            create: (_) => ProfileCubit(),
                            child: FollowersView(
                              userId: userId,
                              userName: userName,
                            ),
                          ),
                        ),
                      );
                    },
                    onFollowingTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BlocProvider(
                            create: (_) => ProfileCubit(),
                            child: FollowingView(
                              userId: userId,
                              userName: userName,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),

              // ── Follow / Message Action Buttons ─────────────────────────
              if (FirebaseAuth.instance.currentUser?.uid != userId) ...[
                const SizedBox(height: 14),
                Row(
                  children: [
                    const Expanded(child: FollowButton()),
                    const SizedBox(width: 10),
                    Expanded(
                      child: MessageProfileButton(
                        userId: userId,
                        userName: userName,
                        userPhoto: profileImage,
                      ),
                    ),
                  ],
                ),
              ],

              if (onSwitchToPortfolio != null) ...[
                const SizedBox(height: 12),
                PortfolioSwitchButton(
                  target: ProfileSwitchTarget.portfolio,
                  onPressed: onSwitchToPortfolio!,
                  isDarkTheme: AppColors.isDark,
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
