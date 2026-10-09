import 'package:flutter/material.dart';
import '../theme/web_colors.dart';
import '../theme/web_text_styles.dart';
import '../theme/web_theme.dart';
import '../models/portfolio_view_data.dart';
import '../widgets/responsive_container.dart';
import '../widgets/social_icon_button.dart';

/// Footer Section with copyright, tech stack attribution, and scroll-to-top button.
class FooterSection extends StatelessWidget {
  final PortfolioViewData data;
  final bool isDark;
  final VoidCallback onScrollToTop;

  const FooterSection({
    super.key,
    required this.data,
    required this.isDark,
    required this.onScrollToTop,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = WebTheme.isMobile(context);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? WebColors.background : WebColors.lightBackground,
        border: Border(
          top: BorderSide(
            color: isDark ? WebColors.border : WebColors.lightBorder,
            width: 1,
          ),
        ),
      ),
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? 32.0 : 48.0,
      ),
      child: ResponsiveContainer(
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 16.0 : 48.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Brand Monogram and Title
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          gradient: WebColors.primaryGradient,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Text(
                            'CH',
                            style: TextStyle(
                              color: Color(0xFF090909),
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          data.user.name,
                          style: WebTextStyles.cardTitle(isDark: isDark).copyWith(fontSize: 15),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // Back to Top Button
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: onScrollToTop,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDark ? WebColors.surfaceElevated : WebColors.lightSurface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isDark ? WebColors.border : WebColors.lightBorder,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.arrow_upward_rounded,
                            size: 15,
                            color: WebColors.primaryLight,
                          ),
                          if (!isMobile) ...[
                            const SizedBox(width: 6),
                            Text(
                              'Back to top',
                              style: WebTextStyles.bodySmall(isDark: isDark).copyWith(
                                fontWeight: FontWeight.w600,
                                color: isDark ? WebColors.textPrimary : WebColors.lightTextPrimary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
            Divider(
              color: isDark ? WebColors.border : WebColors.lightBorder,
              height: 1,
            ),
            const SizedBox(height: 20),

            // Bottom Credits and Social Links
            isMobile
                ? Column(
                    children: [
                      Text(
                        '© ${DateTime.now().year} ${data.user.name}. All rights reserved.',
                        style: WebTextStyles.bodySmall(isDark: isDark),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Engineered with Flutter Web & Clean Architecture.',
                        style: WebTextStyles.bodySmall(isDark: isDark).copyWith(
                          color: WebColors.accent,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 14),
                      _buildSocialRow(),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '© ${DateTime.now().year} ${data.user.name}. Built with Flutter Web & Clean Architecture.',
                          style: WebTextStyles.bodySmall(isDark: isDark),
                        ),
                      ),
                      const SizedBox(width: 16),
                      _buildSocialRow(),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialRow() {
    final githubUrl = (data.user.socialLinks.github != null && data.user.socialLinks.github!.trim().isNotEmpty)
        ? data.user.socialLinks.github!.trim()
        : (data.user.githubUsername != null && data.user.githubUsername!.trim().isNotEmpty)
            ? 'https://github.com/${data.user.githubUsername!.trim()}'
            : null;
    final linkedinUrl = (data.user.socialLinks.linkedin != null && data.user.socialLinks.linkedin!.trim().isNotEmpty)
        ? data.user.socialLinks.linkedin!.trim()
        : null;
    final websiteUrl = (data.user.socialLinks.website != null && data.user.socialLinks.website!.trim().isNotEmpty)
        ? data.user.socialLinks.website!.trim()
        : null;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (githubUrl != null)
          SocialIconButton(
            icon: Icons.code_rounded,
            url: githubUrl,
            tooltip: 'GitHub',
            isDark: isDark,
          ),
        if (linkedinUrl != null)
          SocialIconButton(
            icon: Icons.business_center_outlined,
            url: linkedinUrl,
            tooltip: 'LinkedIn',
            isDark: isDark,
          ),
        if (websiteUrl != null)
          SocialIconButton(
            icon: Icons.language_rounded,
            url: websiteUrl,
            tooltip: 'Website',
            isDark: isDark,
          ),
      ],
    );
  }
}
