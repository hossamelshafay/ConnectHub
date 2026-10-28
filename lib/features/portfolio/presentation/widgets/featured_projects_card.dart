import 'package:flutter/material.dart';
import 'package:connecthub/features/portfolio/data/models/project_model.dart';
import 'package:connecthub/features/portfolio/presentation/widgets/portfolio_theme.dart';
import 'package:connecthub/features/portfolio/presentation/widgets/glass_card.dart';
import 'package:connecthub/features/portfolio/presentation/widgets/section_empty_state.dart';
import 'package:connecthub/features/portfolio/presentation/widgets/contact_card.dart';
import 'package:connecthub/features/profile/presentation/widgets/social_icons.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Featured Projects Card (Horizontal Scrollable Developer Cards)
// ─────────────────────────────────────────────────────────────────────────────
class FeaturedProjectsCard extends StatelessWidget {
  final List<ProjectModel> projects;
  final bool isCurrentUser;
  final VoidCallback onAdd;
  final ValueChanged<ProjectModel> onEdit;
  final ValueChanged<ProjectModel> onDelete;

  const FeaturedProjectsCard({
    super.key,
    required this.projects,
    required this.isCurrentUser,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.folder_outlined, color: kPortfolioTextSecondary, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Featured Projects',
                    style: TextStyle(
                      color: kPortfolioTextPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
              if (isCurrentUser)
                PillEditButton(
                  onTap: onAdd,
                  label: 'Add',
                  icon: Icons.add_rounded,
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (projects.isNotEmpty)
            SizedBox(
              height: 160,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: projects.length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final proj = projects[index];
                  return ProjectMockupCard(
                    proj: proj,
                    isCurrentUser: isCurrentUser,
                    onEdit: () => onEdit(proj),
                    onDelete: () => onDelete(proj),
                  );
                },
              ),
            )
          else
            PortfolioSectionEmptyState(
              icon: Icons.folder_outlined,
              title: 'No projects yet.',
              subtitle: 'Showcase your applications, designs, or open source repos.',
              actionLabel: isCurrentUser ? 'Add Project' : null,
              onAction: isCurrentUser ? onAdd : null,
            ),
        ],
      ),
    );
  }
}

class ProjectMockupCard extends StatelessWidget {
  final ProjectModel proj;
  final bool isCurrentUser;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ProjectMockupCard({
    super.key,
    required this.proj,
    this.isCurrentUser = false,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final hasUrl = proj.projectUrl != null && proj.projectUrl!.trim().isNotEmpty;
    final hasGithub = proj.githubUrl != null && proj.githubUrl!.trim().isNotEmpty;

    return Container(
      width: 255,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kPortfolioInnerCardBg,
        borderRadius: BorderRadius.circular(kPortfolioRadius),
        border: Border.all(color: kPortfolioCardBorder, width: 0.8),
        boxShadow: kPortfolioSoftShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: kPortfolioAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(Icons.terminal_rounded, size: 15, color: kPortfolioAccent),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  proj.title,
                  style: TextStyle(
                    color: kPortfolioTextPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (hasUrl) ...[
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: () => ContactCard.launchUrlSafe(context, proj.projectUrl!),
                  child: Icon(Icons.open_in_new_rounded, size: 14, color: kPortfolioTextMuted),
                ),
              ],
              if (hasGithub) ...[
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: () => ContactCard.launchUrlSafe(context, proj.githubUrl!),
                  child: SocialIcons.github(size: 14, color: kPortfolioTextMuted),
                ),
              ],
            ],
          ),
          Text(
            proj.description,
            style: TextStyle(
              color: kPortfolioTextSecondary,
              fontSize: 12,
              height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          Row(
            children: [
              Expanded(
                child: proj.technologies.isEmpty
                    ? const SizedBox.shrink()
                    : ClipRect(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: proj.technologies.map((tech) {
                              return Container(
                                margin: const EdgeInsets.only(right: 5),
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                                decoration: BoxDecoration(
                                  color: kPortfolioChipBg,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: kPortfolioChipBorder),
                                ),
                                child: Text(
                                  tech,
                                  style: TextStyle(
                                    color: kPortfolioTextSecondary,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
              ),
              if (isCurrentUser) ...[
                const SizedBox(width: 6),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (onEdit != null)
                      GestureDetector(
                        onTap: onEdit,
                        behavior: HitTestBehavior.opaque,
                        child: Padding(
                          padding: const EdgeInsets.all(3),
                          child: Icon(Icons.edit_outlined, size: 13, color: kPortfolioTextMuted),
                        ),
                      ),
                    if (onDelete != null)
                      GestureDetector(
                        onTap: onDelete,
                        behavior: HitTestBehavior.opaque,
                        child: const Padding(
                          padding: EdgeInsets.all(3),
                          child: Icon(Icons.delete_outline_rounded, size: 13, color: Color(0xFFEF4444)),
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
