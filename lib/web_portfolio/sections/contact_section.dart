import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/web_colors.dart';
import '../theme/web_text_styles.dart';
import '../theme/web_theme.dart';
import '../models/portfolio_view_data.dart';
import '../widgets/responsive_container.dart';
import '../widgets/web_section_header.dart';
import '../widgets/glass_card.dart';
import '../widgets/social_icon_button.dart';
import '../widgets/animated_glow_button.dart';
import '../animations/entrance_fader.dart';

/// Contact Section featuring direct contact methods, email launcher, and contact form layout.
class ContactSection extends StatefulWidget {
  final PortfolioViewData data;
  final bool isDark;

  const ContactSection({
    super.key,
    required this.data,
    required this.isDark,
  });

  @override
  State<ContactSection> createState() => _ContactSectionState();
}

class _ContactSectionState extends State<ContactSection> {
  bool _copied = false;
  Timer? _copyResetTimer;

  Future<void> _launchEmail() async {
    final email = widget.data.user.email;
    final uri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {'subject': 'Inquiry from ConnectHub Portfolio'},
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _copyEmail() {
    Clipboard.setData(ClipboardData(text: widget.data.user.email));
    setState(() => _copied = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Email copied to clipboard!'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
    _copyResetTimer?.cancel();
    _copyResetTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  void dispose() {
    _copyResetTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            eyebrow: 'Get In Touch',
            title: "Let's Build Something Exceptional",
            subtitle:
                'Whether you are looking to architect a new high-scale application, '
                'conduct a codebase audit, or expand your engineering leadership team, let us connect.',
            isDark: widget.isDark,
          ),

          LayoutBuilder(
            builder: (context, constraints) {
              final isTwoColumn = constraints.maxWidth >= 840;

              return isTwoColumn
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 5,
                          child: _buildContactInfo(isMobile),
                        ),
                        const SizedBox(width: 36),
                        Expanded(
                          flex: 6,
                          child: _buildMessageCard(isMobile),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        _buildContactInfo(isMobile),
                        const SizedBox(height: 32),
                        _buildMessageCard(isMobile),
                      ],
                    );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfo(bool isMobile) {
    return EntranceFader(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Availability Card
          Container(
            padding: EdgeInsets.all(isMobile ? 16 : 20),
            decoration: BoxDecoration(
              color: WebColors.emeraldAccent.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: WebColors.emeraldAccent.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: WebColors.emeraldAccent,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Available for architectural consulting, contract roles, and technical advisory.',
                    style: WebTextStyles.bodySmall(isDark: widget.isDark).copyWith(
                      fontWeight: FontWeight.w600,
                      color: widget.isDark ? WebColors.textPrimary : WebColors.lightTextPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Email Contact Card
          _buildInfoTile(
            icon: Icons.alternate_email_rounded,
            title: 'Email Address',
            value: widget.data.user.email,
            action: TextButton.icon(
              onPressed: _copyEmail,
              icon: Icon(
                _copied ? Icons.check_rounded : Icons.copy_rounded,
                size: 14,
                color: WebColors.accent,
              ),
              label: Text(
                _copied ? 'Copied' : 'Copy',
                style: const TextStyle(fontSize: 12, color: WebColors.accent, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Location
          if (widget.data.user.location != null)
            _buildInfoTile(
              icon: Icons.place_outlined,
              title: 'Location',
              value: widget.data.user.location!,
            ),
          const SizedBox(height: 24),

          // Social Profiles Row
          Text(
            'Connect On Social Platforms',
            style: WebTextStyles.cardSubtitle(isDark: widget.isDark).copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 10,
            children: [
              SocialIconButton(
                icon: Icons.code_rounded,
                url: widget.data.user.socialLinks.github,
                tooltip: 'GitHub',
                isDark: widget.isDark,
              ),
              SocialIconButton(
                icon: Icons.business_center_outlined,
                url: widget.data.user.socialLinks.linkedin,
                tooltip: 'LinkedIn',
                isDark: widget.isDark,
              ),
              SocialIconButton(
                icon: Icons.language_rounded,
                url: widget.data.user.socialLinks.website,
                tooltip: 'Website',
                isDark: widget.isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String value,
    Widget? action,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: widget.isDark ? WebColors.surfaceCard : WebColors.lightSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: widget.isDark ? WebColors.border : WebColors.lightBorder,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: WebColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: WebColors.primaryLight, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: WebTextStyles.bodySmall(isDark: widget.isDark),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: WebTextStyles.cardSubtitle(isDark: widget.isDark).copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: widget.isDark ? WebColors.textPrimary : WebColors.lightTextPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          ?action,
        ],
      ),
    );
  }

  Widget _buildMessageCard(bool isMobile) {
    return EntranceFader(
      delay: const Duration(milliseconds: 150),
      child: GlassCard(
        backgroundColor: widget.isDark ? WebColors.surfaceCard : WebColors.lightSurface,
        borderColor: widget.isDark ? WebColors.border : WebColors.lightBorder,
        padding: EdgeInsets.all(isMobile ? 18 : 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Direct Message',
              style: WebTextStyles.cardTitle(isDark: widget.isDark).copyWith(fontSize: 18),
            ),
            const SizedBox(height: 6),
            Text(
              'Launches your preferred email client with pre-configured recipient details.',
              style: WebTextStyles.bodySmall(isDark: widget.isDark),
            ),
            const SizedBox(height: 20),

            _buildMockTextField('Your Name', 'e.g. Alex Morgan'),
            const SizedBox(height: 14),
            _buildMockTextField('Your Email', 'e.g. alex@company.com'),
            const SizedBox(height: 14),
            _buildMockTextField('Message', 'Briefly describe your requirements or inquiry...', maxLines: 3),
            const SizedBox(height: 24),

            AnimatedGlowButton(
              label: 'Compose Email',
              icon: Icons.send_rounded,
              onTap: _launchEmail,
              isDark: widget.isDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMockTextField(String label, String hint, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: WebTextStyles.bodySmall(isDark: widget.isDark).copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: widget.isDark ? WebColors.surface : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: widget.isDark ? WebColors.border : WebColors.lightBorder,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  hint,
                  style: WebTextStyles.bodySmall(isDark: widget.isDark).copyWith(
                    color: widget.isDark ? WebColors.textMuted : WebColors.lightTextMuted,
                  ),
                  maxLines: maxLines,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
