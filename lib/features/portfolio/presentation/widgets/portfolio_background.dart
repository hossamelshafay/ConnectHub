import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:connecthub/core/utils/app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Fixed Background Canvas (Atmospheric Frosted Glass with Visible Image)
// ─────────────────────────────────────────────────────────────────────────────
class PortfolioBackground extends StatelessWidget {
  const PortfolioBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark;

    return Positioned.fill(
      child: RepaintBoundary(
        child: Stack(
        children: [
          // Base metallic titanium background
          Positioned.fill(
            child: Container(
              color: isDark ? const Color(0xFF121110) : const Color(0xFFF4F2EE),
            ),
          ),

          // Background image with soft glassmorphism blur (~60% visible, ~40% blur/overlay)
          Positioned.fill(
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
              child: Opacity(
                opacity: isDark ? 0.55 : 0.65,
                child: Image.asset(
                  'assets/img/background.png',
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                  errorBuilder: (ctx, err, stack) => Image.asset(
                    'assets/images/background.png',
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                    errorBuilder: (ctx2, err2, stack2) => Image.asset(
                      'assets/img/glass.png',
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                      errorBuilder: (ctx3, err3, stack3) => const SizedBox.shrink(),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Airy warm titanium gradient overlay (keeps wallpaper clearly noticeable while ensuring contrast)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    isDark
                        ? const Color(0x40121110)
                        : const Color(0x18F4F0E8),
                    isDark
                        ? const Color(0x65121110)
                        : const Color(0x35F4F0E8),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
}
