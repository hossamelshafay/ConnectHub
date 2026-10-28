import 'package:flutter/material.dart';
import 'package:connecthub/features/portfolio/data/models/education_model.dart';
import 'package:connecthub/features/portfolio/presentation/widgets/portfolio_theme.dart';
import 'package:connecthub/features/portfolio/presentation/widgets/glass_card.dart';
import 'package:connecthub/features/portfolio/presentation/widgets/section_empty_state.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Education Section
// ─────────────────────────────────────────────────────────────────────────────
class EducationCard extends StatelessWidget {
  final List<EducationModel> education;
  final bool isCurrentUser;
  final VoidCallback onAdd;
  final ValueChanged<EducationModel> onEdit;
  final ValueChanged<EducationModel> onDelete;

  const EducationCard({
    super.key,
    required this.education,
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
                  Icon(Icons.school_outlined, color: kPortfolioTextSecondary, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Education',
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
          const SizedBox(height: 12),
          if (education.isNotEmpty)
            Column(
              children: education.map((edu) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              edu.degree,
                              style: TextStyle(color: kPortfolioTextPrimary, fontSize: 13.5, fontWeight: FontWeight.w600),
                            ),
                            Text(
                              edu.institution,
                              style: TextStyle(color: kPortfolioAccent, fontSize: 12, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                      if (isCurrentUser)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onTap: () => onEdit(edu),
                              child: Icon(Icons.edit_outlined, size: 14, color: kPortfolioTextMuted),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () => onDelete(edu),
                              child: const Icon(Icons.delete_outline_rounded, size: 14, color: Color(0xFFEF4444)),
                            ),
                          ],
                        ),
                    ],
                  ),
                );
              }).toList(),
            )
          else
            PortfolioSectionEmptyState(
              icon: Icons.school_outlined,
              title: 'No education added.',
              subtitle: 'List your degree, university, or academic certifications.',
              actionLabel: isCurrentUser ? 'Add Education' : null,
              onAction: isCurrentUser ? onAdd : null,
            ),
        ],
      ),
    );
  }
}
