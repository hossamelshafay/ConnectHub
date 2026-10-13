import 'package:flutter/material.dart';
import '../theme/web_colors.dart';
import '../theme/web_text_styles.dart';
import '../theme/web_theme.dart';
import '../models/portfolio_view_data.dart';
import '../widgets/responsive_container.dart';
import '../widgets/web_section_header.dart';
import '../widgets/glass_card.dart';
import '../widgets/section_empty_state.dart';
import '../animations/entrance_fader.dart';

/// About Section showcasing background, bio, and engineering pillars.
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

    final aboutText = (data.user.about != null && data.user.about!.trim().isNotEmpty)
        ? data.user.about!.trim()
        : (data.user.bio != null && data.user.bio!.trim().isNotEmpty)
            ? data.user.bio!.trim()
            : null;

    final bool isEmpty = aboutText == null;

    final locationText = (data.user.location != null && data.user.location!.trim().isNotEmpty)
        ? data.user.location!.trim()
        : null;

    final roleText = (data.user.headline != null && data.user.headline!.trim().isNotEmpty)
        ? data.user.headline!.trim()
        : null;

    return ResponsiveContainer(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16.0 : 48.0,
        vertical: isMobile ? 40.0 : 80.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WebSectionHeader(
            eyebrow: 'About',
            title: 'About',
            subtitle: null,
            isDark: isDark,
          ),

          if (isEmpty)
            SectionEmptyState(
              icon: Icons.person_outline_rounded,
              message: 'No information provided yet.',
              isDark: isDark,
            )
          else ...[
            // Bio Summary Card
            EntranceFader(
              delay: const Duration(milliseconds: 200),
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
                            'Background & Professional Journey',
                            style: WebTextStyles.cardTitle(isDark: isDark).copyWith(fontSize: 18),
                            softWrap: true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      aboutText,
                      style: WebTextStyles.bodyMedium(isDark: isDark).copyWith(height: 1.7),
                      softWrap: true,
                    ),
                    if (locationText != null || roleText != null) ...[
                      const SizedBox(height: 24),
                      Wrap(
                        spacing: 20,
                        runSpacing: 12,
                        children: [
                          if (locationText != null)
                            _buildDetailItem(
                              Icons.location_on_outlined,
                              'Location',
                              locationText,
                            ),
                          if (roleText != null)
                            _buildDetailItem(
                              Icons.work_outline_rounded,
                              'Role',
                              roleText,
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ],
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

