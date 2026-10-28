import 'package:flutter/material.dart';
import 'package:connecthub/features/portfolio/data/models/certificate_model.dart';
import 'package:connecthub/features/portfolio/presentation/widgets/portfolio_theme.dart';
import 'package:connecthub/features/portfolio/presentation/widgets/glass_card.dart';
import 'package:connecthub/features/portfolio/presentation/widgets/section_empty_state.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Certificates Section
// ─────────────────────────────────────────────────────────────────────────────
class CertificatesCard extends StatelessWidget {
  final List<CertificateModel> certificates;
  final bool isCurrentUser;
  final VoidCallback onAdd;
  final ValueChanged<CertificateModel> onEdit;
  final ValueChanged<CertificateModel> onDelete;

  const CertificatesCard({
    super.key,
    required this.certificates,
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
                  Icon(Icons.workspace_premium_outlined, color: kPortfolioTextSecondary, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Certificates',
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
          if (certificates.isNotEmpty)
            Column(
              children: certificates.map((cert) {
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
                              cert.title,
                              style: TextStyle(color: kPortfolioTextPrimary, fontSize: 13.5, fontWeight: FontWeight.w600),
                            ),
                            Text(
                              cert.issuingOrganization,
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
                              onTap: () => onEdit(cert),
                              child: Icon(Icons.edit_outlined, size: 14, color: kPortfolioTextMuted),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () => onDelete(cert),
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
              icon: Icons.workspace_premium_outlined,
              title: 'No certificates added.',
              subtitle: 'Display your licenses, courses, and verified credentials.',
              actionLabel: isCurrentUser ? 'Add Certificate' : null,
              onAction: isCurrentUser ? onAdd : null,
            ),
        ],
      ),
    );
  }
}
