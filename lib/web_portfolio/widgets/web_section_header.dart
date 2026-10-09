import 'package:flutter/material.dart';
import '../theme/web_colors.dart';
import '../theme/web_text_styles.dart';
import '../theme/web_theme.dart';
import '../animations/entrance_fader.dart';
import '../animations/gold_shimmer.dart';

/// Luxury section header with gold eyebrow badge, shimmer title, and optional subtitle.
class WebSectionHeader extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String? subtitle;
  final bool isDark;
  final CrossAxisAlignment alignment;

  const WebSectionHeader({
    super.key,
    required this.eyebrow,
    required this.title,
    this.subtitle,
    this.isDark = true,
    this.alignment = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = WebTheme.isMobile(context);

    return EntranceFader(
      offset: const Offset(0, 16),
      child: Column(
        crossAxisAlignment: alignment,
        children: [
          // ── Eyebrow ──────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: WebColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(4),
              border: const Border.fromBorderSide(
                BorderSide(color: WebColors.border, width: 1),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 5,
                  height: 5,
                  decoration: const BoxDecoration(
                    color: WebColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    eyebrow.toUpperCase(),
                    style: WebTextStyles.sectionSubtitle(isDark: isDark),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // ── Shimmer Section Title ─────────────────────────────────────────
          GoldShimmerText(
            duration: const Duration(milliseconds: 4500),
            child: Text(
              title,
              style: isMobile
                  ? WebTextStyles.sectionTitleMobile(isDark: isDark)
                  : WebTextStyles.sectionTitle(isDark: isDark),
            ),
          ),

          // ── Optional Subtitle ────────────────────────────────────────────
          if (subtitle != null) ...[
            const SizedBox(height: 14),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Text(
                subtitle!,
                style: WebTextStyles.bodyLarge(isDark: isDark).copyWith(
                  height: 1.7,
                  fontSize: isMobile ? 15 : 16,
                ),
              ),
            ),
          ],
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
