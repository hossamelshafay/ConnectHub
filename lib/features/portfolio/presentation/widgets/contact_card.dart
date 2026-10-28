import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:connecthub/features/profile/data/models/user_model.dart';
import 'package:connecthub/features/profile/presentation/widgets/social_icons.dart';
import 'package:connecthub/features/portfolio/presentation/widgets/portfolio_theme.dart';
import 'package:connecthub/features/portfolio/presentation/widgets/glass_card.dart';
import 'package:connecthub/features/portfolio/presentation/widgets/section_empty_state.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Contact & Links Card
// ─────────────────────────────────────────────────────────────────────────────
class ContactCard extends StatelessWidget {
  final UserModel user;
  final bool isCurrentUser;
  final VoidCallback? onEdit;

  const ContactCard({
    super.key,
    required this.user,
    this.isCurrentUser = false,
    this.onEdit,
  });

  static IconData getPlatformIcon(String key) {
    switch (key.toLowerCase()) {
      case 'github':
        return Icons.code_rounded;
      case 'linkedin':
        return Icons.business_center_outlined;
      case 'website':
        return Icons.language_rounded;
      case 'instagram':
        return Icons.camera_alt_outlined;
      case 'twitter':
      case 'x':
        return Icons.alternate_email_rounded;
      case 'facebook':
        return Icons.facebook_rounded;
      case 'behance':
        return Icons.palette_outlined;
      case 'dribbble':
        return Icons.sports_basketball_outlined;
      case 'medium':
        return Icons.article_outlined;
      case 'youtube':
        return Icons.play_circle_outline_rounded;
      case 'tiktok':
        return Icons.music_note_rounded;
      case 'discord':
        return Icons.sports_esports_outlined;
      case 'telegram':
        return Icons.send_rounded;
      default:
        return Icons.link_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final links = user.socialLinks;
    final hasPhone = user.phone != null && user.phone!.trim().isNotEmpty;
    final hasLoc = user.location != null && user.location!.trim().isNotEmpty;
    final activeSocial = links.activeLinks;
    final hasAny = hasPhone || hasLoc || activeSocial.isNotEmpty;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.alternate_email_rounded, color: kPortfolioTextSecondary, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Contact & Links',
                  style: TextStyle(
                    color: kPortfolioTextPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              if (isCurrentUser && onEdit != null)
                PillEditButton(onTap: onEdit!),
            ],
          ),
          const SizedBox(height: 12),
          if (hasAny)
            Column(
              children: [
                if (hasPhone)
                  ContactRow(
                    icon: Icons.phone_outlined,
                    label: 'Phone',
                    value: user.phone!,
                    onTap: () => launchUrlSafe(context, 'tel:${user.phone!}'),
                  ),
                if (hasLoc)
                  ContactRow(
                    icon: Icons.location_on_outlined,
                    label: 'Location',
                    value: user.location!,
                    onTap: () => launchUrlSafe(context, 'https://maps.google.com/?q=${Uri.encodeComponent(user.location!)}'),
                  ),
                ...activeSocial.map((item) {
                  final meta = SocialPlatformRegistry.get(item.key);
                  return ContactRow(
                    customIcon: meta.iconBuilder(context, size: 15, color: kPortfolioAccent),
                    icon: getPlatformIcon(item.key),
                    label: item.title,
                    value: item.value,
                    onTap: () => launchUrlSafe(context, item.url),
                  );
                }),
              ],
            )
          else
            PortfolioSectionEmptyState(
              icon: Icons.link_off_rounded,
              title: 'No contact details or links',
              subtitle: isCurrentUser ? 'Add your links so recruiters and peers can connect' : null,
              actionLabel: isCurrentUser ? 'Add Links' : null,
              onAction: isCurrentUser ? onEdit : null,
            ),
        ],
      ),
    );
  }

  static Future<void> launchUrlSafe(BuildContext context, String rawUrl) async {
    if (rawUrl.trim().isEmpty) return;
    String url = rawUrl.trim();
    if (!url.startsWith('http://') &&
        !url.startsWith('https://') &&
        !url.startsWith('tel:') &&
        !url.startsWith('mailto:')) {
      url = 'https://$url';
    }
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Invalid URL: $url')));
      }
      return;
    }
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok && context.mounted) {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not open link: $e')));
      }
    }
  }
}

class ContactRow extends StatelessWidget {
  final IconData? icon;
  final Widget? customIcon;
  final String label;
  final String value;
  final VoidCallback onTap;

  const ContactRow({
    super.key,
    this.icon,
    this.customIcon,
    required this.label,
    required this.value,
    required this.onTap,
  }) : assert(icon != null || customIcon != null);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8.5),
        decoration: BoxDecoration(
          color: kPortfolioChipBg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: kPortfolioChipBorder),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 15,
              height: 15,
              child: Center(
                child: customIcon ?? Icon(icon, size: 15, color: kPortfolioAccent),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(color: kPortfolioTextMuted, fontSize: 11.5, fontWeight: FontWeight.w500),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                value,
                style: TextStyle(color: kPortfolioTextPrimary, fontSize: 12.5, fontWeight: FontWeight.w600),
                textAlign: TextAlign.end,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 6),
            Icon(Icons.arrow_outward_rounded, size: 13, color: kPortfolioTextMuted),
          ],
        ),
      ),
    );
  }
}
