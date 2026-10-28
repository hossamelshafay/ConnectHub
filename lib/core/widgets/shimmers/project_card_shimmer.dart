import 'package:flutter/material.dart';
import 'package:connecthub/core/utils/app_theme.dart';
import 'package:connecthub/core/widgets/shimmer_box.dart';
import 'package:connecthub/core/widgets/shimmers/app_shimmer.dart';

/// Reusable Project Card Shimmer matching portfolio project cards.
class ProjectCardShimmer extends StatelessWidget {
  final int itemCount;

  const ProjectCardShimmer({
    super.key,
    this.itemCount = 1,
  });

  @override
  Widget build(BuildContext context) {
    if (itemCount == 1) {
      return const AppShimmer(child: _SingleProjectCardShimmer());
    }

    return AppShimmer(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemCount,
        separatorBuilder: (_, _) => const SizedBox(height: 14),
        itemBuilder: (context, index) => const _SingleProjectCardShimmer(),
      ),
    );
  }
}

class _SingleProjectCardShimmer extends StatelessWidget {
  const _SingleProjectCardShimmer();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.glassBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner thumbnail
          const ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
            child: ShimmerBox(
              width: double.infinity,
              height: 140,
              borderRadius: 0,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ShimmerBox(width: 160, height: 16, borderRadius: 6),
                const SizedBox(height: 10),
                const ShimmerBox(
                  width: double.infinity,
                  height: 13,
                  borderRadius: 5,
                ),
                const SizedBox(height: 6),
                const ShimmerBox(width: 220, height: 13, borderRadius: 5),
                const SizedBox(height: 14),

                // Tags row
                Row(
                  children: const [
                    ShimmerBox(width: 58, height: 22, borderRadius: 11),
                    SizedBox(width: 8),
                    ShimmerBox(width: 70, height: 22, borderRadius: 11),
                    SizedBox(width: 8),
                    ShimmerBox(width: 64, height: 22, borderRadius: 11),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
