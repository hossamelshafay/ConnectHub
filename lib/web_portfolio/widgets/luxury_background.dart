import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../theme/web_colors.dart';

/// A subtle, GPU-optimized luxury background with warm gold ambient radial glows
/// and a fine stochastic micro-grain texture.
class LuxuryBackground extends StatelessWidget {
  const LuxuryBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Stack(
        children: [
          // Base deep black
          Container(color: WebColors.background),

          // Subtle warm gold ambient glow at the top
          Positioned(
            top: -200,
            left: 0,
            right: 0,
            height: 750,
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topCenter,
                  radius: 1.1,
                  colors: [
                    WebColors.primary.withValues(alpha: 0.05),
                    WebColors.primaryDark.withValues(alpha: 0.02),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.45, 1.0],
                ),
              ),
            ),
          ),

          // Secondary subtle gold illumination
          Positioned(
            top: 1400,
            right: -150,
            width: 600,
            height: 600,
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 0.85,
                  colors: [
                    WebColors.primaryLight.withValues(alpha: 0.025),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Fine procedural micro-grain
          Positioned.fill(
            child: CustomPaint(
              painter: const _LuxuryNoisePainter(),
            ),
          ),
        ],
      ),
    );
  }
}

class _LuxuryNoisePainter extends CustomPainter {
  const _LuxuryNoisePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFFFFFF).withValues(alpha: 0.015)
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;

    const step = 26.0;
    for (double x = 0; x < size.width; x += step) {
      for (double y = 0; y < size.height; y += step) {
        final hash = ((x * 12.9898 + y * 78.233) % 1.0);
        if (hash > 0.48) {
          final offsetX = (hash * 19) % step;
          final offsetY = (hash * 37) % step;
          canvas.drawPoints(
            ui.PointMode.points,
            [Offset(x + offsetX, y + offsetY)],
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
