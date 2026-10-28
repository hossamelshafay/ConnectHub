import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:connecthub/core/utils/app_theme.dart';
import 'package:connecthub/features/profile/data/models/user_model.dart';
import 'package:connecthub/features/profile/presentation/widgets/social_icons.dart';
import 'package:connecthub/features/profile/presentation/widgets/profile_live_website_chip.dart';

/// Horizontal social links bar rendered on the profile header.
///
/// Displays a row of tappable brand-icon buttons for each non-empty social
/// platform stored in [socialLinks], plus an optional "Live Website" pill
/// chip when [websiteUrl] is provided.  Tapping any icon opens the
/// corresponding URL in the system browser.
class ProfileSocialLinksBar extends StatelessWidget {
  final SocialLinksModel socialLinks;

  /// URL of the user's generated portfolio website (distinct from the
  /// social-links `website` field).  When non-null and non-empty a
  /// [ProfileLiveWebsiteChip] is shown at the leading position.
  final String? websiteUrl;

  const ProfileSocialLinksBar({
    super.key,
    required this.socialLinks,
    this.websiteUrl,
  });

  Future<void> _open(String url) async {
    final uri = Uri.tryParse(url.trim());
    if (uri != null && uri.hasScheme) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final links = socialLinks.activeLinks;
    final hasWebsite =
        websiteUrl != null && websiteUrl!.trim().isNotEmpty;

    // Nothing to show
    if (links.isEmpty && !hasWebsite) return const SizedBox.shrink();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          // ── Live Website Pill ───────────────────────────────────────────
          if (hasWebsite) ...[
            ProfileLiveWebsiteChip(websiteUrl: websiteUrl!),
            if (links.isNotEmpty) const SizedBox(width: 10),
          ],

          // ── Social Brand Icon Buttons ───────────────────────────────────
          ...links.map((item) => _SocialIconButton(
                item: item,
                onTap: () => _open(item.url),
              )),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _SocialIconButton extends StatelessWidget {
  final SocialPlatformItem item;
  final VoidCallback onTap;

  const _SocialIconButton({
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final meta = SocialPlatformRegistry.get(item.key);
    final iconColor = AppColors.textSecondary;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Tooltip(
        message: item.title,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.isDark
                  ? const Color(0xFF2A2724)
                  : const Color(0xFFEDE7DD),
              border: Border.all(
                color: AppColors.isDark
                    ? const Color(0x22FFFFFF)
                    : const Color(0xFFDDD6CB),
                width: 1,
              ),
            ),
            child: Center(
              child: meta.iconBuilder(context, color: iconColor, size: 16),
            ),
          ),
        ),
      ),
    );
  }
}
