import 'package:flutter/material.dart';
import '../theme/web_colors.dart';
import '../theme/web_text_styles.dart';
import '../animations/gold_shimmer.dart';

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
            gradient: WebColors.primaryGradient,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: WebColors.primary.withValues(alpha: _isHovered ? 0.40 : 0.20),
                blurRadius: _isHovered ? 24 : 10,
                offset: Offset(0, _isHovered ? 8 : 3),
              ),
            ],
          ),
          child: GoldShimmerSurface(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.label,
                  style: WebTextStyles.buttonText(),
                ),
                if (widget.icon != null) ...[
                  const SizedBox(width: 8),
                  Icon(
                    widget.icon,
                    size: 16,
                    color: WebColors.textDark,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Secondary button: transparent with gold border; fills on hover.
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
                ? WebColors.primary.withValues(alpha: 0.10)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _isHovered ? WebColors.primaryLight : WebColors.border,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.label,
                style: WebTextStyles.buttonText().copyWith(
                  color: _isHovered
                      ? WebColors.primaryLight
                      : WebColors.textSecondary,
                ),
              ),
              if (widget.icon != null) ...[
                const SizedBox(width: 8),
                Icon(
                  widget.icon,
                  size: 16,
                  color: _isHovered
                      ? WebColors.primaryLight
                      : WebColors.textSecondary,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
