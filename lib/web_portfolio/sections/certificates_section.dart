import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../features/portfolio/data/models/certificate_model.dart';
import '../theme/web_colors.dart';
import '../models/portfolio_view_data.dart';
import '../widgets/section_empty_state.dart';

/// Certificates Section card matching the Titanium/Beige mockup design.
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
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? WebColors.darkSurfaceCard : WebColors.lightSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? WebColors.darkBorder : WebColors.lightBorder,
          ),
        ),
        child: SectionEmptyState(
          icon: Icons.verified_outlined,
          message: 'No certificates added yet.',
          isDark: isDark,
        ),
      );
    }

    final dateFormat = DateFormat('MMM yyyy');

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: isDark ? WebColors.darkSurfaceCard : WebColors.lightSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? WebColors.darkBorder : WebColors.lightBorder,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
            blurRadius: 22,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: isDark
                          ? WebColors.darkPrimary.withValues(alpha: 0.18)
                          : const Color(0xFFF0EAE1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.verified_outlined,
                      size: 20,
                      color: isDark ? WebColors.darkPrimaryLight : WebColors.lightPrimary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Certificates',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 17.5,
                      fontWeight: FontWeight.w700,
                      color: isDark ? WebColors.darkTextPrimary : const Color(0xFF1B1917),
                    ),
                  ),
                ],
              ),
              // View all Pill Button
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark
                      ? WebColors.darkSurface.withValues(alpha: 0.8)
                      : const Color(0xFFF7F3EC),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isDark ? WebColors.darkBorder : const Color(0xFFE2DCD1),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'View all',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? WebColors.darkTextSecondary : const Color(0xFF4A433D),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 13,
                      color: isDark ? WebColors.darkTextSecondary : const Color(0xFF4A433D),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),

          // Certificates List
          Column(
            children: data.certificates.asMap().entries.map((entry) {
              final index = entry.key;
              final cert = entry.value;
              final isLast = index == data.certificates.length - 1;
              final dateStr = cert.issueDate != null ? dateFormat.format(cert.issueDate!) : '';

              return Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Badge / Logo icon (adapted to organization)
                    _buildCertBadge(cert, isDark),
                    const SizedBox(width: 14),

                    // Title & Org
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cert.title,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: isDark ? WebColors.darkTextPrimary : const Color(0xFF1C1917),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            cert.issuingOrganization,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: isDark ? WebColors.darkTextMuted : const Color(0xFF6B6258),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    // Date badge & Verification link
                    if (dateStr.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                        decoration: BoxDecoration(
                          color: isDark
                              ? WebColors.darkSurface
                              : const Color(0xFFF7F4EE),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isDark ? WebColors.darkBorder : const Color(0xFFEAE3D6),
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          dateStr,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: isDark ? WebColors.darkTextMuted : const Color(0xFF6B6258),
                          ),
                        ),
                      ),
                    ],

                    if (cert.credentialUrl != null && cert.credentialUrl!.trim().isNotEmpty) ...[
                      const SizedBox(width: 8),
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () async {
                            final uri = Uri.tryParse(cert.credentialUrl!.trim());
                            if (uri != null && await canLaunchUrl(uri)) {
                              await launchUrl(uri, mode: LaunchMode.externalApplication);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isDark ? WebColors.darkSurface : const Color(0xFFF6F2EB),
                            ),
                            child: Icon(
                              Icons.arrow_outward_rounded,
                              size: 13,
                              color: isDark ? WebColors.darkPrimaryLight : WebColors.lightPrimary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCertBadge(CertificateModel cert, bool isDark) {
    final title = cert.title.toLowerCase();
    final org = cert.issuingOrganization.toLowerCase();

    Color bgColor = isDark ? WebColors.darkSurface : const Color(0xFFF7F4EE);
    Color iconColor = isDark ? WebColors.darkPrimaryLight : WebColors.lightPrimary;
    Widget child = Icon(
      Icons.workspace_premium_outlined,
      size: 20,
      color: iconColor,
    );

    if (title.contains('ibm') || org.contains('ibm')) {
      bgColor = const Color(0xFF0F62FE).withValues(alpha: 0.14);
      iconColor = const Color(0xFF0F62FE);
      child = Text(
        'IBM',
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 12,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
          color: iconColor,
        ),
      );
    } else if (title.contains('hugging') || org.contains('hugging') || title.contains('langchain')) {
      bgColor = const Color(0xFFFFD21E).withValues(alpha: 0.22);
      iconColor = const Color(0xFFD97706);
      child = const Text(
        '🤗',
        style: TextStyle(fontSize: 18),
      );
    } else if (title.contains('stanford') || org.contains('stanford') || org.contains('deeplearning')) {
      bgColor = const Color(0xFF8C1515).withValues(alpha: 0.15);
      iconColor = const Color(0xFF8C1515);
      child = Text(
        'S',
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 16,
          fontWeight: FontWeight.w900,
          color: iconColor,
        ),
      );
    } else if (title.contains('google') || org.contains('google')) {
      bgColor = const Color(0xFF4285F4).withValues(alpha: 0.14);
      iconColor = const Color(0xFF4285F4);
      child = Icon(Icons.stars_rounded, size: 21, color: iconColor);
    } else if (title.contains('aws') || org.contains('amazon')) {
      bgColor = const Color(0xFFFF9900).withValues(alpha: 0.16);
      iconColor = const Color(0xFFFF9900);
      child = Icon(Icons.cloud_done_rounded, size: 20, color: iconColor);
    }

    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? WebColors.darkBorder : const Color(0xFFE8E0D2),
        ),
      ),
      child: Center(child: child),
    );
  }
}
