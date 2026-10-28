import 'package:flutter/material.dart';
import 'package:connecthub/core/utils/app_theme.dart';
import 'package:connecthub/core/widgets/shimmer_box.dart';
import 'package:connecthub/core/widgets/shimmers/app_shimmer.dart';

/// Reusable Post Card Shimmer that matches the exact geometry of [PostCard].
///
/// Supports Light and Dark modes seamlessly.
class PostCardShimmer extends StatelessWidget {
  final bool hasImage;

  const PostCardShimmer({
    super.key,
    this.hasImage = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.glassBorder, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Header Row
            Row(
              children: [
                const ShimmerBox.circle(size: 44),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      ShimmerBox(width: 130, height: 14, borderRadius: 6),
                      SizedBox(height: 6),
                      ShimmerBox(width: 85, height: 11, borderRadius: 5),
                    ],
                  ),
                ),
                const ShimmerBox(width: 24, height: 14, borderRadius: 4),
              ],
            ),
            const SizedBox(height: 14),

            // Content text lines
            const ShimmerBox(
              width: double.infinity,
              height: 14,
              borderRadius: 6,
            ),
            const SizedBox(height: 8),
            const ShimmerBox(
              width: 220,
              height: 13,
              borderRadius: 6,
            ),

            // Optional Image placeholder
            if (hasImage) ...[
              const SizedBox(height: 12),
              const ShimmerBox(
                width: double.infinity,
                height: 160,
                borderRadius: 14,
              ),
            ],

            const SizedBox(height: 14),
            Divider(color: AppColors.divider, height: 1),
            const SizedBox(height: 10),

            // Bottom action icons row (Like, Comment, Share)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [
                ShimmerBox(width: 60, height: 20, borderRadius: 10),
                ShimmerBox(width: 60, height: 20, borderRadius: 10),
                ShimmerBox(width: 60, height: 20, borderRadius: 10),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
