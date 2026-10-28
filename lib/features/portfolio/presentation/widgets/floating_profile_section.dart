import 'package:flutter/material.dart';
import 'package:connecthub/core/utils/app_widgets.dart';
import 'package:connecthub/features/profile/data/models/user_model.dart';
import 'package:connecthub/features/portfolio/presentation/widgets/portfolio_theme.dart';
import 'package:connecthub/features/portfolio/presentation/widgets/glass_card.dart';
import 'package:connecthub/features/portfolio/presentation/widgets/contact_card.dart';
import 'package:connecthub/features/profile/presentation/widgets/social_icons.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Floating Profile Header Section
// ─────────────────────────────────────────────────────────────────────────────
class FloatingProfileSection extends StatelessWidget {
  final UserModel user;
  final bool isCurrentUser;
  final VoidCallback? onEdit;
  final VoidCallback? onAddContactInfo;

  const FloatingProfileSection({
    super.key,
    required this.user,
    required this.isCurrentUser,
    this.onEdit,
    this.onAddContactInfo,
  });

  @override
  Widget build(BuildContext context) {
    final hasHeadline = user.headline != null && user.headline!.trim().isNotEmpty;
    final headline = hasHeadline
        ? user.headline!.trim()
        : (isCurrentUser ? 'Add a professional headline' : '');

    final hasBio = user.about != null && user.about!.trim().isNotEmpty;
    final bio = hasBio
        ? user.about!.trim()
        : (isCurrentUser ? 'Add a short professional summary' : '');

    final location = user.location?.trim() ?? '';
    final hasWebsite = user.websiteGenerated &&
        (user.websiteUrl != null && user.websiteUrl!.trim().isNotEmpty);
    final activeSocial = user.socialLinks.activeLinks;
    final hasAnyChips = location.isNotEmpty || activeSocial.isNotEmpty || hasWebsite;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // ── Avatar with Clean Border & Online Status ────────────────
        Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: kPortfolioCardBorder, width: 1.5),
                boxShadow: kPortfolioSoftShadow,
              ),
              child: UserAvatar(
                name: user.name,
                size: 68,
                imageUrl: user.profileImage,
              ),
            ),
            // Online status indicator
            Positioned(
              right: 2,
              bottom: 2,
              child: Container(
                width: 13,
                height: 13,
                decoration: BoxDecoration(
                  color: const Color(0xFF22C55E),
                  shape: BoxShape.circle,
                  border: Border.all(color: kPortfolioCardBg, width: 2),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x3022C55E),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(width: 14),

        // ── Name, Role, Bio & Compact Chips ─────────────────────────
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      user.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: kPortfolioTextPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.4,
                        height: 1.2,
                      ),
                    ),
                  ),
                  if (isCurrentUser && onEdit != null) ...[
                    const SizedBox(width: 8),
                    PillEditButton(onTap: onEdit!),
                  ],
                ],
              ),
              if (headline.isNotEmpty) ...[
                const SizedBox(height: 3),
                Text(
                  headline,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: hasHeadline ? kPortfolioTextSecondary : kPortfolioTextMuted,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.1,
                    fontStyle: hasHeadline ? FontStyle.normal : FontStyle.italic,
                  ),
                ),
              ],
              if (bio.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  bio,
                  style: TextStyle(
                    color: kPortfolioTextMuted,
                    fontSize: 12,
                    fontStyle: hasBio ? FontStyle.normal : FontStyle.italic,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (hasAnyChips || isCurrentUser) ...[
                const SizedBox(height: 8),
                // ── Compact Tech Chips ───────────────────────────────
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      if (location.isNotEmpty) ...[
                        MiniGlassChip(
                          icon: Icons.location_on_outlined,
                          label: location,
                        ),
                        const SizedBox(width: 6),
                      ],
                      if (hasWebsite) ...[
                        MiniGlassChip(
                          icon: Icons.language_rounded,
                          label: 'Website',
                          accentGlow: true,
                          onTap: () => ContactCard.launchUrlSafe(context, user.websiteUrl!),
                        ),
                        const SizedBox(width: 6),
                      ],
                      ...activeSocial.where((s) => !hasWebsite || s.key != 'website').map((item) {
                        final meta = SocialPlatformRegistry.get(item.key);
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: MiniGlassChip(
                            customIcon: meta.iconBuilder(context, size: 13, color: kPortfolioTextSecondary),
                            icon: ContactCard.getPlatformIcon(item.key),
                            label: item.title,
                            onTap: () => ContactCard.launchUrlSafe(context, item.url),
                          ),
                        );
                      }),
                      if (!hasAnyChips && isCurrentUser && onAddContactInfo != null)
                        MiniGlassChip(
                          icon: Icons.add_rounded,
                          label: 'Add contact info',
                          onTap: onAddContactInfo,
                        ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
