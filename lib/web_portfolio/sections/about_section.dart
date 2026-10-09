import 'package:flutter/material.dart';
import '../theme/web_colors.dart';
import '../theme/web_text_styles.dart';
import '../theme/web_theme.dart';
import '../models/portfolio_view_data.dart';
import '../widgets/responsive_container.dart';
import '../widgets/web_section_header.dart';
import '../widgets/glass_card.dart';
import '../animations/entrance_fader.dart';
import '../responsive/responsive.dart';

/// About Section showcasing engineering values, architecture pillars, and background.
class AboutSection extends StatelessWidget {
  final PortfolioViewData data;
  final bool isDark;

  const AboutSection({
    super.key,
    required this.data,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = WebTheme.isMobile(context);

    final pillars = [
      _PillarItem(
        icon: Icons.architecture_rounded,
        title: 'Clean Architecture',
        description:
            'Strict separation of concerns via Presentation, Domain, and Data layers. '
            'Isolated business logic with high test coverage and zero vendor lock-in.',
      ),
      _PillarItem(
        icon: Icons.speed_rounded,
        title: 'Performance & 120 FPS',
        description:
            'Laser focus on smooth rendering, memory footprint profiling, '
            'efficient widget rebuilding, and eliminating frame drops on all devices.',
      ),
      _PillarItem(
        icon: Icons.design_services_outlined,
        title: 'Pixel-Perfect UI/UX',
        description:
            'Translating complex design systems into responsive, fluid interfaces '
            'with delightful micro-interactions, typography hierarchy, and accessibility.',
      ),
      _PillarItem(
        icon: Icons.sync_alt_rounded,
        title: 'Reactive State & Cloud',
        description:
            'Reliable state management using BLoC & streams, offline-first data caching, '
            'and robust cloud integrations with Firebase and modern REST/GraphQL APIs.',
      ),
    ];

    return ResponsiveContainer(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16.0 : 48.0,
        vertical: isMobile ? 40.0 : 80.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WebSectionHeader(
            eyebrow: 'Engineering Philosophy',
            title: 'Precision, Scalability & Architecture',
            subtitle:
                'I build resilient, production-ready cross-platform systems with an obsession for '
                'architectural purity, smooth user experiences, and maintainable codebases.',
            isDark: isDark,
          ),

          // Core Pillars Adaptive Grid
          ResponsiveGrid(
            maxCrossAxisExtent: 280,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              for (int i = 0; i < pillars.length; i++)
                _buildPillarCard(pillars[i], i),
            ],
          ),

          const SizedBox(height: 36),

          // Bio Summary Card
          EntranceFader(
            delay: const Duration(milliseconds: 300),
            child: GlassCard(
              backgroundColor: isDark ? WebColors.surfaceCard : WebColors.lightSurface,
              borderColor: isDark ? WebColors.border : WebColors.lightBorder,
              padding: EdgeInsets.all(isMobile ? 20 : 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: WebColors.accent,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          'Background & Engineering Journey',
                          style: WebTextStyles.cardTitle(isDark: isDark).copyWith(fontSize: 18),
                          softWrap: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    (data.user.about != null && data.user.about!.trim().isNotEmpty)
                        ? data.user.about!
                        : (data.user.bio ?? ''),
                    style: WebTextStyles.bodyMedium(isDark: isDark).copyWith(height: 1.7),
                    softWrap: true,
                  ),
                  const SizedBox(height: 24),
                  Wrap(
                    spacing: 20,
                    runSpacing: 12,
                    children: [
                      _buildDetailItem(Icons.location_on_outlined, 'Location', data.user.location ?? 'Remote'),
                      _buildDetailItem(Icons.work_outline_rounded, 'Role', data.user.headline ?? 'Software Engineer'),
                      _buildDetailItem(Icons.verified_outlined, 'Status', 'Open to opportunities'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPillarCard(_PillarItem item, int index) {
    return EntranceFader(
      delay: Duration(milliseconds: 90 * index),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: isDark ? WebColors.surfaceCard : WebColors.lightSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? WebColors.border : WebColors.lightBorder,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: WebColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: WebColors.primary.withValues(alpha: 0.25),
                ),
              ),
              child: Icon(
                item.icon,
                color: WebColors.primaryLight,
                size: 24,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              item.title,
              style: WebTextStyles.cardTitle(isDark: isDark).copyWith(fontSize: 17),
            ),
            const SizedBox(height: 10),
            Text(
              item.description,
              style: WebTextStyles.bodySmall(isDark: isDark).copyWith(
                height: 1.6,
                color: isDark ? WebColors.textSecondary : WebColors.lightTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: WebColors.accent,
        ),
        const SizedBox(width: 8),
        Flexible(
          child: RichText(
            softWrap: true,
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$label: ',
                  style: WebTextStyles.bodySmall(isDark: isDark).copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark ? WebColors.textSecondary : WebColors.lightTextSecondary,
                  ),
                ),
                TextSpan(
                  text: value,
                  style: WebTextStyles.bodySmall(isDark: isDark).copyWith(
                    color: isDark ? WebColors.textPrimary : WebColors.lightTextPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PillarItem {
  final IconData icon;
  final String title;
  final String description;

  _PillarItem({
    required this.icon,
    required this.title,
    required this.description,
  });
}
