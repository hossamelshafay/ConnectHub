import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../features/portfolio/data/models/project_model.dart';
import '../theme/web_colors.dart';
import '../models/portfolio_view_data.dart';
import '../widgets/section_empty_state.dart';

/// Featured Projects Section matching the Titanium/Beige mockup design.
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
          icon: Icons.folder_open_rounded,
          message: 'No projects added yet.',
          isDark: isDark,
        ),
      );
    }

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
                      Icons.folder_outlined,
                      size: 20,
                      color: isDark ? WebColors.darkPrimaryLight : WebColors.lightPrimary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Featured Projects',
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

          // Layout grid of projects
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;

              if (width >= 820) {
                // Desktop: 3 project cards in a Row
                final displayProjects = data.projects.take(3).toList();
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (int i = 0; i < displayProjects.length; i++) ...[
                      if (i > 0) const SizedBox(width: 20),
                      Expanded(
                        child: _MockupProjectCard(
                          project: displayProjects[i],
                          isDark: isDark,
                        ),
                      ),
                    ],
                  ],
                );
              } else if (width >= 540) {
                // Tablet: 2 columns
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: data.projects.take(4).length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 18,
                    mainAxisSpacing: 18,
                    childAspectRatio: 0.82,
                  ),
                  itemBuilder: (context, index) {
                    return _MockupProjectCard(
                      project: data.projects[index],
                      isDark: isDark,
                    );
                  },
                );
              } else {
                // Mobile: Vertical Stack of project cards without squished aspect ratio
                final displayProjects = data.projects.take(3).toList();
                return Column(
                  children: [
                    for (int i = 0; i < displayProjects.length; i++) ...[
                      if (i > 0) const SizedBox(height: 18),
                      _MockupProjectCard(
                        project: displayProjects[i],
                        isDark: isDark,
                      ),
                    ],
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

class _MockupProjectCard extends StatefulWidget {
  final ProjectModel project;
  final bool isDark;

  const _MockupProjectCard({
    required this.project,
    required this.isDark,
  });

  @override
  State<_MockupProjectCard> createState() => _MockupProjectCardState();
}

class _MockupProjectCardState extends State<_MockupProjectCard> {
  bool _hovered = false;

  Future<void> _openUrl(String? url) async {
    if (url == null || url.trim().isEmpty) return;
    final uri = Uri.tryParse(url.trim());
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = widget.project.imageUrl != null && widget.project.imageUrl!.trim().isNotEmpty;
    final hasGithub = widget.project.githubUrl != null && widget.project.githubUrl!.trim().isNotEmpty;
    final hasDemo = widget.project.projectUrl != null && widget.project.projectUrl!.trim().isNotEmpty;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: widget.isDark
              ? (_hovered ? WebColors.darkSurfaceElevated : WebColors.darkSurface)
              : (_hovered ? const Color(0xFFFAF7F2) : const Color(0xFFFBF8F3)),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _hovered
                ? (widget.isDark ? WebColors.darkPrimary : WebColors.lightPrimary)
                : (widget.isDark ? WebColors.darkBorder : const Color(0xFFE5DDD0)),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: widget.isDark ? (_hovered ? 0.3 : 0.12) : (_hovered ? 0.09 : 0.03)),
              blurRadius: _hovered ? 18 : 10,
              offset: Offset(0, _hovered ? 6 : 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Project Preview Image Banner (inside card with rounded corners)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                height: 148,
                width: double.infinity,
                child: hasImage
                    ? CachedNetworkImage(
                        imageUrl: widget.project.imageUrl!.trim(),
                        fit: BoxFit.cover,
                        placeholder: (context, url) => _buildPlaceholder(),
                        errorWidget: (context, url, error) => _buildPlaceholder(),
                      )
                    : _buildPlaceholder(),
              ),
            ),
            const SizedBox(height: 14),

            // Title & GitHub Icon Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    widget.project.title,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                      color: widget.isDark ? WebColors.darkTextPrimary : const Color(0xFF1B1917),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (hasGithub) ...[
                  const SizedBox(width: 8),
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () => _openUrl(widget.project.githubUrl),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: widget.isDark ? WebColors.darkSurfaceCard : Colors.white,
                          border: Border.all(
                            color: widget.isDark ? WebColors.darkBorder : const Color(0xFFE4DDD1),
                          ),
                        ),
                        child: Icon(
                          Icons.code_rounded,
                          size: 15,
                          color: widget.isDark ? WebColors.darkTextPrimary : const Color(0xFF2C2723),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 6),

            // Description (fixed lines, clean whitespace)
            Text(
              widget.project.description,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12.5,
                fontWeight: FontWeight.w400,
                height: 1.45,
                color: widget.isDark ? WebColors.darkTextSecondary : const Color(0xFF5A524A),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),

            // Bottom Technologies & Floating Action Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Tech tags
                Expanded(
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: (widget.project.technologies.isNotEmpty
                            ? widget.project.technologies
                            : ['Flutter', 'Firebase'])
                        .take(3)
                        .map((tech) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: widget.isDark ? WebColors.darkSurfaceCard : const Color(0xFFF3ECE1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: widget.isDark ? WebColors.darkBorder : const Color(0xFFE6DEC3),
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          tech,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: widget.isDark ? WebColors.darkPrimaryLight : const Color(0xFF4A4035),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(width: 8),

                // Floating Action Button at bottom right
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => _openUrl(hasDemo
                        ? widget.project.projectUrl
                        : (hasGithub ? widget.project.githubUrl : null)),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.isDark ? const Color(0xFF88735C) : const Color(0xFF88735C),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF88735C).withValues(alpha: 0.35),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.arrow_outward_rounded,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Image.asset(
      'assets/img/projects.png',
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (context, error, stackTrace) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: widget.isDark
                ? [const Color(0xFF26221E), const Color(0xFF1B1816)]
                : [const Color(0xFFEDE6DA), const Color(0xFFE2D9CB)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Icon(
            Icons.devices_rounded,
            size: 34,
            color: widget.isDark ? WebColors.darkPrimary : WebColors.lightPrimary,
          ),
        ),
      ),
    );
  }
}
