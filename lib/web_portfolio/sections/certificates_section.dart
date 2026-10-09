import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../features/portfolio/data/models/certificate_model.dart';
import '../theme/web_colors.dart';
import '../theme/web_text_styles.dart';
import '../theme/web_theme.dart';
import '../models/portfolio_view_data.dart';
import '../widgets/responsive_container.dart';
import '../widgets/web_section_header.dart';
import '../animations/entrance_fader.dart';
import '../animations/hover_tilt_card.dart';
import '../responsive/responsive.dart';

/// Certificates Section featuring industry certifications with verification links.
class CertificatesSection extends StatelessWidget {
  final PortfolioViewData data;
  final bool isDark;

  const CertificatesSection({
    super.key,
    required this.data,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    if (data.certificates.isEmpty) {
      return const SizedBox.shrink();
    }
    final isMobile = WebTheme.isMobile(context);

    return ResponsiveContainer(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16.0 : 48.0,
        vertical: isMobile ? 40.0 : 80.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WebSectionHeader(
            eyebrow: 'Credentials',
            title: 'Certifications & Honors',
            subtitle:
                'Industry-recognized certifications validating core mobile engineering, '
                'systems architecture, and cloud best practices.',
            isDark: isDark,
          ),

          // Adaptive Certificate Grid: 1 col on mobile, 2 cols on tablet/desktop
          ResponsiveGrid(
            maxCrossAxisExtent: 520,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            children: [
              for (int i = 0; i < data.certificates.length; i++)
                _CertificateCard(
                  cert: data.certificates[i],
                  isDark: isDark,
                  index: i,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CertificateCard extends StatelessWidget {
  final CertificateModel cert;
  final bool isDark;
  final int index;

  const _CertificateCard({
    required this.cert,
    required this.isDark,
    required this.index,
  });

  Future<void> _verify() async {
    if (cert.credentialUrl == null || cert.credentialUrl!.isEmpty) return;
    final uri = Uri.tryParse(cert.credentialUrl!);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMMM yyyy');
    final issueDateStr = cert.issueDate != null ? dateFormat.format(cert.issueDate!) : '';

    return EntranceFader(
      delay: Duration(milliseconds: 100 * index),
      child: HoverTiltCard(
        backgroundColor: isDark ? WebColors.surfaceCard : WebColors.lightSurface,
        borderColor: isDark ? WebColors.border : WebColors.lightBorder,
        hoverBorderColor: WebColors.accent,
        borderRadius: BorderRadius.circular(16),
        enableScale: true,
        hoverScale: 1.015,
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: WebColors.accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: WebColors.accent.withValues(alpha: 0.3),
                      ),
                    ),
                    child: const Icon(
                      Icons.verified_rounded,
                      color: WebColors.secondaryAccent,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cert.title,
                          style: WebTextStyles.cardTitle(isDark: isDark).copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          cert.issuingOrganization,
                          style: WebTextStyles.cardSubtitle(isDark: isDark).copyWith(
                            color: WebColors.primaryLight,
                            fontWeight: FontWeight.w600,
                            fontSize: 13.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if (issueDateStr.isNotEmpty)
                    Text(
                      'Issued: $issueDateStr',
                      style: WebTextStyles.bodySmall(isDark: isDark),
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (cert.credentialUrl != null)
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: _verify,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Verify',
                              style: WebTextStyles.bodySmall(isDark: isDark).copyWith(
                                color: WebColors.accent,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.arrow_outward_rounded,
                              size: 14,
                              color: WebColors.accent,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
