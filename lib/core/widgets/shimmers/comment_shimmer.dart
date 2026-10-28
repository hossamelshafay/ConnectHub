import 'package:flutter/material.dart';
import 'package:connecthub/core/utils/app_theme.dart';
import 'package:connecthub/core/widgets/shimmer_box.dart';
import 'package:connecthub/core/widgets/shimmers/app_shimmer.dart';

/// Reusable Comment Shimmer that matches the layout of [CommentTile].
class CommentShimmer extends StatelessWidget {
  final int itemCount;

  const CommentShimmer({
    super.key,
    this.itemCount = 3,
  });

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemCount,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) => const _SingleCommentShimmer(),
      ),
    );
  }
}

class _SingleCommentShimmer extends StatelessWidget {
  const _SingleCommentShimmer();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ShimmerBox.circle(size: 36),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ShimmerBox(width: 100, height: 13, borderRadius: 5),
                    ShimmerBox(width: 45, height: 10, borderRadius: 4),
                  ],
                ),
                SizedBox(height: 8),
                ShimmerBox(width: double.infinity, height: 12, borderRadius: 5),
                SizedBox(height: 6),
                ShimmerBox(width: 160, height: 12, borderRadius: 5),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
