import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connecthub/features/portfolio/presentation/cubit/portfolio_cubit.dart';
import 'package:connecthub/features/portfolio_import/presentation/widgets/upload_cv_button.dart';
import 'package:connecthub/features/profile/data/models/user_model.dart';
import 'package:connecthub/features/profile/presentation/widgets/social_icons.dart';
import 'package:connecthub/features/portfolio/presentation/widgets/portfolio_theme.dart';
import 'package:connecthub/features/portfolio/presentation/widgets/glass_card.dart';
import 'package:connecthub/features/portfolio/presentation/widgets/contact_card.dart';
import 'package:connecthub/features/portfolio/presentation/widgets/sheets/edit_contact_sheet.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Action Buttons Row (CV Upload / GitHub / Message / Social Profile)
// ─────────────────────────────────────────────────────────────────────────────
class ActionButtonsRow extends StatelessWidget {
  final String userId;
  final UserModel user;
  final bool isCurrentUser;
  final VoidCallback? onSwitchToSocial;

  const ActionButtonsRow({
    super.key,
    required this.userId,
    required this.user,
    required this.isCurrentUser,
    this.onSwitchToSocial,
  });

  @override
  Widget build(BuildContext context) {
    final rawUsername = user.githubUsername?.trim() ?? '';
    final rawSocial = user.socialLinks.github?.trim() ?? '';
    final ghValue = rawUsername.isNotEmpty ? rawUsername : rawSocial;
    final hasGithub = ghValue.isNotEmpty;
    final githubUrl = ghValue.startsWith('http://') || ghValue.startsWith('https://')
        ? ghValue
        : 'https://github.com/${ghValue.replaceAll('@', '')}';
    final ghDisplay = rawUsername.isNotEmpty
        ? (rawUsername.startsWith('@') ? rawUsername : '@$rawUsername')
        : (hasGithub ? 'GitHub' : 'Add GitHub');

    if (isCurrentUser) {
      return Row(
        children: [
          // Left button: Upload CV
          Expanded(
            child: UploadCvButton(
              userId: userId,
              isCompactGlass: true,
              onImportComplete: () =>
                  context.read<PortfolioCubit>().loadPortfolio(userId),
            ),
          ),
          const SizedBox(width: 10),
          // Right button: GitHub (or Add GitHub)
          Expanded(
            child: ActionGlassButton(
              icon: hasGithub ? null : Icons.add_rounded,
              customIcon: hasGithub
                  ? SocialIcons.github(size: 18, color: kPortfolioAccent)
                  : null,
              label: ghDisplay,
              trailing: hasGithub
                  ? Icons.arrow_outward_rounded
                  : Icons.arrow_forward_ios_rounded,
              onTap: () {
                if (hasGithub) {
                  ContactCard.launchUrlSafe(context, githubUrl);
                } else {
                  EditContactSheet.show(context, uid: userId, user: user);
                }
              },
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: ActionGlassButton(
            icon: Icons.chat_bubble_outline_rounded,
            label: 'Message',
            trailing: Icons.send_rounded,
            onTap: () {
              if (user.email.isNotEmpty) {
                ContactCard.launchUrlSafe(context, 'mailto:${user.email}');
              }
            },
          ),
        ),
        if (hasGithub) ...[
          const SizedBox(width: 10),
          Expanded(
            child: ActionGlassButton(
              customIcon: SocialIcons.github(size: 18, color: kPortfolioAccent),
              label: ghDisplay,
              trailing: Icons.arrow_outward_rounded,
              onTap: () => ContactCard.launchUrlSafe(context, githubUrl),
            ),
          ),
        ] else if (onSwitchToSocial != null) ...[
          const SizedBox(width: 10),
          Expanded(
            child: ActionGlassButton(
              icon: Icons.people_outline_rounded,
              label: 'Social Profile',
              trailing: Icons.arrow_forward_ios_rounded,
              onTap: onSwitchToSocial!,
            ),
          ),
        ],
      ],
    );
  }
}
