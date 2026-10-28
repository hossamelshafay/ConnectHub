import 'package:flutter/material.dart';
import 'package:connecthub/core/utils/app_theme.dart';
import 'package:connecthub/features/portfolio/presentation/widgets/portfolio_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Premium Subtle Glass Card (Titanium Tinted Surface with Soft Glass Blur)
// ─────────────────────────────────────────────────────────────────────────────
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.radius = kPortfolioRadius,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: kPortfolioCardBg,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: kPortfolioCardBorder, width: 1),
          boxShadow: kPortfolioSoftShadow,
        ),
        padding: padding,
        child: child,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Frosted Circle Glass Button (Back, Share, More)
// ─────────────────────────────────────────────────────────────────────────────
class CircleGlassButton extends StatelessWidget {
  final IconData icon;
  final double size;
  final VoidCallback onTap;

  const CircleGlassButton({
    super.key,
    required this.icon,
    this.size = 18,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: kPortfolioGlassButtonBg,
          shape: BoxShape.circle,
          border: Border.all(color: kPortfolioCardBorder, width: 1),
          boxShadow: kPortfolioSoftShadow,
        ),
        child: Center(
          child: Icon(icon, color: kPortfolioTextPrimary, size: size),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Refined Action Glass Button (Message, GitHub, Social Profile)
// ─────────────────────────────────────────────────────────────────────────────
class ActionGlassButton extends StatelessWidget {
  final IconData? icon;
  final Widget? customIcon;
  final String label;
  final IconData trailing;
  final VoidCallback onTap;

  const ActionGlassButton({
    super.key,
    this.icon,
    this.customIcon,
    required this.label,
    required this.trailing,
    required this.onTap,
  }) : assert(icon != null || customIcon != null);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 46,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: kPortfolioGlassButtonBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: kPortfolioCardBorder, width: 1),
          boxShadow: kPortfolioSoftShadow,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
                Flexible(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 18,
                        height: 18,
                        child: Center(
                          child: customIcon ?? Icon(icon, color: kPortfolioAccent, size: 18),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          label,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            color: kPortfolioTextPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.2,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Icon(trailing, color: kPortfolioTextMuted, size: 14),
              ],
            ),
          ),
        );
      }
}

// ─────────────────────────────────────────────────────────────────────────────
// Compact Tech / Link Glass Chip
// ─────────────────────────────────────────────────────────────────────────────
class MiniGlassChip extends StatelessWidget {
  final IconData? icon;
  final Widget? customIcon;
  final String label;
  final VoidCallback? onTap;
  final bool accentGlow;

  const MiniGlassChip({
    super.key,
    this.icon,
    this.customIcon,
    required this.label,
    this.onTap,
    this.accentGlow = false,
  }) : assert(icon != null || customIcon != null);

  @override
  Widget build(BuildContext context) {
    final iconColor = accentGlow ? kPortfolioAccent : kPortfolioTextSecondary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: accentGlow ? kPortfolioAccent.withValues(alpha: 0.14) : kPortfolioChipBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: accentGlow ? kPortfolioAccent.withValues(alpha: 0.45) : kPortfolioChipBorder,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 13,
              height: 13,
              child: Center(
                child: customIcon ?? Icon(icon, size: 13, color: iconColor),
              ),
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                color: accentGlow ? kPortfolioAccent : kPortfolioTextSecondary,
                fontSize: 11.5,
                fontWeight: accentGlow ? FontWeight.w600 : FontWeight.w500,
                letterSpacing: -0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Redesigned Pill Edit Button (Matching Mockup Warm Titanium Pill)
// ─────────────────────────────────────────────────────────────────────────────
class PillEditButton extends StatelessWidget {
  final VoidCallback onTap;
  final String label;
  final IconData icon;

  const PillEditButton({
    super.key,
    required this.onTap,
    this.label = 'Edit',
    this.icon = Icons.edit_outlined,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark;
    final bgGradient = isDark
        ? const LinearGradient(
            colors: [Color(0x55352E28), Color(0x402A241F)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : const LinearGradient(
            colors: [Color(0xEEF3EBE0), Color(0xDEEAE0D2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );

    final border = isDark
        ? const Color(0x40FFFFFF)
        : const Color(0x80D4C5B0);
    final textCol = isDark
        ? AppColors.primary
        : const Color(0xFF6B5842);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5.5),
        decoration: BoxDecoration(
          gradient: bgGradient,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: border, width: 0.9),
          boxShadow: [
            BoxShadow(
              color: isDark ? const Color(0x20000000) : const Color(0x1055402A),
              blurRadius: 4,
              offset: const Offset(0, 1.5),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12.5, color: textCol),
            const SizedBox(width: 4.5),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                color: textCol,
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
