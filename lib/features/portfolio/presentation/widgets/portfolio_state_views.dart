import 'package:flutter/material.dart';
import 'package:connecthub/core/utils/app_theme.dart';
import 'package:connecthub/features/portfolio/presentation/widgets/portfolio_theme.dart';

import 'package:connecthub/core/utils/app_widgets.dart';

class PortfolioLoadingView extends StatelessWidget {
  const PortfolioLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // Hero Header Shimmer
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.glassBorder, width: 1),
            ),
            child: Column(
              children: [
                const ShimmerBox.circle(size: 80),
                const SizedBox(height: 14),
                const ShimmerBox(width: 160, height: 20, borderRadius: 6),
                const SizedBox(height: 8),
                const ShimmerBox(width: 120, height: 13, borderRadius: 5),
                const SizedBox(height: 14),
                const ShimmerBox(
                  width: double.infinity,
                  height: 12,
                  borderRadius: 5,
                ),
                const SizedBox(height: 6),
                const ShimmerBox(width: 220, height: 12, borderRadius: 5),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    ShimmerBox(width: 80, height: 32, borderRadius: 16),
                    SizedBox(width: 12),
                    ShimmerBox(width: 90, height: 32, borderRadius: 16),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Section Title
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            child: ShimmerBox(width: 140, height: 18, borderRadius: 6),
          ),
          const SizedBox(height: 8),

          // Project Cards
          const ProjectCardShimmer(itemCount: 2),
        ],
      ),
    );
  }
}

class PortfolioErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const PortfolioErrorView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Color(0xFFEF4444),
              size: 40,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(color: kPortfolioTextSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kPortfolioAccent,
                foregroundColor: AppColors.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
