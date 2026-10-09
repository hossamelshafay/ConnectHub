import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../features/portfolio/data/models/project_model.dart';
import '../theme/web_colors.dart';
import '../theme/web_text_styles.dart';
import '../theme/web_theme.dart';
import '../models/portfolio_view_data.dart';
import '../widgets/responsive_container.dart';
import '../widgets/web_section_header.dart';
import '../widgets/tech_badge.dart';
import '../animations/entrance_fader.dart';
import '../animations/hover_tilt_card.dart';
import '../responsive/responsive.dart';

/// Projects Section showcasing responsive project cards with GitHub and Demo links.
class ProjectsSection extends StatelessWidget {
  final PortfolioViewData data;
  final bool isDark;

  const ProjectsSection({
    super.key,
    required this.data,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    if (data.projects.isEmpty) {
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
            eyebrow: 'Selected Work',
            title: 'Featured Projects',
            subtitle:
                'Production-grade systems built with architectural excellence, '
                'high-performance rendering, and elegant user interaction.',
            isDark: isDark,
          ),

          // Adaptive Project Grid: Scales from 1 column on mobile to 2 or 3 columns on desktop
          ResponsiveGrid(
            maxCrossAxisExtent: 540,
            crossAxisSpacing: 24,
            mainAxisSpacing: 28,
            children: [
              for (int i = 0; i < data.projects.length; i++)
                _ProjectCard(
                  project: data.projects[i],
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

class _ProjectCard extends StatelessWidget {
  final ProjectModel project;
  final bool isDark;
  final int index;

  const _ProjectCard({
    required this.project,
    required this.isDark,
    required this.index,
  });

  Future<void> _openUrl(String? url) async {
    if (url == null || url.trim().isEmpty) return;
    final uri = Uri.tryParse(url.trim());
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildBanner() {
    final hasImage = project.imageUrl != null && project.imageUrl!.trim().isNotEmpty;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
      child: SizedBox(
        height: 160,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (hasImage)
              CachedNetworkImage(
                imageUrl: project.imageUrl!.trim(),
                fit: BoxFit.cover,
                placeholder: (context, url) => _buildPlaceholderBanner(),
                errorWidget: (context, url, error) => _buildPlaceholderBanner(),
              )
            else
              _buildPlaceholderBanner(),

            // Featured Badge
            if (project.isFeatured)
              Positioned(
                top: 14,
                right: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    gradient: WebColors.primaryGradient,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: WebColors.primary.withValues(alpha: 0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star_rounded, size: 14, color: Colors.white),
                      SizedBox(width: 4),
                      Text(
                        'Featured',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderBanner() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            WebColors.primaryDark.withValues(alpha: 0.35),
            WebColors.primary.withValues(alpha: 0.15),
            isDark ? WebColors.background : WebColors.lightBackground,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _GridBackgroundPainter(
                color: WebColors.primaryLight.withValues(alpha: 0.08),
              ),
            ),
          ),
          Center(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: WebColors.surface.withValues(alpha: 0.7),
                border: Border.all(
                  color: WebColors.border,
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.terminal_rounded,
                size: 38,
                color: WebColors.primaryLight,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasGithub = project.githubUrl != null && project.githubUrl!.trim().isNotEmpty;
    final hasDemo = project.projectUrl != null && project.projectUrl!.trim().isNotEmpty;

    return EntranceFader(
      delay: Duration(milliseconds: 100 * index),
      child: HoverTiltCard(
        backgroundColor: isDark ? WebColors.surfaceCard : WebColors.lightSurface,
        borderColor: isDark ? WebColors.border : WebColors.lightBorder,
        hoverBorderColor: WebColors.primaryLight,
        borderRadius: BorderRadius.circular(16),
        enableScale: true,
        hoverScale: 1.018,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Architectural Banner or Real Network Image
            _buildBanner(),

            // Card Body with Generous Spacing
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    project.title,
                    style: WebTextStyles.cardTitle(isDark: isDark).copyWith(
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    project.description,
                    style: WebTextStyles.bodyMedium(isDark: isDark).copyWith(
                      fontSize: 14,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Technology Tags
                  if (project.technologies.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: project.technologies.map((tech) {
                        return TechBadge(label: tech, isDark: isDark);
                      }).toList(),
                    ),

                  if (hasGithub || hasDemo) ...[
                    const SizedBox(height: 24),
                    // Premium Action Buttons Row
                    Wrap(
                      spacing: 12,
                      runSpacing: 10,
                      children: [
                        if (hasGithub)
                          _buildGitHubButton(
                            url: project.githubUrl!.trim(),
                          ),
                        if (hasDemo)
                          _buildDemoButton(
                            url: project.projectUrl!.trim(),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGitHubButton({required String url}) {
    return _InteractiveButton(
      icon: Icons.code_rounded,
      label: 'View Code',
      badge: 'GitHub',
      isPrimary: true,
      onTap: () => _openUrl(url),
      isDark: isDark,
    );
  }

  Widget _buildDemoButton({required String url}) {
    return _InteractiveButton(
      icon: Icons.open_in_new_rounded,
      label: 'Live Preview',
      badge: null,
      isPrimary: false,
      onTap: () => _openUrl(url),
      isDark: isDark,
    );
  }
}

class _InteractiveButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final String? badge;
  final bool isPrimary;
  final VoidCallback onTap;
  final bool isDark;

  const _InteractiveButton({
    required this.icon,
    required this.label,
    this.badge,
    required this.isPrimary,
    required this.onTap,
    required this.isDark,
  });

  @override
  State<_InteractiveButton> createState() => _InteractiveButtonState();
}

class _InteractiveButtonState extends State<_InteractiveButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: widget.isPrimary
                ? (_isHovered
                    ? WebColors.primary
                    : WebColors.primary.withValues(alpha: 0.15))
                : (_isHovered
                    ? WebColors.accent.withValues(alpha: 0.2)
                    : (widget.isDark ? WebColors.surfaceCard : WebColors.lightSurface)),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: widget.isPrimary
                  ? (_isHovered ? WebColors.primaryLight : WebColors.primary.withValues(alpha: 0.6))
                  : (_isHovered ? WebColors.accent : WebColors.border),
              width: 1.1,
            ),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: (widget.isPrimary ? WebColors.primary : WebColors.accent)
                          .withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                size: 16,
                color: widget.isPrimary && _isHovered
                    ? Colors.white
                    : WebColors.primaryLight,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: widget.isPrimary && _isHovered
                        ? Colors.white
                        : (widget.isDark ? WebColors.textPrimary : WebColors.lightTextPrimary),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (widget.badge != null) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: WebColors.accent.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    widget.badge!,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: WebColors.secondaryAccent,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _GridBackgroundPainter extends CustomPainter {
  final Color color;

  _GridBackgroundPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 0.8;

    const spacing = 20.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GridBackgroundPainter oldDelegate) => false;
}
