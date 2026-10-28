import 'package:flutter/material.dart';
import 'package:connecthub/core/utils/app_theme.dart';
import 'package:connecthub/features/portfolio/presentation/widgets/contact_card.dart';
import 'package:connecthub/features/portfolio/presentation/widgets/portfolio_theme.dart';
import 'package:connecthub/features/profile/data/models/user_model.dart';

void showExportPdfSheet({
  required BuildContext context,
  required UserModel user,
  required bool isCurrentUser,
  required Function(String, {required bool isError}) onShowSnack,
  required VoidCallback onGenerateWebsiteFirst,
}) {
  final hasWebsite = user.websiteGenerated && (user.websiteUrl != null && user.websiteUrl!.isNotEmpty);
  showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) => Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFEC4899).withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.picture_as_pdf_outlined, color: Color(0xFFEC4899), size: 24),
          ),
          const SizedBox(height: 16),
          const Text(
            'Export Portfolio PDF',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            hasWebsite
                ? 'Your portfolio website is optimized for PDF resume generation. Open it in your browser and choose "Print / Save as PDF".'
                : 'Generate your web portfolio first to export a formatted PDF resume.',
            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          if (hasWebsite)
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: kPortfolioAccent,
                foregroundColor: AppColors.isDark ? const Color(0xFF141210) : Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              ),
              icon: const Icon(Icons.open_in_browser_rounded, size: 18),
              label: const Text('Open in Browser to Save PDF', style: TextStyle(fontWeight: FontWeight.w700)),
              onPressed: () {
                Navigator.pop(ctx);
                ContactCard.launchUrlSafe(context, user.websiteUrl!);
              },
            )
          else
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kPortfolioAccent,
                foregroundColor: AppColors.isDark ? const Color(0xFF141210) : Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              ),
              onPressed: () {
                Navigator.pop(ctx);
                onGenerateWebsiteFirst();
              },
              child: const Text('Generate Website First', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
        ],
      ),
    ),
  );
}
