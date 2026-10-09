import 'package:flutter/material.dart';
import '../theme/web_colors.dart';
import '../animations/gold_shimmer.dart';
import '../responsive/responsive.dart';
import 'responsive_container.dart';

/// Luxury Black + Gold Shimmer Loading view that mirrors the exact Web Portfolio structure.
class PortfolioShimmerLoading extends StatelessWidget {
  const PortfolioShimmerLoading({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= ResponsiveBreakpoints.desktop;
    final isMobile = screenWidth < ResponsiveBreakpoints.tablet;

    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Shimmer Top Navigation Bar ─────────────────────────────────
          Container(
            height: 76,
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 48),
            decoration: BoxDecoration(
              color: WebColors.surface.withValues(alpha: 0.8),
              border: const Border(
                bottom: BorderSide(color: WebColors.border, width: 1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _shimmerBox(width: 140, height: 26, radius: 8),
                if (!isMobile)
                  Row(
                    children: [
                      _shimmerBox(width: 60, height: 16, radius: 4),
                      const SizedBox(width: 24),
                      _shimmerBox(width: 60, height: 16, radius: 4),
                      const SizedBox(width: 24),
                      _shimmerBox(width: 60, height: 16, radius: 4),
                      const SizedBox(width: 24),
                      _shimmerBox(width: 100, height: 36, radius: 20),
                    ],
                  )
                else
                  _shimmerBox(width: 38, height: 38, radius: 8),
              ],
            ),
          ),

          // ── Shimmer Hero Section ───────────────────────────────────────
          ResponsiveContainer(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 20.0 : 52.0,
              vertical: isMobile ? 36.0 : 70.0,
            ),
            child: isDesktop
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 6,
                        child: _buildHeroLeftShimmer(isMobile: false),
                      ),
                      const SizedBox(width: 64),
                      Expanded(
                        flex: 4,
                        child: Center(
                          child: _shimmerCircle(size: 240),
                        ),
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _shimmerCircle(size: 180),
                      const SizedBox(height: 36),
                      _buildHeroLeftShimmer(isMobile: true),
                    ],
                  ),
          ),

          const SizedBox(height: 40),

          // ── Shimmer Section Header ─────────────────────────────────────
          ResponsiveContainer(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 52),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _shimmerBox(width: 120, height: 14, radius: 4),
                const SizedBox(height: 12),
                _shimmerBox(width: 280, height: 32, radius: 6),
                const SizedBox(height: 14),
                _shimmerBox(width: 480, height: 16, radius: 4),
                const SizedBox(height: 32),
                // Shimmer cards row
                Row(
                  children: [
                    Expanded(child: _shimmerCard(height: 240)),
                    if (!isMobile) ...[
                      const SizedBox(width: 20),
                      Expanded(child: _shimmerCard(height: 240)),
                    ],
                    if (isDesktop) ...[
                      const SizedBox(width: 20),
                      Expanded(child: _shimmerCard(height: 240)),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildHeroLeftShimmer({required bool isMobile}) {
    return Column(
      crossAxisAlignment:
          isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        _shimmerBox(width: 130, height: 18, radius: 20),
        const SizedBox(height: 20),
        _shimmerBox(width: isMobile ? 220 : 360, height: 44, radius: 8),
        const SizedBox(height: 14),
        _shimmerBox(width: isMobile ? 180 : 260, height: 24, radius: 6),
        const SizedBox(height: 20),
        _shimmerBox(width: isMobile ? 280 : 480, height: 16, radius: 4),
        const SizedBox(height: 8),
        _shimmerBox(width: isMobile ? 240 : 380, height: 16, radius: 4),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment:
              isMobile ? MainAxisAlignment.center : MainAxisAlignment.start,
          children: [
            _shimmerBox(width: 140, height: 46, radius: 12),
            const SizedBox(width: 16),
            _shimmerBox(width: 130, height: 46, radius: 12),
          ],
        ),
      ],
    );
  }

  static Widget _shimmerBox({
    required double width,
    required double height,
    required double radius,
  }) {
    return GoldShimmerSurface(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: WebColors.surfaceCard,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: WebColors.border, width: 0.8),
        ),
      ),
    );
  }

  static Widget _shimmerCircle({required double size}) {
    return GoldShimmerSurface(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: WebColors.surfaceCard,
          shape: BoxShape.circle,
          border: Border.all(color: WebColors.border, width: 1.5),
        ),
      ),
    );
  }

  static Widget _shimmerCard({required double height}) {
    return GoldShimmerSurface(
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: WebColors.surfaceCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: WebColors.border, width: 1),
        ),
      ),
    );
  }
}
