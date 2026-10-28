import 'package:flutter/material.dart';
import '../theme/web_colors.dart';

/// Luxury gold CTA button with shimmer sweep and hover elevation.
class AnimatedGlowButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onTap;
  final bool isSecondary;
  final bool isDark;

  const AnimatedGlowButton({
    super.key,
    required this.label,
    this.icon,
    required this.onTap,
    this.isSecondary = false,
    this.isDark = true,
  });

  @override
  State<AnimatedGlowButton> createState() => _AnimatedGlowButtonState();
}

class _AnimatedGlowButtonState extends State<AnimatedGlowButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    if (widget.isSecondary) {
      return _buildSecondaryButton();
    }
    return _buildPrimaryButton();
  }

  /// Primary button: gold gradient fill with shimmer sweep.
  Widget _buildPrimaryButton() {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
          decoration: BoxDecoration(
            color: widget.isDark ? WebColors.darkPrimary : WebColors.lightPrimary,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: (widget.isDark ? WebColors.darkPrimary : WebColors.lightPrimary)
                    .withValues(alpha: _isHovered ? 0.38 : 0.20),
                blurRadius: _isHovered ? 20 : 10,
                offset: Offset(0, _isHovered ? 6 : 3),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.label,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: widget.isDark ? const Color(0xFF141210) : Colors.white,
                  letterSpacing: -0.2,
                ),
              ),
              if (widget.icon != null) ...[
                const SizedBox(width: 8),
                Icon(
                  widget.icon,
                  size: 16,
                  color: widget.isDark ? const Color(0xFF141210) : Colors.white,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Secondary button: transparent with warm border; fills on hover.
  Widget _buildSecondaryButton() {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
          decoration: BoxDecoration(
            color: _isHovered
                ? (widget.isDark ? WebColors.darkPrimary : WebColors.lightPrimary).withValues(alpha: 0.14)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isHovered
                  ? (widget.isDark ? WebColors.darkPrimaryLight : WebColors.lightPrimary)
                  : (widget.isDark ? WebColors.darkPrimary.withValues(alpha: 0.35) : WebColors.lightBorder),
              width: 1.2,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.label,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _isHovered
                      ? (widget.isDark ? WebColors.darkPrimaryLight : WebColors.lightPrimary)
                      : (widget.isDark ? WebColors.darkTextPrimary : WebColors.lightTextSecondary),
                ),
              ),
              if (widget.icon != null) ...[
                const SizedBox(width: 8),
                Icon(
                  widget.icon,
                  size: 16,
                  color: _isHovered
                      ? (widget.isDark ? WebColors.darkPrimaryLight : WebColors.lightPrimary)
                      : (widget.isDark ? WebColors.darkTextPrimary : WebColors.lightTextSecondary),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
