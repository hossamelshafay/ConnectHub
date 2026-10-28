import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/web_colors.dart';
import '../theme/web_theme.dart';
import '../models/portfolio_view_data.dart';
import '../widgets/responsive_container.dart';
import '../widgets/web_section_header.dart';
import '../widgets/social_icon_button.dart';
import '../widgets/animated_glow_button.dart';
import '../animations/entrance_fader.dart';

/// Contact Section featuring direct contact methods, email launcher, and high-contrast contact form.
/// Designed for maximum accessibility, glassmorphic elegance, and contrast in both Light & Dark modes.
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

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  Future<void> _launchEmail() async {
    final email = widget.data.user.email;
    final name = _nameController.text.trim();
    final senderEmail = _emailController.text.trim();
    final message = _messageController.text.trim();

    String subject = 'Inquiry from ConnectHub Portfolio';
    if (name.isNotEmpty) {
      subject = 'Inquiry from $name | ConnectHub Portfolio';
    }

    String body = '';
    if (name.isNotEmpty || senderEmail.isNotEmpty || message.isNotEmpty) {
      body = 'Hello,\n\n$message\n\nBest regards,\n$name${senderEmail.isNotEmpty ? ' ($senderEmail)' : ''}';
    }

    final queryParams = <String, String>{'subject': subject};
    if (body.isNotEmpty) {
      queryParams['body'] = body;
    }

    final uri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: queryParams,
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _copyEmail() {
    Clipboard.setData(ClipboardData(text: widget.data.user.email));
    setState(() => _copied = true);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: WebColors.emeraldAccent, size: 20),
            const SizedBox(width: 12),
            Text(
              'Email copied to clipboard!',
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                color: widget.isDark ? WebColors.darkTextPrimary : Colors.white,
              ),
            ),
          ],
        ),
        backgroundColor: widget.isDark ? const Color(0xFF1E1B18) : WebColors.lightTextPrimary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: widget.isDark ? WebColors.darkPrimary.withValues(alpha: 0.45) : Colors.transparent,
            width: 1.2,
          ),
        ),
        duration: const Duration(seconds: 2),
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
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
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
          // Availability Card — High contrast in both themes
          Container(
            padding: EdgeInsets.all(isMobile ? 16 : 20),
            decoration: BoxDecoration(
              color: widget.isDark
                  ? const Color(0xFF132A1F)
                  : const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: widget.isDark
                    ? const Color(0xFF10B981).withValues(alpha: 0.55)
                    : const Color(0xFF10B981).withValues(alpha: 0.35),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: WebColors.emeraldAccent.withValues(alpha: widget.isDark ? 0.16 : 0.06),
                  blurRadius: 18,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: WebColors.emeraldAccent,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: WebColors.emeraldAccent.withValues(alpha: 0.65),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'Available for architectural consulting, contract roles, and technical advisory.',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      height: 1.45,
                      color: widget.isDark ? const Color(0xFFD1FAE5) : const Color(0xFF065F46),
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
                color: _copied
                    ? WebColors.emeraldAccent
                    : (widget.isDark ? WebColors.darkPrimary : WebColors.lightPrimary),
              ),
              label: Text(
                _copied ? 'Copied' : 'Copy',
                style: TextStyle(
                  fontSize: 12,
                  color: _copied
                      ? WebColors.emeraldAccent
                      : (widget.isDark ? WebColors.darkPrimary : WebColors.lightPrimary),
                  fontWeight: FontWeight.w600,
                ),
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
          Builder(
            builder: (context) {
              final rawGithub = (widget.data.user.socialLinks.github != null && widget.data.user.socialLinks.github!.trim().isNotEmpty)
                  ? widget.data.user.socialLinks.github!.trim()
                  : (widget.data.user.githubUsername != null && widget.data.user.githubUsername!.trim().isNotEmpty)
                      ? widget.data.user.githubUsername!.trim()
                      : null;
              final String? githubUrl;
              if (rawGithub == null || rawGithub.isEmpty) {
                githubUrl = null;
              } else if (rawGithub.startsWith('http://') || rawGithub.startsWith('https://')) {
                githubUrl = rawGithub;
              } else {
                final clean = rawGithub.replaceAll('@', '').trim();
                githubUrl = clean.isNotEmpty ? 'https://github.com/$clean' : null;
              }

              final rawLinkedin = widget.data.user.socialLinks.linkedin?.trim();
              final String? linkedinUrl;
              if (rawLinkedin == null || rawLinkedin.isEmpty) {
                linkedinUrl = null;
              } else if (rawLinkedin.startsWith('http://') || rawLinkedin.startsWith('https://')) {
                linkedinUrl = rawLinkedin;
              } else {
                final clean = rawLinkedin.replaceAll('@', '').trim();
                linkedinUrl = clean.isNotEmpty ? 'https://linkedin.com/in/$clean' : null;
              }

              final rawWebsite = widget.data.user.socialLinks.website?.trim();
              final String? websiteUrl;
              if (rawWebsite == null || rawWebsite.isEmpty) {
                websiteUrl = null;
              } else if (rawWebsite.startsWith('http://') || rawWebsite.startsWith('https://')) {
                websiteUrl = rawWebsite;
              } else {
                websiteUrl = 'https://$rawWebsite';
              }

              final hasAny = githubUrl != null || linkedinUrl != null || websiteUrl != null;
              if (!hasAny) {
                return const SizedBox.shrink();
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Connect On Social Platforms',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: widget.isDark ? WebColors.darkTextPrimary : WebColors.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 10,
                    children: [
                      if (githubUrl != null)
                        SocialIconButton(
                          icon: Icons.code_rounded,
                          url: githubUrl,
                          tooltip: 'GitHub',
                          isDark: widget.isDark,
                        ),
                      if (linkedinUrl != null)
                        SocialIconButton(
                          icon: Icons.business_center_outlined,
                          url: linkedinUrl,
                          tooltip: 'LinkedIn',
                          isDark: widget.isDark,
                        ),
                      if (websiteUrl != null)
                        SocialIconButton(
                          icon: Icons.language_rounded,
                          url: websiteUrl,
                          tooltip: 'Website',
                          isDark: widget.isDark,
                        ),
                    ],
                  ),
                ],
              );
            },
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
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
      decoration: BoxDecoration(
        color: widget.isDark ? const Color(0xFF1A1816) : WebColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.isDark ? WebColors.darkPrimary.withValues(alpha: 0.28) : WebColors.lightBorder,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: widget.isDark ? 0.25 : 0.035),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (widget.isDark ? WebColors.darkPrimary : WebColors.lightPrimary)
                  .withValues(alpha: widget.isDark ? 0.18 : 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: widget.isDark ? WebColors.darkPrimary : WebColors.lightPrimary,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: widget.isDark ? WebColors.darkTextSecondary : WebColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: widget.isDark ? WebColors.darkTextPrimary : WebColors.lightTextPrimary,
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
      child: Container(
        padding: EdgeInsets.all(isMobile ? 20 : 28),
        decoration: BoxDecoration(
          color: widget.isDark ? const Color(0xFF1A1816) : WebColors.lightSurface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: widget.isDark ? WebColors.darkPrimary.withValues(alpha: 0.28) : WebColors.lightBorder,
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: widget.isDark ? 0.35 : 0.04),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Direct Message',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 18.5,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
                color: widget.isDark ? WebColors.darkTextPrimary : WebColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Launches your preferred email client with pre-configured recipient details.',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13.5,
                color: widget.isDark ? WebColors.darkTextSecondary : WebColors.lightTextSecondary,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 22),

            _buildInputField(
              label: 'Your Name',
              hint: 'e.g. Alex Morgan',
              controller: _nameController,
            ),
            const SizedBox(height: 16),
            _buildInputField(
              label: 'Your Email',
              hint: 'e.g. alex@company.com',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            _buildInputField(
              label: 'Message',
              hint: 'Briefly describe your requirements or inquiry...',
              controller: _messageController,
              maxLines: 3,
            ),
            const SizedBox(height: 26),

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

  Widget _buildInputField({
    required String label,
    required String hint,
    required TextEditingController controller,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: widget.isDark ? WebColors.darkTextPrimary : WebColors.lightTextPrimary,
            letterSpacing: -0.1,
          ),
        ),
        const SizedBox(height: 7),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: widget.isDark ? 0.20 : 0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: widget.isDark ? WebColors.darkTextPrimary : WebColors.lightTextPrimary,
            ),
            cursorColor: widget.isDark ? WebColors.darkPrimary : WebColors.lightPrimary,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13.5,
                color: widget.isDark ? const Color(0xFFA8A095) : const Color(0xFF888076),
              ),
              filled: true,
              fillColor: widget.isDark ? const Color(0xFF141311) : const Color(0xFFF9F7F3),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: widget.isDark
                      ? WebColors.darkPrimary.withValues(alpha: 0.32)
                      : const Color(0xFFDDD6CB),
                  width: 1.2,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: widget.isDark
                      ? WebColors.darkPrimary.withValues(alpha: 0.32)
                      : const Color(0xFFDDD6CB),
                  width: 1.2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: widget.isDark ? WebColors.darkPrimary : WebColors.lightPrimary,
                  width: 1.6,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
