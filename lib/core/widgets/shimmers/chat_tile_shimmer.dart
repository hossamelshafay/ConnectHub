import 'package:flutter/material.dart';
import 'package:connecthub/core/utils/app_theme.dart';
import 'package:connecthub/core/widgets/shimmer_box.dart';
import 'package:connecthub/core/widgets/shimmers/app_shimmer.dart';

/// Reusable Chat Tile Shimmer matching conversation / direct message list items.
class ChatTileShimmer extends StatelessWidget {
  final int itemCount;

  const ChatTileShimmer({
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
        itemBuilder: (context, index) => const _SingleChatTileShimmer(),
      ),
    );
  }
}

class _SingleChatTileShimmer extends StatelessWidget {
  const _SingleChatTileShimmer();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder, width: 0.8),
      ),
      child: Row(
        children: [
          const ShimmerBox.circle(size: 52),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    ShimmerBox(width: 120, height: 14, borderRadius: 6),
                    ShimmerBox(width: 40, height: 10, borderRadius: 4),
                  ],
                ),
                const SizedBox(height: 8),
                const ShimmerBox(
                  width: double.infinity,
                  height: 12,
                  borderRadius: 5,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
