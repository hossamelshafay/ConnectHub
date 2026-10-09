import 'package:flutter/material.dart';
import '../theme/web_colors.dart';

/// A premium luxury card with soft gold border, subtle shadow,
/// and a smooth 250ms hover elevation effect.
class GlassCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;
  final double blur;
  final List<BoxShadow>? boxShadow;
  final bool enableHover;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.margin,
    this.borderRadius = 12,
    this.backgroundColor,
    this.borderColor,
    this.blur = 0, // No blur by default — pure matte luxury card
    this.boxShadow,
    this.enableHover = true,
  });

  @override
  State<GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<GlassCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final bg = widget.backgroundColor ?? WebColors.surfaceCard;
    final border = widget.borderColor ??
        (_hovered ? WebColors.borderHover : WebColors.border);

    return MouseRegion(
      onEnter: widget.enableHover ? (_) => setState(() => _hovered = true) : null,
      onExit: widget.enableHover ? (_) => setState(() => _hovered = false) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        margin: widget.margin,
        padding: widget.padding,
        transform: widget.enableHover && _hovered
            ? Matrix4.translationValues(0.0, -2.0, 0.0)
            : Matrix4.identity(),
        decoration: BoxDecoration(
          color: _hovered
              ? WebColors.surfaceCardHover
              : bg,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          border: Border.all(color: border, width: 1.0),
          boxShadow: widget.boxShadow ??
              [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.45),
                  blurRadius: _hovered ? 32 : 16,
                  offset: Offset(0, _hovered ? 12 : 4),
                ),
                if (_hovered)
                  BoxShadow(
                    color: WebColors.primary.withValues(alpha: 0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
              ],
        ),
        child: widget.child,
      ),
    );
  }
}
