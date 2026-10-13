import 'package:flutter/material.dart';
import '../theme/web_colors.dart';
import '../theme/web_text_styles.dart';
import '../theme/web_theme.dart';
import '../animations/entrance_fader.dart';

/// Luxury minimalist empty state card for web portfolio sections.
/// Renders clean, professional empty states when real Firebase user data is absent.
class SectionEmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final bool isDark;

  const SectionEmptyState({
    super.key,
    required this.icon,
    required this.message,
    this.isDark = true,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = WebTheme.isMobile(context);

    return EntranceFader(
      offset: const Offset(0, 10),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 20.0 : 36.0,
          vertical: isMobile ? 32.0 : 48.0,
        ),
        decoration: BoxDecoration(
          color: isDark ? WebColors.surfaceCard : WebColors.lightSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? WebColors.border : WebColors.lightBorder,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: WebColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
                border: Border.all(
                  color: WebColors.primary.withValues(alpha: 0.20),
                  width: 1,
                ),
              ),
              child: Icon(
                icon,
                size: isMobile ? 26 : 32,
                color: WebColors.primaryLight,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              message,
              style: WebTextStyles.bodyMedium(isDark: isDark).copyWith(
                fontSize: isMobile ? 14 : 15,
                color: isDark ? WebColors.textMuted : WebColors.lightTextMuted,
                fontWeight: FontWeight.w400,
                letterSpacing: 0.2,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
