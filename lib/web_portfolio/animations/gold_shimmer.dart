import 'package:flutter/material.dart';
import '../theme/web_colors.dart';

/// Renders a diagonal metallic shimmer sweep over a child widget using ShaderMask.
///
/// The shimmer travels from top-left to bottom-right continuously.
/// Subtle, GPU-friendly, and loop-smooth — designed for luxury text and buttons.
///
/// Usage:
/// ```dart
/// GoldShimmerText(
///   child: Text('ConnectHub', style: bigStyle),
/// )
/// ```
class GoldShimmerText extends StatefulWidget {
  final Widget child;

  /// Duration of one full shimmer sweep cycle. Default 3.5s for subtlety.
  final Duration duration;

  /// How strong the shimmer is — blends between plain gold and bright sweep.
  /// 0.0 = invisible, 1.0 = full bright. Default 1.0.
  final double intensity;

  const GoldShimmerText({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 3500),
    this.intensity = 1.0,
  });

  @override
  State<GoldShimmerText> createState() => _GoldShimmerTextState();
}

class _GoldShimmerTextState extends State<GoldShimmerText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _shimmerOffset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();
    _shimmerOffset = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmerOffset,
      builder: (context, child) {
        final t = _shimmerOffset.value;
        return ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: const [
                WebColors.primary,      // #D4AF37 gold
                WebColors.primaryLight, // #F4D06F light gold
                Color(0xFFFFF3C4),      // bright highlight peak
                WebColors.primaryLight, // #F4D06F light gold
                WebColors.primary,      // #D4AF37 gold
              ],
              stops: const [0.0, 0.3, 0.5, 0.7, 1.0],
              begin: Alignment(t - 1, t - 1),
              end: Alignment(t + 1, t + 1),
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// Wraps a button or surface widget with the same diagonal shimmer
/// applied as a foreground overlay. Used for CTA buttons.
class GoldShimmerSurface extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const GoldShimmerSurface({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 4000),
  });

  @override
  State<GoldShimmerSurface> createState() => _GoldShimmerSurfaceState();
}

class _GoldShimmerSurfaceState extends State<GoldShimmerSurface>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value * 3 - 1; // sweeps from -1 to 2
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: const [
                Color(0x00D4AF37),
                Color(0x20F4D06F),
                Color(0x38FFF3C4),
                Color(0x20F4D06F),
                Color(0x00D4AF37),
              ],
              stops: const [0.0, 0.3, 0.5, 0.7, 1.0],
              begin: Alignment(t - 1, t - 1),
              end: Alignment(t + 1, t + 1),
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
