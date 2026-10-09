import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/web_colors.dart';
import '../theme/web_text_styles.dart';

/// Animated skill progress bar with percentage indicator and gradient fill.
class AnimatedProgressBar extends StatefulWidget {
  final String label;
  final double percentage; // 0.0 to 1.0
  final Duration duration;
  final Duration delay;
  final bool isDark;

  const AnimatedProgressBar({
    super.key,
    required this.label,
    required this.percentage,
    this.duration = const Duration(milliseconds: 1200),
    this.delay = Duration.zero,
    this.isDark = true,
  });

  @override
  State<AnimatedProgressBar> createState() => _AnimatedProgressBarState();
}

class _AnimatedProgressBarState extends State<AnimatedProgressBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;
  Timer? _delayTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      _delayTimer = Timer(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _delayTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                widget.label,
                style: WebTextStyles.cardSubtitle(isDark: widget.isDark).copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: widget.isDark ? WebColors.textPrimary : WebColors.lightTextPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                final displayPercent = (_animation.value * widget.percentage * 100).round();
                return Text(
                  '$displayPercent%',
                  style: WebTextStyles.bodySmall(isDark: widget.isDark).copyWith(
                    fontWeight: FontWeight.w600,
                    color: WebColors.primaryLight,
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 8,
          width: double.infinity,
          decoration: BoxDecoration(
            color: widget.isDark ? WebColors.surfaceElevated : WebColors.lightBorder,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: widget.isDark ? WebColors.border : Colors.transparent,
              width: 0.5,
            ),
          ),
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: (_animation.value * widget.percentage).clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: WebColors.primaryGradient,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: WebColors.primary.withValues(alpha: 0.35),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
