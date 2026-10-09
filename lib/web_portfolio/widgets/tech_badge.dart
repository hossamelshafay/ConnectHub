import 'package:flutter/material.dart';
import '../theme/web_colors.dart';
import '../theme/web_text_styles.dart';

/// Minimal pill-style tech tag with gold border and text.
class TechBadge extends StatelessWidget {
  final String label;
  final bool isDark;

  const TechBadge({
    super.key,
    required this.label,
    this.isDark = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: WebColors.primary.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: WebColors.border,
          width: 1.0,
        ),
      ),
      child: Text(
        label,
        style: WebTextStyles.techChip(isDark: isDark).copyWith(
          color: WebColors.primaryLight,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
