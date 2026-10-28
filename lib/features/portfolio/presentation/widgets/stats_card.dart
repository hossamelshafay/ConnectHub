import 'package:flutter/material.dart';
import 'package:connecthub/features/portfolio/data/models/experience_model.dart';
import 'package:connecthub/features/portfolio/presentation/widgets/portfolio_theme.dart';
import 'package:connecthub/features/portfolio/presentation/widgets/glass_card.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Statistics Card (Projects, Years Exp, Certificates, Skills)
// ─────────────────────────────────────────────────────────────────────────────
class StatsCard extends StatelessWidget {
  final int projectsCount;
  final String experienceYears;
  final int certsCount;
  final int skillsCount;

  const StatsCard({
    super.key,
    required this.projectsCount,
    required this.experienceYears,
    required this.certsCount,
    required this.skillsCount,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      radius: kPortfolioRadius,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildItem('$projectsCount', 'Projects'),
          _buildDivider(),
          _buildItem(experienceYears, 'Years Exp'),
          _buildDivider(),
          _buildItem('$certsCount', 'Certificates'),
          _buildDivider(),
          _buildItem('$skillsCount', 'Skills'),
        ],
      ),
    );
  }

  Widget _buildItem(String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            color: kPortfolioTextPrimary,
            fontSize: 16.5,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: kPortfolioTextMuted,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 20,
      color: kPortfolioCardBorder,
    );
  }

  static String calculateExperienceYears(List<ExperienceModel> exps) {
    if (exps.isEmpty) return '0';
    int totalMonths = 0;
    final now = DateTime.now();
    for (final e in exps) {
      if (e.startDate != null) {
        final end = (e.isCurrent || e.endDate == null) ? now : (e.endDate ?? now);
        final diff = end.difference(e.startDate!);
        if (diff.inDays > 0) {
          totalMonths += (diff.inDays / 30.44).round();
        }
      }
    }
    if (totalMonths <= 0) {
      return exps.length.toString();
    }
    final years = totalMonths / 12;
    if (years < 1) return '<1';
    return years >= 10 ? '${years.round()}+' : years.toStringAsFixed(years % 1 == 0 ? 0 : 1);
  }
}
