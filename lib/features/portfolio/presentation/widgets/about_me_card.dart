import 'package:flutter/material.dart';
import 'package:connecthub/features/profile/data/models/user_model.dart';
import 'package:connecthub/features/portfolio/presentation/widgets/portfolio_theme.dart';
import 'package:connecthub/features/portfolio/presentation/widgets/glass_card.dart';
import 'package:connecthub/features/portfolio/presentation/widgets/section_empty_state.dart';

// ─────────────────────────────────────────────────────────────────────────────
// About Me Card (Expandable Preview with Read More / Show Less)
// ─────────────────────────────────────────────────────────────────────────────
class AboutMeCard extends StatefulWidget {
  final UserModel user;
  final bool isCurrentUser;
  final VoidCallback onEdit;

  const AboutMeCard({
    super.key,
    required this.user,
    required this.isCurrentUser,
    required this.onEdit,
  });

  @override
  State<AboutMeCard> createState() => _AboutMeCardState();
}

class _AboutMeCardState extends State<AboutMeCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final bioText = widget.user.about?.trim() ?? '';
    final hasBio = bioText.isNotEmpty;
    final isLong = bioText.length > 160;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.person_outline_rounded, color: kPortfolioTextSecondary, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'About',
                    style: TextStyle(
                      color: kPortfolioTextPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
              if (widget.isCurrentUser && hasBio)
                PillEditButton(onTap: widget.onEdit),
            ],
          ),
          const SizedBox(height: 12),
          if (hasBio) ...[
            Text(
              bioText,
              maxLines: _isExpanded ? null : 3,
              overflow: _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
              style: TextStyle(
                color: kPortfolioTextSecondary,
                fontSize: 13,
                height: 1.5,
              ),
            ),
            if (isLong) ...[
              const SizedBox(height: 6),
              GestureDetector(
                onTap: () => setState(() => _isExpanded = !_isExpanded),
                child: Text(
                  _isExpanded ? 'Show less' : 'Read more',
                  style: TextStyle(
                    color: kPortfolioAccent,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ] else
            PortfolioSectionEmptyState(
              icon: Icons.person_outline_rounded,
              title: 'Add a short professional summary.',
              subtitle: 'Highlight your background, passion, and what drives you.',
              actionLabel: widget.isCurrentUser ? 'Add Summary' : null,
              onAction: widget.isCurrentUser ? widget.onEdit : null,
            ),
        ],
      ),
    );
  }
}
