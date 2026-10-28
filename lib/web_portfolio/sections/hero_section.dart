import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/web_colors.dart';
import '../theme/web_theme.dart';
import '../models/portfolio_view_data.dart';
import '../widgets/responsive_container.dart';
import '../widgets/hero_profile_avatar.dart';
import '../animations/entrance_fader.dart';

/// Recreated Hero Section matching the Titanium/Beige design mockup.
/// Features:
/// - Wallpaper `assets/img/web-background.png` ONLY in the hero with 40% blur & warm beige overlay.
/// - Smooth gradient fade into the page background.
/// - Circular profile avatar with active emerald status indicator.
/// - "Available for opportunities" badge, bold name, role, bio, and social icons.
/// - Translucent 2x2 glass stats card (Projects, Experience, Certificates, Skills).
/// - Inspirational vertical quote ("Build Learn Create Repeat").
class HeroSection extends StatelessWidget {
  final PortfolioViewData data;
  final bool isDark;
  final VoidCallback onExploreProjects;
  final VoidCallback onContactMe;

  const HeroSection({
    super.key,
    required this.data,
    required this.isDark,
    required this.onExploreProjects,
    required this.onContactMe,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = WebTheme.isMobile(context);
    final isTablet = WebTheme.isTablet(context);

    return ClipRect(
      child: Stack(
        children: [
          // ── Hero Background Wallpaper ONLY in Hero Section ───────────────────
          Positioned.fill(
            child: Image.asset(
              'assets/img/web-background.png',
              fit: BoxFit.cover,
              alignment: Alignment.center,
              errorBuilder: (context, error, stackTrace) => Container(
                color: isDark ? WebColors.darkSurface : WebColors.lightSurfaceElevated,
              ),
            ),
          ),

          // ── ~40% Blur with ImageFilter (background image remains clearly visible) ──
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 7.5, sigmaY: 7.5),
              child: const SizedBox.expand(),
            ),
          ),

          // ── Soft Warm Vignette Overlay ──────────────────────────────────────
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.25,
                  colors: [
                    Colors.transparent,
                    isDark
                        ? Colors.black.withValues(alpha: 0.45)
                        : const Color(0xFF4A3E32).withValues(alpha: 0.12),
                  ],
                ),
              ),
            ),
          ),

          // ── Warm Overlay & Smooth Gradient Fade into Canvas Background ──────
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: isDark
                      ? [
                          const Color(0x55121110),
                          const Color(0x75121110),
                          const Color(0xC5121110),
                          WebColors.darkBackground,
                        ]
                      : [
                          const Color(0x22D4C6B2),
                          const Color(0x38E8E1D5),
                          const Color(0x95F3EFE9),
                          WebColors.lightBackground,
                        ],
                  stops: const [0.0, 0.40, 0.82, 1.0],
                ),
              ),
            ),
          ),

          // ── Hero Content (with top padding for floating top nav) ───────────
          ResponsiveContainer(
            padding: EdgeInsets.only(
              left: isMobile ? 18.0 : (isTablet ? 32.0 : 48.0),
              right: isMobile ? 18.0 : (isTablet ? 32.0 : 48.0),
              top: isMobile ? 88.0 : 108.0,
              bottom: isMobile ? 36.0 : 64.0,
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 990;

                return isWide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Left Side: Avatar + Details
                          Expanded(
                            flex: 6,
                            child: _buildProfileHeroContent(context, isMobile: false),
                          ),
                          const SizedBox(width: 32),
                          // Right Side: 2x2 Stats Card + Vertical Quote
                          Expanded(
                            flex: 5,
                            child: _buildRightHeroContent(isMobile: false),
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _buildProfileHeroContent(context, isMobile: true),
                          const SizedBox(height: 36),
                          _buildRightHeroContent(isMobile: true),
                        ],
                      );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeroContent(BuildContext context, {required bool isMobile}) {
    final bioText = (data.user.about != null && data.user.about!.trim().isNotEmpty)
        ? data.user.about!.trim()
        : (data.user.bio != null && data.user.bio!.trim().isNotEmpty)
            ? data.user.bio!.trim()
            : (data.user.headline != null && data.user.headline!.trim().isNotEmpty)
                ? data.user.headline!.trim()
                : 'Passionate about building clean, scalable mobile applications and turning ideas into real products.';

    final avatar = HeroProfileAvatar(
      imageUrl: data.user.profileImage,
      name: data.user.name,
      size: isMobile ? 132.0 : 172.0,
      isDark: isDark,
    );

    final details = Column(
      crossAxisAlignment:
          isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        // Available for opportunities Badge
        EntranceFader(
          delay: const Duration(milliseconds: 100),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5.5),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0x38000000)
                  : const Color(0x40FFFFFF),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark
                    ? const Color(0x33FFFFFF)
                    : const Color(0x66FFFFFF),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7.5,
                  height: 7.5,
                  decoration: const BoxDecoration(
                    color: WebColors.emeraldAccent,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 7),
                Text(
                  'Available for opportunities',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? WebColors.darkTextPrimary : const Color(0xFF2C2723),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // User Name
        EntranceFader(
          delay: const Duration(milliseconds: 150),
          child: Text(
            data.user.name,
            textAlign: isMobile ? TextAlign.center : TextAlign.start,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: isMobile ? 32 : 44,
              fontWeight: FontWeight.w800,
              letterSpacing: -1.0,
              height: 1.15,
              color: isDark ? WebColors.darkTextPrimary : const Color(0xFF1C1917),
            ),
          ),
        ),
        const SizedBox(height: 6),

        // Role / Headline
        EntranceFader(
          delay: const Duration(milliseconds: 200),
          child: Text(
            (data.user.headline != null && data.user.headline!.trim().isNotEmpty)
                ? data.user.headline!.trim()
                : (data.roleTitles.isNotEmpty ? data.roleTitles.first : 'Flutter Developer'),
            textAlign: isMobile ? TextAlign.center : TextAlign.start,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: isMobile ? 17 : 20,
              fontWeight: FontWeight.w700,
              color: isDark ? WebColors.darkPrimaryLight : const Color(0xFF332D28),
              letterSpacing: -0.3,
            ),
          ),
        ),
        const SizedBox(height: 14),

        // Bio summary
        EntranceFader(
          delay: const Duration(milliseconds: 250),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Text(
              bioText,
              textAlign: isMobile ? TextAlign.center : TextAlign.start,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w400,
                height: 1.6,
                color: isDark ? WebColors.darkTextSecondary : const Color(0xFF4A433D),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Social Buttons & Download CV
        EntranceFader(
          delay: const Duration(milliseconds: 300),
          child: _buildSocialsAndCv(isMobile),
        ),
      ],
    );

    return isMobile
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              avatar,
              const SizedBox(height: 20),
              details,
            ],
          )
        : Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              avatar,
              const SizedBox(width: 28),
              Expanded(child: details),
            ],
          );
  }

  Widget _buildSocialsAndCv(bool isMobile) {
    final cvUrl = (data.user.cvLink != null && data.user.cvLink!.trim().isNotEmpty)
        ? data.user.cvLink!.trim()
        : ((data.resumeUrl != null && data.resumeUrl!.trim().isNotEmpty)
            ? data.resumeUrl!.trim()
            : ((data.user.resumeUrl != null && data.user.resumeUrl!.trim().isNotEmpty)
                ? data.user.resumeUrl!.trim()
                : null));

    final rawGithub = (data.user.socialLinks.github != null && data.user.socialLinks.github!.trim().isNotEmpty)
        ? data.user.socialLinks.github!.trim()
        : (data.user.githubUsername != null && data.user.githubUsername!.trim().isNotEmpty)
            ? data.user.githubUsername!.trim()
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

    final rawLinkedin = (data.user.socialLinks.linkedin != null && data.user.socialLinks.linkedin!.trim().isNotEmpty)
        ? data.user.socialLinks.linkedin!.trim()
        : null;

    final String? linkedinUrl;
    if (rawLinkedin == null || rawLinkedin.isEmpty) {
      linkedinUrl = null;
    } else if (rawLinkedin.startsWith('http://') || rawLinkedin.startsWith('https://')) {
      linkedinUrl = rawLinkedin;
    } else {
      final clean = rawLinkedin.replaceAll('@', '').trim();
      linkedinUrl = clean.isNotEmpty ? 'https://linkedin.com/in/$clean' : null;
    }

    final rawWebsite = (data.user.socialLinks.website != null && data.user.socialLinks.website!.trim().isNotEmpty)
        ? data.user.socialLinks.website!.trim()
        : null;

    final String? websiteUrl;
    if (rawWebsite == null || rawWebsite.isEmpty) {
      websiteUrl = null;
    } else if (rawWebsite.startsWith('http://') || rawWebsite.startsWith('https://')) {
      websiteUrl = rawWebsite;
    } else {
      websiteUrl = 'https://$rawWebsite';
    }

    final hasCv = cvUrl != null && cvUrl.isNotEmpty;
    final hasAnySocial = githubUrl != null || linkedinUrl != null || websiteUrl != null;

    // Hide entire row if user has no social buttons and no CV
    if (!hasCv && !hasAnySocial) {
      return const SizedBox.shrink();
    }

    return Wrap(
      alignment: isMobile ? WrapAlignment.center : WrapAlignment.start,
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (githubUrl != null)
          _buildCircleSocialIcon(Icons.code_rounded, githubUrl, 'GitHub'),
        if (linkedinUrl != null)
          _buildCircleSocialIcon(Icons.business_center_outlined, linkedinUrl, 'LinkedIn'),
        if (websiteUrl != null)
          _buildCircleSocialIcon(Icons.link_rounded, websiteUrl, 'Website'),

        // CV Pill Button (Visible ONLY if cvLink exists)
        if (hasCv) ...[
          const SizedBox(width: 4),
          _HeroCvButton(
            cvUrl: cvUrl,
            isDark: isDark,
          ),
        ],
      ],
    );
  }

  Widget _buildCircleSocialIcon(IconData icon, String url, String tooltip) {
    return _HeroIconButton(
      icon: icon,
      url: url,
      tooltip: tooltip,
      isDark: isDark,
    );
  }

  Widget _buildRightHeroContent({required bool isMobile}) {
    // Collect counts dynamically
    final projectsCount = data.projects.length;
    final expCount = data.experiences.length;
    final certCount = data.certificates.length;
    final skillsCount = data.skills.isNotEmpty ? data.skills.length : data.user.skills.length;

    final statsCard = ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: (isDark ? const Color(0x99201C19) : const Color(0x55FFFFFF)),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: (isDark ? const Color(0x33D4B982) : const Color(0x99FFFFFF)),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildStatBox(
                    icon: Icons.folder_outlined,
                    count: projectsCount > 0 ? projectsCount.toString() : '—',
                    label: 'Projects',
                    isMobile: isMobile,
                  ),
                  const SizedBox(width: 12),
                  _buildStatBox(
                    icon: Icons.business_center_outlined,
                    count: expCount > 0 ? expCount.toString() : '—',
                    label: 'Years Experience',
                    isMobile: isMobile,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildStatBox(
                    icon: Icons.verified_outlined,
                    count: certCount > 0 ? certCount.toString() : '—',
                    label: 'Certificates',
                    isMobile: isMobile,
                  ),
                  const SizedBox(width: 12),
                  _buildStatBox(
                    icon: Icons.code_rounded,
                    count: skillsCount > 0 ? skillsCount.toString() : '—',
                    label: 'Skills',
                    isMobile: isMobile,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    final quoteBlock = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.format_quote_rounded,
          size: 34,
          color: isDark ? WebColors.darkPrimary : WebColors.lightPrimary,
        ),
        const SizedBox(height: 6),
        Text(
          'Build\nLearn\nCreate\nRepeat',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14.5,
            fontWeight: FontWeight.w700,
            height: 1.45,
            letterSpacing: -0.2,
            color: isDark ? WebColors.darkTextPrimary : const Color(0xFF2C2621),
          ),
        ),
      ],
    );

    return EntranceFader(
      delay: const Duration(milliseconds: 350),
      child: isMobile
          ? statsCard
          : Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                statsCard,
                const SizedBox(width: 26),
                quoteBlock,
              ],
            ),
    );
  }

  Widget _buildStatBox({
    required IconData icon,
    required String count,
    required String label,
    required bool isMobile,
  }) {
    return Container(
      width: isMobile ? 128 : 146,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(
        color: (isDark ? const Color(0x332E2822) : const Color(0x60FFFFFF)),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (isDark ? const Color(0x22D4B982) : const Color(0x80FFFFFF)),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isDark
                  ? WebColors.darkPrimary.withValues(alpha: 0.18)
                  : WebColors.lightPrimary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 19,
              color: isDark ? WebColors.darkPrimaryLight : WebColors.lightPrimary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  count,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                    color: isDark ? WebColors.darkTextPrimary : const Color(0xFF1B1917),
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: isDark ? WebColors.darkTextMuted : const Color(0xFF6B6258),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroIconButton extends StatefulWidget {
  final IconData icon;
  final String url;
  final String tooltip;
  final bool isDark;

  const _HeroIconButton({
    required this.icon,
    required this.url,
    required this.tooltip,
    required this.isDark,
  });

  @override
  State<_HeroIconButton> createState() => _HeroIconButtonState();
}

class _HeroIconButtonState extends State<_HeroIconButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: () async {
            final raw = widget.url.trim();
            if (raw.isEmpty) return;
            final normalized = (raw.startsWith('http://') || raw.startsWith('https://'))
                ? raw
                : 'https://$raw';
            final uri = Uri.tryParse(normalized);
            if (uri != null) {
              try {
                await launchUrl(
                  uri,
                  mode: LaunchMode.externalApplication,
                  webOnlyWindowName: '_blank',
                );
              } catch (e) {
                debugPrint('[_HeroIconButton] Failed to launch $uri: $e');
              }
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: (widget.isDark ? WebColors.darkSurface : WebColors.lightSurface)
                  .withValues(alpha: _hovered ? 0.95 : 0.75),
              border: Border.all(
                color: _hovered
                    ? (widget.isDark ? WebColors.darkPrimary : WebColors.lightPrimary)
                    : (widget.isDark ? WebColors.darkBorder : const Color(0xFFE2DCD1)),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: _hovered ? 0.12 : 0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              widget.icon,
              size: 16,
              color: widget.isDark
                  ? (_hovered ? WebColors.darkPrimaryLight : WebColors.darkTextPrimary)
                  : (_hovered ? WebColors.lightPrimaryDark : WebColors.lightTextPrimary),
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroCvButton extends StatefulWidget {
  final String cvUrl;
  final bool isDark;

  const _HeroCvButton({
    required this.cvUrl,
    required this.isDark,
  });

  @override
  State<_HeroCvButton> createState() => _HeroCvButtonState();
}

class _HeroCvButtonState extends State<_HeroCvButton> {
  bool _hovered = false;

  Future<void> _handleOpenCv() async {
    final uri = Uri.tryParse(widget.cvUrl.trim());
    if (uri != null) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
        webOnlyWindowName: '_blank',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: _handleOpenCv,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: (widget.isDark ? WebColors.darkSurface : const Color(0xFFFFFFFF))
                .withValues(alpha: _hovered ? 0.95 : 0.75),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _hovered
                  ? (widget.isDark ? WebColors.darkPrimary : WebColors.lightPrimary)
                  : (widget.isDark ? WebColors.darkBorder : const Color(0xFFE2DCD1)),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: _hovered ? 0.1 : 0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.description_outlined,
                size: 15,
                color: widget.isDark ? WebColors.darkPrimaryLight : WebColors.lightPrimary,
              ),
              const SizedBox(width: 6),
              Text(
                'CV',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: widget.isDark ? WebColors.darkTextPrimary : const Color(0xFF2B2520),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
