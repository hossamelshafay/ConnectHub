import 'package:flutter/material.dart';
import 'package:connecthub/features/portfolio/presentation/widgets/portfolio_theme.dart';
import 'package:connecthub/features/portfolio/presentation/widgets/glass_card.dart';
import 'package:connecthub/features/portfolio/presentation/widgets/section_empty_state.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Skills Card with Badges
// ─────────────────────────────────────────────────────────────────────────────
class SkillsCard extends StatelessWidget {
  final List<String> skills;
  final bool isCurrentUser;
  final VoidCallback onEdit;
  final VoidCallback onAdd;

  const SkillsCard({
    super.key,
    required this.skills,
    required this.isCurrentUser,
    required this.onEdit,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.code_rounded, color: kPortfolioTextSecondary, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Skills',
                    style: TextStyle(
                      color: kPortfolioTextPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
              if (isCurrentUser)
                PillEditButton(
                  onTap: onEdit,
                  label: 'Edit',
                  icon: Icons.edit_outlined,
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (skills.isNotEmpty)
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: skills.map((skill) => SkillPillBadge(skill: skill)).toList(),
            )
          else
            PortfolioSectionEmptyState(
              icon: Icons.code_rounded,
              title: 'No skills added yet.',
              subtitle: 'Highlight your technical stack and expertise.',
              actionLabel: isCurrentUser ? 'Add Skills' : null,
              onAction: isCurrentUser ? onAdd : null,
            ),
        ],
      ),
    );
  }
}

class SkillPillBadge extends StatelessWidget {
  final String skill;
  const SkillPillBadge({super.key, required this.skill});

  static IconData iconForSkill(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('python')) return Icons.code_rounded;
    if (lower.contains('machine') || lower.contains('ml')) return Icons.insights_rounded;
    if (lower.contains('deep') || lower.contains('neural')) return Icons.hub_outlined;
    if (lower.contains('flutter') || lower.contains('dart')) return Icons.flutter_dash;
    if (lower.contains('fire')) return Icons.local_fire_department_rounded;
    if (lower.contains('ai') || lower.contains('gen')) return Icons.auto_awesome_rounded;
    return Icons.terminal_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final icon = iconForSkill(skill);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.5, vertical: 4.5),
      decoration: BoxDecoration(
        color: kPortfolioChipBg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: kPortfolioChipBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: kPortfolioAccent),
          const SizedBox(width: 5),
          Text(
            skill,
            style: TextStyle(
              color: kPortfolioTextPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
