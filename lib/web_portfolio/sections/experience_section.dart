import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../features/portfolio/data/models/experience_model.dart';
import '../theme/web_colors.dart';
import '../theme/web_text_styles.dart';
import '../theme/web_theme.dart';
import '../models/portfolio_view_data.dart';
import '../widgets/responsive_container.dart';
import '../widgets/web_section_header.dart';
import '../widgets/tech_badge.dart';
import '../widgets/section_empty_state.dart';
import '../animations/entrance_fader.dart';
import '../animations/hover_tilt_card.dart';

/// Experience Section featuring a modern vertical timeline layout.
class ExperienceSection extends StatelessWidget {
  final PortfolioViewData data;
  final bool isDark;

  const ExperienceSection({
    super.key,
    required this.data,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
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
            eyebrow: 'Experience',
            title: 'Experience',
            subtitle: null,
            isDark: isDark,
          ),

          if (data.experiences.isEmpty)
            SectionEmptyState(
              icon: Icons.work_outline_rounded,
              message: 'No experience added yet.',
              isDark: isDark,
            )
          else
            // Timeline Container
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: data.experiences.length,
              itemBuilder: (context, index) {
                final exp = data.experiences[index];
                final isLast = index == data.experiences.length - 1;
                return _buildTimelineItem(exp, isLast, index, isMobile);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(
    ExperienceModel exp,
    bool isLast,
    int index,
    bool isMobile,
  ) {
    final dateFormat = DateFormat('MMM yyyy');
    final startDateStr = exp.startDate != null ? dateFormat.format(exp.startDate!) : '';
    final endDateStr = exp.isCurrent
        ? 'Present'
        : (exp.endDate != null ? dateFormat.format(exp.endDate!) : '');
    final periodStr = '$startDateStr — $endDateStr';

    final indicatorWidth = isMobile ? 24.0 : 32.0;
    final cardLeftSpacing = isMobile ? 12.0 : 16.0;

    return EntranceFader(
      delay: Duration(milliseconds: 120 * index),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Timeline line and glowing indicator
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: indicatorWidth,
            child: Column(
              children: [
                SizedBox(height: isMobile ? 20 : 28),
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: exp.isCurrent ? WebColors.primaryLight : WebColors.border,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: exp.isCurrent ? WebColors.primary : WebColors.border,
                      width: 2.0,
                    ),
                    boxShadow: exp.isCurrent
                        ? [
                            BoxShadow(
                              color: WebColors.primaryLight.withValues(alpha: 0.5),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                ),
                const SizedBox(height: 6),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: isDark
                          ? WebColors.border
                          : WebColors.lightBorder,
                    ),
                  ),
              ],
            ),
          ),

          // Experience Card Content (drives the height naturally without any tight vertical constraints)
          Padding(
            padding: EdgeInsets.only(
              left: indicatorWidth + cardLeftSpacing,
              bottom: 28,
            ),
            child: HoverTiltCard(
              backgroundColor: isDark ? WebColors.surfaceCard : WebColors.lightSurface,
              borderColor: isDark ? WebColors.border : WebColors.lightBorder,
              hoverBorderColor: WebColors.accent,
              borderRadius: BorderRadius.circular(16),
              enableScale: true,
              hoverScale: 1.012,
              child: Padding(
                padding: EdgeInsets.all(isMobile ? 16 : 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Role & Current Badge
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                exp.role,
                                style: WebTextStyles.cardTitle(isDark: isDark).copyWith(
                                  fontSize: isMobile ? 17 : 19,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                exp.company,
                                style: WebTextStyles.cardSubtitle(isDark: isDark).copyWith(
                                  color: WebColors.primaryLight,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (exp.isCurrent)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: WebColors.emeraldAccent.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: WebColors.emeraldAccent.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              'Current',
                              style: WebTextStyles.bodySmall(isDark: isDark).copyWith(
                                color: WebColors.emeraldAccent,
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Date and Location Meta with Safe Wrap to prevent overflow on 320px
                    Wrap(
                      spacing: 16,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 260),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.calendar_today_rounded,
                                size: 13,
                                color: isDark ? WebColors.textMuted : WebColors.lightTextMuted,
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  periodStr,
                                  style: WebTextStyles.bodySmall(isDark: isDark).copyWith(fontSize: 12),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (exp.location != null)
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 200),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.location_on_outlined,
                                  size: 13,
                                  color: isDark ? WebColors.textMuted : WebColors.lightTextMuted,
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    exp.location!,
                                    style: WebTextStyles.bodySmall(isDark: isDark).copyWith(fontSize: 12),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // Description
                    Text(
                      exp.description,
                      style: WebTextStyles.bodyMedium(isDark: isDark).copyWith(
                        fontSize: 13.5,
                        height: 1.6,
                      ),
                    ),

                    // Skills chips
                    if (exp.skills.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: exp.skills.map((skill) {
                          return TechBadge(label: skill, isDark: isDark);
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
