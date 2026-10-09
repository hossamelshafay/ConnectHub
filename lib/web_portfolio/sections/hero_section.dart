import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/web_colors.dart';
import '../theme/web_text_styles.dart';
import '../theme/web_theme.dart';
import '../models/portfolio_view_data.dart';
import '../widgets/responsive_container.dart';
import '../widgets/social_icon_button.dart';
import '../widgets/animated_glow_button.dart';
import '../widgets/hero_profile_avatar.dart';
import '../animations/entrance_fader.dart';
import '../animations/typing_text_animation.dart';
import '../animations/animated_counter.dart';
import '../animations/gold_shimmer.dart';

/// Luxury Hero Section — Black/Gold cinematic layout.
/// Left: intro + name with shimmer + typing role + CTA
/// Right: circular profile image with animated gold ring
/// Bottom: stats bar
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

    return ResponsiveContainer(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20.0 : 52.0,
        vertical: isMobile ? 40.0 : 80.0,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 900;
          final screenWidth = constraints.maxWidth;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isWide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 6,
                      child: _buildIntroContent(context, isMobile: false),
                    ),
                    const SizedBox(width: 64),
                    Expanded(
                      flex: 4,
                      child: EntranceFader(
                        delay: const Duration(milliseconds: 300),
                        offset: const Offset(20, 0),
                        child: HeroProfileAvatar(
                          imageUrl: data.user.profileImage,
                          name: data.user.name,
                          size: (screenWidth * 0.22).clamp(220.0, 300.0),
                          isDark: isDark,
                        ),
                      ),
                    ),
                  ],
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    EntranceFader(
                      delay: const Duration(milliseconds: 100),
                      offset: const Offset(0, -12),
                      child: HeroProfileAvatar(
                        imageUrl: data.user.profileImage,
                        name: data.user.name,
                        size: (screenWidth * 0.52).clamp(160.0, 220.0),
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(height: 40),
                    _buildIntroContent(context, isMobile: true),
                  ],
                ),

              const SizedBox(height: 60),

              // Stats bar
              _buildStatsContainer(screenWidth),
            ],
          );
        },
      ),
    );
  }

  Widget _buildIntroContent(BuildContext context, {required bool isMobile}) {
    return Column(
      crossAxisAlignment:
          isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        // Availability pill
        EntranceFader(
          offset: const Offset(0, 12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: WebColors.emeraldAccent.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: WebColors.emeraldAccent.withValues(alpha: 0.30),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: WebColors.emeraldAccent,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'AVAILABLE FOR NEW OPPORTUNITIES',
                    style: WebTextStyles.sectionSubtitle(isDark: isDark).copyWith(
                      color: WebColors.emeraldAccent,
                      fontSize: 10,
                      letterSpacing: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Hello, I'm
        EntranceFader(
          delay: const Duration(milliseconds: 100),
          child: Text(
            "Hello, I'm",
            style: WebTextStyles.cardSubtitle(isDark: isDark).copyWith(
              fontSize: isMobile ? 15 : 18,
              letterSpacing: 1.0,
              color: WebColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(height: 4),

        // Name with gold shimmer
        EntranceFader(
          delay: const Duration(milliseconds: 150),
          child: GoldShimmerText(
            duration: const Duration(milliseconds: 3500),
            child: Text(
              data.user.name,
              textAlign: isMobile ? TextAlign.center : TextAlign.start,
              style: isMobile
                  ? WebTextStyles.displayHeroMobile(isDark: isDark)
                  : WebTextStyles.displayHero(isDark: isDark),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Typing role
        EntranceFader(
          delay: const Duration(milliseconds: 250),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment:
                isMobile ? MainAxisAlignment.center : MainAxisAlignment.start,
            children: [
              const Text(
                '— ',
                style: TextStyle(
                  color: WebColors.textMuted,
                  fontSize: 18,
                  fontWeight: FontWeight.w300,
                ),
              ),
              Flexible(
                child: TypingTextAnimation(
                  texts: data.roleTitles,
                  textStyle: WebTextStyles.cardTitle(isDark: isDark).copyWith(
                    fontSize: isMobile ? 16 : 21,
                    fontWeight: FontWeight.w400,
                    color: WebColors.primaryLight,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Bio text
        EntranceFader(
          delay: const Duration(milliseconds: 350),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 580),
            child: Text(
              (data.user.about != null && data.user.about!.trim().isNotEmpty)
                  ? data.user.about!
                  : (data.user.bio != null && data.user.bio!.trim().isNotEmpty)
                      ? data.user.bio!
                      : (data.user.headline ?? ''),
              textAlign: isMobile ? TextAlign.center : TextAlign.start,
              style: isMobile
                  ? WebTextStyles.bodyMedium(isDark: isDark).copyWith(fontSize: 14)
                  : WebTextStyles.bodyLarge(isDark: isDark),
            ),
          ),
        ),
        const SizedBox(height: 36),

        // CTAs + socials
        EntranceFader(
          delay: const Duration(milliseconds: 450),
          child: Builder(
            builder: (context) {
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
              final resumeUrl = (data.resumeUrl != null && data.resumeUrl!.trim().isNotEmpty)
                  ? data.resumeUrl!.trim()
                  : (data.user.resumeUrl != null && data.user.resumeUrl!.trim().isNotEmpty)
                      ? data.user.resumeUrl!.trim()
                      : null;

              return Wrap(
                alignment: isMobile ? WrapAlignment.center : WrapAlignment.start,
                spacing: 12,
                runSpacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if (data.projects.isNotEmpty)
                    AnimatedGlowButton(
                      label: 'View Projects',
                      icon: Icons.arrow_downward_rounded,
                      onTap: onExploreProjects,
                      isDark: isDark,
                    ),
                  AnimatedGlowButton(
                    label: 'Contact Me',
                    icon: Icons.mail_outline_rounded,
                    isSecondary: true,
                    onTap: onContactMe,
                    isDark: isDark,
                  ),
                  if (resumeUrl != null)
                    AnimatedGlowButton(
                      label: 'Download CV',
                      icon: Icons.download_rounded,
                      isSecondary: true,
                      onTap: () async {
                        final uri = Uri.tryParse(resumeUrl);
                        if (uri != null && await canLaunchUrl(uri)) {
                          await launchUrl(uri, mode: LaunchMode.externalApplication);
                        }
                      },
                      isDark: isDark,
                    ),
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
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatsContainer(double screenWidth) {
    final isCompactStats = screenWidth < 680;

    return EntranceFader(
      delay: const Duration(milliseconds: 600),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth < 400 ? 12 : (isCompactStats ? 20 : 32),
          vertical: isCompactStats ? 20 : 28,
        ),
        decoration: BoxDecoration(
          color: WebColors.surfaceCard,
          borderRadius: BorderRadius.circular(12),
          border: const Border.fromBorderSide(
            BorderSide(color: WebColors.border, width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: isCompactStats
            ? GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: data.stats.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: screenWidth < 360 ? 10 : 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: screenWidth < 360 ? 1.5 : 1.9,
                ),
                itemBuilder: (context, i) =>
                    _buildStatItem(data.stats[i], isCompact: true),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  for (int i = 0; i < data.stats.length; i++) ...[
                    Expanded(
                      child: _buildStatItem(data.stats[i], isCompact: false),
                    ),
                    if (i < data.stats.length - 1)
                      Container(
                        height: 40,
                        width: 1,
                        color: WebColors.border,
                      ),
                  ],
                ],
              ),
      ),
    );
  }

  Widget _buildStatItem(StatItem stat, {required bool isCompact}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GoldShimmerText(
          duration: const Duration(milliseconds: 4000),
          child: AnimatedCounter(
            targetValue: stat.count,
            suffix: stat.suffix,
            style: WebTextStyles.statNumber(isDark: isDark).copyWith(
              fontSize: isCompact ? 26 : 36,
              color: WebColors.primary,
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          stat.label,
          textAlign: TextAlign.center,
          style: WebTextStyles.statLabel(isDark: isDark).copyWith(
            fontSize: isCompact ? 10 : 12,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
