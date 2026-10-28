import 'package:flutter/material.dart';
import 'package:connecthub/core/utils/app_theme.dart';
import 'package:connecthub/core/widgets/shimmer_box.dart';
import 'package:connecthub/core/widgets/shimmers/app_shimmer.dart';
import 'package:connecthub/core/widgets/shimmers/post_card_shimmer.dart';

/// Reusable Profile Header Shimmer that matches the layout of [ProfileCard].
class ProfileHeaderShimmer extends StatelessWidget {
  final bool includePosts;

  const ProfileHeaderShimmer({
    super.key,
    this.includePosts = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        physics: const NeverScrollableScrollPhysics(),
        children: [
          // ── Header Card ─────────────────────────────────────────────
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.glassBorder, width: 1),
            ),
            child: Column(
              children: [
                // Top row with Avatar + Edit button placeholder
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ShimmerBox.circle(size: 76),
                    const Spacer(),
                    const ShimmerBox(width: 90, height: 36, borderRadius: 18),
                  ],
                ),
                const SizedBox(height: 16),

                // Name & Username
                Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      ShimmerBox(width: 160, height: 20, borderRadius: 6),
                      SizedBox(height: 6),
                      ShimmerBox(width: 100, height: 13, borderRadius: 5),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Headline & Bio
                const Align(
                  alignment: Alignment.centerLeft,
                  child: ShimmerBox(
                    width: double.infinity,
                    height: 13,
                    borderRadius: 5,
                  ),
                ),
                const SizedBox(height: 6),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: ShimmerBox(
                    width: 240,
                    height: 13,
                    borderRadius: 5,
                  ),
                ),
                const SizedBox(height: 16),

                // Stats Row: Posts, Likes, Followers, Following
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: const [
                      _StatShimmerItem(),
                      _StatShimmerItem(),
                      _StatShimmerItem(),
                      _StatShimmerItem(),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Tabs placeholder (Posts / Liked)
                Row(
                  children: const [
                    Expanded(
                      child: ShimmerBox(
                        width: double.infinity,
                        height: 38,
                        borderRadius: 12,
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: ShimmerBox(
                        width: double.infinity,
                        height: 38,
                        borderRadius: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ── Feed Post Shimmers below header ─────────────────────────
          if (includePosts) ...[
            const PostCardShimmer(hasImage: false),
            const SizedBox(height: 8),
            const PostCardShimmer(hasImage: true),
          ],
        ],
      ),
    );
  }
}

class _StatShimmerItem extends StatelessWidget {
  const _StatShimmerItem();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: const [
        ShimmerBox(width: 28, height: 16, borderRadius: 4),
        SizedBox(height: 4),
        ShimmerBox(width: 44, height: 11, borderRadius: 4),
      ],
    );
  }
}
