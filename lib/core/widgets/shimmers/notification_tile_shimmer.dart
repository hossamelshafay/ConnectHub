import 'package:flutter/material.dart';
import 'package:connecthub/core/utils/app_theme.dart';
import 'package:connecthub/core/widgets/shimmer_box.dart';
import 'package:connecthub/core/widgets/shimmers/app_shimmer.dart';

/// Reusable Notification Tile Shimmer matching the layout of [NotificationTile].
class NotificationTileShimmer extends StatelessWidget {
  final int itemCount;

  const NotificationTileShimmer({
    super.key,
    this.itemCount = 6,
  });

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemCount,
        itemBuilder: (context, index) => const _SingleNotificationShimmer(),
      ),
    );
  }
}

class _SingleNotificationShimmer extends StatelessWidget {
  const _SingleNotificationShimmer();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder, width: 1),
      ),
      child: Row(
        children: [
          const ShimmerBox.circle(size: 44),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                ShimmerBox(width: 170, height: 14, borderRadius: 6),
                SizedBox(height: 7),
                ShimmerBox(width: 90, height: 11, borderRadius: 5),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const ShimmerBox.circle(size: 8),
        ],
      ),
    );
  }
}
