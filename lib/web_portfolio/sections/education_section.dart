import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../features/portfolio/data/models/education_model.dart';
import '../theme/web_colors.dart';
import '../theme/web_text_styles.dart';
import '../theme/web_theme.dart';
import '../models/portfolio_view_data.dart';
import '../widgets/responsive_container.dart';
import '../widgets/web_section_header.dart';
import '../animations/entrance_fader.dart';

/// Education Section highlighting academic background and honors.
class EducationSection extends StatelessWidget {
  final PortfolioViewData data;
  final bool isDark;

  const EducationSection({
    super.key,
    required this.data,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    if (data.educations.isEmpty) {
      return const SizedBox.shrink();
    }
    final isMobile = WebTheme.isMobile(context);

    return ResponsiveContainer(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16.0 : 48.0,
        vertical: isMobile ? 40.0 : 80.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WebSectionHeader(
            eyebrow: 'Academics',
            title: 'Education & Foundation',
            subtitle:
                'Strong computer science foundation covering algorithms, distributed architectures, '
                'systems engineering, and software verification.',
            isDark: isDark,
          ),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: data.educations.length,
            itemBuilder: (context, index) {
              final edu = data.educations[index];
              return _buildEducationCard(edu, index, isMobile);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEducationCard(EducationModel edu, int index, bool isMobile) {
    final dateFormat = DateFormat('yyyy');
    final startStr = edu.startDate != null ? dateFormat.format(edu.startDate!) : '';
    final endStr = edu.endDate != null ? dateFormat.format(edu.endDate!) : 'Present';
    final periodStr = '$startStr — $endStr';

    return EntranceFader(
      delay: Duration(milliseconds: 120 * index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: EdgeInsets.all(isMobile ? 18 : 28),
        decoration: BoxDecoration(
          color: isDark ? WebColors.surfaceCard : WebColors.lightSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? WebColors.border : WebColors.lightBorder,
            width: 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Graduation Cap Icon Box
            Container(
              padding: EdgeInsets.all(isMobile ? 10 : 14),
              decoration: BoxDecoration(
                color: WebColors.accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: WebColors.accent.withValues(alpha: 0.3),
                ),
              ),
              child: Icon(
                Icons.school_rounded,
                color: WebColors.accent,
                size: isMobile ? 22 : 26,
              ),
            ),
            SizedBox(width: isMobile ? 12 : 20),

            // Degree & Institution Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isMobile) ...[
                    Text(
                      edu.degree,
                      style: WebTextStyles.cardTitle(isDark: isDark).copyWith(
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: WebColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        periodStr,
                        style: WebTextStyles.bodySmall(isDark: isDark).copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                          color: WebColors.primaryLight,
                        ),
                      ),
                    ),
                  ] else ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            edu.degree,
                            style: WebTextStyles.cardTitle(isDark: isDark).copyWith(
                              fontSize: 19,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: WebColors.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            periodStr,
                            style: WebTextStyles.bodySmall(isDark: isDark).copyWith(
                              fontWeight: FontWeight.w600,
                              color: WebColors.primaryLight,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    edu.institution,
                    style: WebTextStyles.cardSubtitle(isDark: isDark).copyWith(
                      color: isDark ? WebColors.textSecondary : WebColors.lightTextSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (edu.fieldOfStudy != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      edu.fieldOfStudy!,
                      style: WebTextStyles.bodySmall(isDark: isDark).copyWith(
                        color: WebColors.primaryLight,
                      ),
                    ),
                  ],
                  if (edu.grade != null) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(
                          Icons.workspace_premium_rounded,
                          size: 16,
                          color: WebColors.secondaryAccent,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            edu.grade!,
                            style: WebTextStyles.bodySmall(isDark: isDark).copyWith(
                              color: WebColors.secondaryAccent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (edu.description != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      edu.description!,
                      style: WebTextStyles.bodyMedium(isDark: isDark).copyWith(
                        fontSize: 13.5,
                        height: 1.6,
                      ),
                    ),
                  ],
                  if (edu.activities != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Activities: ${edu.activities!}',
                      style: WebTextStyles.bodySmall(isDark: isDark).copyWith(
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
