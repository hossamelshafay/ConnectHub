import 'package:flutter/material.dart';
import '../theme/web_colors.dart';
import '../theme/web_text_styles.dart';
import '../theme/web_theme.dart';
import '../models/portfolio_view_data.dart';
import '../widgets/responsive_container.dart';
import '../widgets/web_section_header.dart';
import '../widgets/tech_badge.dart';
import '../animations/animated_progress_bar.dart';
import '../animations/entrance_fader.dart';
import '../responsive/responsive.dart';

/// Skills Section featuring animated proficiency bars and categorized skill cards.
class SkillsSection extends StatelessWidget {
  final PortfolioViewData data;
  final bool isDark;

  const SkillsSection({
    super.key,
    required this.data,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = WebTheme.isMobile(context);

    // Group skills by category
    final Map<String, List<SkillItem>> categorizedSkills = {};
    for (var skill in data.skills) {
      categorizedSkills.putIfAbsent(skill.category, () => []).add(skill);
    }

    // Dynamically derive tools & tech ecosystem from Firestore data
    final Set<String> gatheredTools = {};
    for (final p in data.projects) {
      gatheredTools.addAll(p.technologies);
    }
    for (final e in data.experiences) {
      gatheredTools.addAll(e.skills);
    }
    for (final s in data.user.skills) {
      gatheredTools.add(s);
    }
    final toolsAndTech = gatheredTools.toList();

    if (data.skills.isEmpty && toolsAndTech.isEmpty) {
      return const SizedBox.shrink();
    }

    return ResponsiveContainer(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16.0 : 48.0,
        vertical: isMobile ? 40.0 : 80.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WebSectionHeader(
            eyebrow: 'Technical Mastery',
            title: 'Skills & Proficiencies',
            subtitle:
                'Demonstrated core competencies across mobile architecture, reactive state management, '
                'cloud infrastructure, and DevOps pipelines.',
            isDark: isDark,
          ),

          // Categories: Adaptive Grid
          if (categorizedSkills.isNotEmpty)
            ResponsiveGrid(
              maxCrossAxisExtent: 340,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              children: categorizedSkills.entries.map((entry) {
                return _buildSkillCategoryCard(entry.key, entry.value);
              }).toList(),
            ),

          if (toolsAndTech.isNotEmpty) ...[
            const SizedBox(height: 36),

            // Tools & Ecosystem
            EntranceFader(
              delay: const Duration(milliseconds: 250),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(isMobile ? 20 : 28),
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
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: WebColors.accent.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.layers_rounded,
                            color: WebColors.accent,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Flexible(
                          child: Text(
                            'Tools, Libraries & Engineering Ecosystem',
                            style: WebTextStyles.cardTitle(isDark: isDark).copyWith(fontSize: 17),
                            softWrap: true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: toolsAndTech.map((tool) {
                        return TechBadge(label: tool, isDark: isDark);
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSkillCategoryCard(String categoryName, List<SkillItem> skills) {
    return Container(
      padding: const EdgeInsets.all(24),
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
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: WebColors.primaryLight,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  categoryName,
                  style: WebTextStyles.cardTitle(isDark: isDark).copyWith(fontSize: 17),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ...skills.asMap().entries.map((entry) {
            final index = entry.key;
            final skill = entry.value;
            return Padding(
              padding: EdgeInsets.only(bottom: index < skills.length - 1 ? 20 : 0),
              child: AnimatedProgressBar(
                label: skill.name,
                percentage: skill.level,
                delay: Duration(milliseconds: 100 * index),
                isDark: isDark,
              ),
            );
          }),
        ],
      ),
    );
  }
}
