import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:connecthub/core/utils/app_theme.dart';

/// Universal Warm Titanium Shimmer wrapper powered by the `shimmer` package.
///
/// Seamlessly supports Light Mode and Dark Mode by inheriting colors from [AppColors].
class AppShimmer extends StatelessWidget {
  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;

  const AppShimmer({
    super.key,
    required this.child,
    this.baseColor,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: baseColor ?? AppColors.shimmerBase,
      highlightColor: highlightColor ?? AppColors.shimmerHighlight,
      child: child,
    );
  }
}
