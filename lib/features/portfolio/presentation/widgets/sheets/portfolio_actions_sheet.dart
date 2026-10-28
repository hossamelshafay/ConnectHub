import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:connecthub/core/utils/app_theme.dart';
import 'package:connecthub/features/profile/data/models/user_model.dart';
import 'package:connecthub/features/portfolio/presentation/widgets/portfolio_theme.dart';
import 'package:connecthub/features/portfolio/presentation/widgets/sheets/glass_form_widgets.dart';
import 'package:connecthub/features/portfolio/presentation/widgets/contact_card.dart';
import 'package:connecthub/features/portfolio/presentation/widgets/sheets/portfolio_delete_website_sheet.dart';
import 'package:connecthub/features/portfolio/presentation/widgets/sheets/portfolio_export_pdf_sheet.dart';
import 'package:connecthub/features/portfolio/presentation/widgets/sheets/portfolio_generate_website_sheet.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Portfolio Actions Bottom Sheet & Dialog Handlers
// ─────────────────────────────────────────────────────────────────────────────
class PortfolioActionsSheet {
  static void showMoreSheet({
    required BuildContext context,
    required UserModel? user,
    required bool isCurrentUser,
    required VoidCallback? onSwitchToSocial,
    required Function(String, {required bool isError}) onShowSnack,
  }) {
    if (user == null) return;
    final hasWebsite = user.websiteGenerated &&
        (user.websiteUrl != null && user.websiteUrl!.trim().isNotEmpty);

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.glassBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),

              // Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Portfolio Actions',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
                  if (hasWebsite)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF22C55E).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(color: const Color(0xFF22C55E).withValues(alpha: 0.3)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle_rounded, color: Color(0xFF22C55E), size: 12),
                          SizedBox(width: 4),
                          Text(
                            'Website Live',
                            style: TextStyle(color: Color(0xFF22C55E), fontSize: 11.5, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),

              if (isCurrentUser) ...[
                // 1. Generate Website (only if NOT generated yet)
                if (!hasWebsite)
                  MenuActionTile(
                    icon: Icons.auto_awesome_rounded,
                    iconColor: kPortfolioAccent,
                    title: 'Generate Website',
                    subtitle: 'Publish your live glass portfolio web page',
                    onTap: () {
                      Navigator.pop(ctx);
                      openGenerateWebsiteSheet(
                        context: context,
                        user: user,
                        isCurrentUser: isCurrentUser,
                        isUpdate: false,
                        onShowSnack: onShowSnack,
                      );
                    },
                  ),

                // 2. Update Website (with "Website needs update" tag)
                if (hasWebsite) ...[
                  MenuActionTile(
                    icon: Icons.refresh_rounded,
                    iconColor: const Color(0xFFF59E0B),
                    title: 'Update Website',
                    subtitle: 'Sync latest edits to your live website',
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.35)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.circle, color: Color(0xFFF59E0B), size: 6),
                          SizedBox(width: 4),
                          Text(
                            'Needs update',
                            style: TextStyle(color: Color(0xFFF59E0B), fontSize: 11, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(ctx);
                      openGenerateWebsiteSheet(
                        context: context,
                        user: user,
                        isCurrentUser: isCurrentUser,
                        isUpdate: true,
                        onShowSnack: onShowSnack,
                      );
                    },
                  ),
                  MenuActionTile(
                    icon: Icons.open_in_browser_rounded,
                    iconColor: kPortfolioAccent,
                    title: 'Open Website',
                    subtitle: user.websiteUrl!,
                    onTap: () {
                      Navigator.pop(ctx);
                      ContactCard.launchUrlSafe(context, user.websiteUrl!);
                    },
                  ),
                  MenuActionTile(
                    icon: Icons.copy_rounded,
                    iconColor: const Color(0xFFA855F7),
                    title: 'Copy Website Link',
                    subtitle: 'Copy live portfolio URL to clipboard',
                    onTap: () {
                      Navigator.pop(ctx);
                      Clipboard.setData(ClipboardData(text: user.websiteUrl!));
                      onShowSnack('Website link copied to clipboard!', isError: false);
                    },
                  ),
                ],

                // 3. Share Portfolio
                MenuActionTile(
                  icon: Icons.share_outlined,
                  iconColor: kPortfolioAccent,
                  title: 'Share Portfolio',
                  subtitle: 'Share your public portfolio link',
                  onTap: () {
                    Navigator.pop(ctx);
                    sharePortfolio(context, user, onShowSnack);
                  },
                ),

                // 4. Export PDF
                MenuActionTile(
                  icon: Icons.picture_as_pdf_outlined,
                  iconColor: const Color(0xFFEC4899),
                  title: 'Export PDF',
                  subtitle: 'Download or print formatted portfolio',
                  onTap: () {
                    Navigator.pop(ctx);
                    exportPdf(context, user, isCurrentUser, onShowSnack);
                  },
                ),

                // 5. Delete Website (only if generated)
                if (hasWebsite)
                  MenuActionTile(
                    icon: Icons.delete_outline_rounded,
                    iconColor: const Color(0xFFEF4444),
                    title: 'Delete Website',
                    titleColor: const Color(0xFFEF4444),
                    subtitle: 'Unpublish and take down your website',
                    onTap: () {
                      Navigator.pop(ctx);
                      confirmDeleteWebsite(context, user, onShowSnack);
                    },
                  ),
              ],

              if (onSwitchToSocial != null) ...[
                const Divider(color: Color(0x1AFFFFFF), height: 16),
                MenuActionTile(
                  icon: Icons.people_outline_rounded,
                  iconColor: kPortfolioTextMuted,
                  title: 'Switch to Social Profile',
                  onTap: () {
                    Navigator.pop(ctx);
                    onSwitchToSocial();
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  static void openGenerateWebsiteSheet({
    required BuildContext context,
    required UserModel user,
    required bool isCurrentUser,
    required bool isUpdate,
    required Function(String, {required bool isError}) onShowSnack,
  }) {
    showGenerateWebsiteSheet(
      context: context,
      user: user,
      isCurrentUser: isCurrentUser,
      isUpdate: isUpdate,
      onShowSnack: onShowSnack,
    );
  }

  static void confirmDeleteWebsite(
    BuildContext context,
    UserModel user,
    Function(String, {required bool isError}) onShowSnack,
  ) {
    showDeleteWebsiteSheet(context, user, onShowSnack);
  }

  static void sharePortfolio(
    BuildContext context,
    UserModel user,
    Function(String, {required bool isError}) onShowSnack,
  ) {
    final hasWebsite = user.websiteGenerated && (user.websiteUrl != null && user.websiteUrl!.isNotEmpty);
    final link = hasWebsite ? user.websiteUrl! : 'Check out ${user.name}\'s portfolio on ConnectHub!';
    final shareText = 'Check out ${user.name}\'s Portfolio: $link';
    try {
      SharePlus.instance.share(ShareParams(text: shareText));
    } catch (_) {
      Clipboard.setData(ClipboardData(text: shareText));
      onShowSnack('Portfolio link copied to clipboard!', isError: false);
    }
  }

  static void exportPdf(
    BuildContext context,
    UserModel user,
    bool isCurrentUser,
    Function(String, {required bool isError}) onShowSnack,
  ) {
    showExportPdfSheet(
      context: context,
      user: user,
      isCurrentUser: isCurrentUser,
      onShowSnack: onShowSnack,
      onGenerateWebsiteFirst: () {
        openGenerateWebsiteSheet(
          context: context,
          user: user,
          isCurrentUser: isCurrentUser,
          isUpdate: false,
          onShowSnack: onShowSnack,
        );
      },
    );
  }

  static Future<void> confirmDeleteItem(
    BuildContext context, {
    required String title,
    required String itemTitle,
    required VoidCallback onConfirmed,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Delete $title?',
            style: TextStyle(color: kPortfolioTextPrimary, fontWeight: FontWeight.w700)),
        content: Text(
          'Are you sure you want to delete "$itemTitle"?\nThis cannot be undone.',
          style: TextStyle(color: kPortfolioTextSecondary, fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: TextStyle(color: kPortfolioTextSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) onConfirmed();
  }
}
