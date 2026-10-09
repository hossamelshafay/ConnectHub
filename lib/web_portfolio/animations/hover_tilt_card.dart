import 'package:flutter/material.dart';
import '../theme/web_colors.dart';

/// A card that smoothly scales, lifts, and glows on mouse hover on desktop/web.
class HoverTiltCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double elevation;
  final double hoverElevation;
  final BorderRadius? borderRadius;
  final Color? borderColor;
  final Color? hoverBorderColor;
  final Color? backgroundColor;
  final bool enableScale;
  final double hoverScale;

  const HoverTiltCard({
    super.key,
    required this.child,
    this.onTap,
    this.elevation = 0,
    this.hoverElevation = 16,
    this.borderRadius,
    this.borderColor,
    this.hoverBorderColor,
    this.backgroundColor,
    this.enableScale = true,
    this.hoverScale = 1.02,
  });

  @override
  State<HoverTiltCard> createState() => _HoverTiltCardState();
}

class _HoverTiltCardState extends State<HoverTiltCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final effectiveBorderRadius = widget.borderRadius ?? BorderRadius.circular(16);
    final defaultBorder = widget.borderColor ?? WebColors.border;
    final hoverBorder = widget.hoverBorderColor ?? WebColors.primary;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: widget.onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: (widget.enableScale && _isHovered) ? widget.hoverScale : 1.0,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          child: AnimatedSlide(
            offset: Offset(0, _isHovered ? -0.015 : 0),
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              decoration: BoxDecoration(
                color: widget.backgroundColor ?? WebColors.surfaceCard,
                borderRadius: effectiveBorderRadius,
                border: Border.all(
                  color: _isHovered ? hoverBorder : defaultBorder,
                  width: _isHovered ? 1.4 : 1.0,
                ),
                boxShadow: [
                  if (_isHovered) ...[
                    BoxShadow(
                      color: WebColors.primary.withValues(alpha: 0.22),
                      blurRadius: 28,
                      offset: const Offset(0, 12),
                      spreadRadius: 2,
                    ),
                    BoxShadow(
                      color: WebColors.accent.withValues(alpha: 0.12),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ] else
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                ],
              ),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}
