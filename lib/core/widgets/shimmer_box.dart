import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:connecthub/core/utils/app_theme.dart';
import 'package:connecthub/core/widgets/shimmers/app_shimmer.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ShimmerBox — Adaptive Theme Shimmer Box / Skeleton Element
// Uses the `shimmer` package while maintaining full backwards compatibility.
// ─────────────────────────────────────────────────────────────────────────────
class ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  final BoxShape shape;

  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 12,
    this.shape = BoxShape.rectangle,
  });

  const ShimmerBox.circle({
    super.key,
    required double size,
  })  : width = size,
        height = size,
        borderRadius = size / 2,
        shape = BoxShape.circle;

  @override
  Widget build(BuildContext context) {
    final box = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        shape: shape,
        borderRadius: shape == BoxShape.circle
            ? null
            : BorderRadius.circular(borderRadius),
        color: AppColors.shimmerBase,
      ),
    );

    // If already inside an ancestor Shimmer, avoid redundant nested shimmers
    final hasAncestorShimmer =
        context.findAncestorWidgetOfExactType<Shimmer>() != null;
    if (hasAncestorShimmer) {
      return box;
    }

    return AppShimmer(child: box);
  }
}
