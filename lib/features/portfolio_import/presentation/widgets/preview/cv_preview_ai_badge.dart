import 'package:flutter/material.dart';
import 'package:connecthub/core/utils/app_theme.dart';

class CvPreviewAiBadge extends StatelessWidget {
  final int projectCount;
  final int experienceCount;
  final int skillCount;

  const CvPreviewAiBadge({
    super.key,
    required this.projectCount,
    required this.experienceCount,
    required this.skillCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1C18) : const Color(0xFFFAF7F2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: primary.withValues(alpha: isDark ? 0.35 : 0.25),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.auto_awesome_rounded, color: primary, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Parsed by Gemini AI',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                    fontSize: 14.5,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '$experienceCount experience · $projectCount projects · $skillCount skills extracted',
                  style: TextStyle(
                    color: isDark ? const Color(0xFFC7BFB5) : const Color(0xFF4B453F),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: primary.withValues(alpha: isDark ? 0.22 : 0.12),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: primary.withValues(alpha: isDark ? 0.4 : 0.25),
                width: 0.8,
              ),
            ),
            child: Text(
              'REVIEW',
              style: TextStyle(
                color: isDark ? AppColors.darkPrimaryLight : AppColors.lightPrimaryDark,
                fontWeight: FontWeight.w800,
                fontSize: 10.5,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
