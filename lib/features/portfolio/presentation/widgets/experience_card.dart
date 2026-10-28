import 'package:flutter/material.dart';
import 'package:connecthub/features/portfolio/data/models/experience_model.dart';
import 'package:connecthub/features/portfolio/presentation/widgets/portfolio_theme.dart';
import 'package:connecthub/features/portfolio/presentation/widgets/glass_card.dart';
import 'package:connecthub/features/portfolio/presentation/widgets/section_empty_state.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Experience Section with Timeline
// ─────────────────────────────────────────────────────────────────────────────
class ExperienceCard extends StatelessWidget {
  final List<ExperienceModel> experience;
  final bool isCurrentUser;
  final VoidCallback onAdd;
  final ValueChanged<ExperienceModel> onEdit;
  final ValueChanged<ExperienceModel> onDelete;

  const ExperienceCard({
    super.key,
    required this.experience,
    required this.isCurrentUser,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
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
                  Icon(Icons.business_center_outlined, color: kPortfolioTextSecondary, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Experience',
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
                  onTap: onAdd,
                  label: 'Add',
                  icon: Icons.add_rounded,
                ),
            ],
          ),
          const SizedBox(height: 14),
          if (experience.isNotEmpty)
            Column(
              children: experience.asMap().entries.map((entry) {
                final exp = entry.value;
                final isLast = entry.key == experience.length - 1;
                return ExperienceTimelineItem(
                  exp: exp,
                  isLast: isLast,
                  isCurrentUser: isCurrentUser,
                  onEdit: () => onEdit(exp),
                  onDelete: () => onDelete(exp),
                );
              }).toList(),
            )
          else
            PortfolioSectionEmptyState(
              icon: Icons.business_center_outlined,
              title: 'No experience added.',
              subtitle: 'Add your past work history, internships, or freelance roles.',
              actionLabel: isCurrentUser ? 'Add Experience' : null,
              onAction: isCurrentUser ? onAdd : null,
            ),
        ],
      ),
    );
  }
}

class ExperienceTimelineItem extends StatelessWidget {
  final ExperienceModel exp;
  final bool isLast;
  final bool isCurrentUser;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ExperienceTimelineItem({
    super.key,
    required this.exp,
    required this.isLast,
    required this.isCurrentUser,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 5),
                decoration: BoxDecoration(
                  color: kPortfolioAccent,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: kPortfolioAccent.withValues(alpha: 0.25), blurRadius: 4),
                  ],
                ),
              ),
              if (!isLast) Container(width: 1.2, height: 50, color: kPortfolioCardBorder),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        exp.role,
                        style: TextStyle(
                          color: kPortfolioTextPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (isCurrentUser)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: onEdit,
                            child: Icon(Icons.edit_outlined, size: 14, color: kPortfolioTextMuted),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: onDelete,
                            child: const Icon(Icons.delete_outline_rounded, size: 14, color: Color(0xFFEF4444)),
                          ),
                        ],
                      ),
                  ],
                ),
                Text(
                  exp.company,
                  style: TextStyle(color: kPortfolioAccent, fontSize: 12.5, fontWeight: FontWeight.w500),
                ),
                if (exp.description.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    exp.description,
                    style: TextStyle(color: kPortfolioTextSecondary, fontSize: 12, height: 1.45),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
