import 'package:flutter/material.dart';
import '../theme/web_colors.dart';
import '../models/portfolio_view_data.dart';

/// Currently Learning & Inspiring Quote Card matching the mockup.
class CurrentlyLearningCard extends StatelessWidget {
  final PortfolioViewData data;
  final bool isDark;

  const CurrentlyLearningCard({
    super.key,
    required this.data,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    // Dynamic or curated learning items based on available skills
    final List<Map<String, dynamic>> learningItems = data.skills.isNotEmpty
        ? data.skills.take(3).map((s) => {'name': s.name, 'progress': s.level}).toList()
        : [
            {'name': 'Advanced Architecture', 'progress': 0.75},
            {'name': 'AI & Machine Learning', 'progress': 0.45},
            {'name': 'Distributed Systems', 'progress': 0.30},
          ];

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: isDark ? WebColors.darkSurfaceCard : WebColors.lightSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? WebColors.darkBorder : WebColors.lightBorder,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.035),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: isDark
                      ? WebColors.darkPrimary.withValues(alpha: 0.15)
                      : WebColors.lightPrimary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.menu_book_rounded,
                  size: 20,
                  color: isDark ? WebColors.darkPrimaryLight : WebColors.lightPrimary,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Currently Learning',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: isDark ? WebColors.darkTextPrimary : WebColors.lightTextPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),

          // Progress items
          Column(
            children: learningItems.map((item) {
              final name = item['name'] as String;
              final progress = (item['progress'] as double).clamp(0.0, 1.0);
              final pct = (progress * 100).toInt();

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.play_circle_filled_rounded,
                              size: 16,
                              color: isDark
                                  ? WebColors.darkPrimaryLight.withValues(alpha: 0.8)
                                  : WebColors.lightPrimary.withValues(alpha: 0.85),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              name,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isDark ? WebColors.darkTextPrimary : WebColors.lightTextPrimary,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '$pct%',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                            color: isDark ? WebColors.darkTextMuted : WebColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 5,
                        backgroundColor: isDark
                            ? WebColors.darkSurface
                            : const Color(0xFFEBE5DB),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isDark ? WebColors.darkPrimary : WebColors.lightPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 14),

          // Quote Box at bottom
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.format_quote_rounded,
                  size: 26,
                  color: isDark
                      ? WebColors.darkPrimary.withValues(alpha: 0.75)
                      : WebColors.lightPrimary.withValues(alpha: 0.7),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Better tools',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                          color: isDark ? WebColors.darkTextPrimary : const Color(0xFF3B342E),
                        ),
                      ),
                      Text(
                        'Build better ideas',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          height: 1.3,
                          color: isDark ? WebColors.darkTextMuted : WebColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
