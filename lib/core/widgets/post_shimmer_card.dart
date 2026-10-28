import 'package:flutter/material.dart';
import 'package:connecthub/core/widgets/shimmers/post_card_shimmer.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PostShimmerCard — Preserved for backward compatibility
// Re-uses the newly upgraded [PostCardShimmer].
// ─────────────────────────────────────────────────────────────────────────────
class PostShimmerCard extends StatelessWidget {
  final bool hasImage;
  const PostShimmerCard({super.key, this.hasImage = true});

  @override
  Widget build(BuildContext context) {
    return PostCardShimmer(hasImage: hasImage);
  }
}
