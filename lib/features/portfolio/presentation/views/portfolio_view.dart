import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:connecthub/core/utils/app_widgets.dart';
import 'package:connecthub/features/profile/data/models/user_model.dart';
import 'package:connecthub/features/portfolio/data/models/project_model.dart';
import 'package:connecthub/features/portfolio/data/models/experience_model.dart';
import 'package:connecthub/features/portfolio/data/models/education_model.dart';
import 'package:connecthub/features/portfolio/data/models/certificate_model.dart';
import 'package:connecthub/features/portfolio/presentation/cubit/portfolio_cubit.dart';
import 'package:connecthub/features/portfolio/presentation/cubit/portfolio_state.dart';
import 'package:connecthub/features/portfolio/presentation/views/portfolio_setup_view.dart';
import 'package:connecthub/features/portfolio/presentation/widgets/portfolio_switch_button.dart';
import 'package:connecthub/features/portfolio_import/presentation/cubit/portfolio_editor_cubit.dart';
import 'package:connecthub/features/portfolio_import/presentation/cubit/portfolio_import_state.dart';
import 'package:connecthub/features/portfolio_import/presentation/widgets/upload_cv_button.dart';
import 'package:connecthub/features/portfolio_import/presentation/widgets/experience_form_sheet.dart';
import 'package:connecthub/features/portfolio_import/presentation/widgets/project_form_sheet.dart';
import 'package:connecthub/features/portfolio_import/presentation/widgets/education_form_sheet.dart';
import 'package:connecthub/features/portfolio_import/presentation/widgets/certificate_form_sheet.dart';
import 'package:connecthub/features/portfolio_import/presentation/widgets/skills_editor_sheet.dart';
import 'package:connecthub/core/config/portfolio_config.dart';
import 'package:connecthub/features/generate_website/presentation/widgets/generate_website_button.dart';

/// The Professional Portfolio View (Phase 1).
///
/// Designed as a modern portfolio with neutral Material 3 aesthetics.
/// Uses clean slate, zinc, and dark surfaces with sky accents.
class PortfolioView extends StatelessWidget {
  final String userId;
  final bool isCurrentUser;
  final bool showBackButton;
  final VoidCallback? onSwitchToSocial;

  const PortfolioView({
    super.key,
    required this.userId,
    required this.isCurrentUser,
    this.showBackButton = false,
    this.onSwitchToSocial,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => PortfolioCubit()..loadPortfolio(userId)),
        BlocProvider(create: (_) => PortfolioEditorCubit()),
      ],
      child: _PortfolioViewBody(
        userId: userId,
        isCurrentUser: isCurrentUser,
        showBackButton: showBackButton,
        onSwitchToSocial: onSwitchToSocial,
      ),
    );
  }
}

class _PortfolioViewBody extends StatelessWidget {
  final String userId;
  final bool isCurrentUser;
  final bool showBackButton;
  final VoidCallback? onSwitchToSocial;

  const _PortfolioViewBody({
    required this.userId,
    required this.isCurrentUser,
    required this.showBackButton,
    this.onSwitchToSocial,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        leading: showBackButton
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new,
                    size: 18, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: const Text(
          'Portfolio',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        actions: [
          BlocBuilder<PortfolioCubit, PortfolioState>(
            builder: (context, state) {
              if (state is! PortfolioLoaded) return const SizedBox.shrink();
              final user = state.user;
              return Row(
                children: [
                  GenerateWebsiteButton(
                    user: user,
                    isOwner: isCurrentUser,
                    compact: true,
                    onWebsiteGenerated: () =>
                        context.read<PortfolioCubit>().loadPortfolio(userId),
                  ),
                  if (isCurrentUser)
                    IconButton(
                      icon: const Icon(Icons.tune_rounded,
                          color: Color(0xFF38BDF8), size: 22),
                      tooltip: 'Configure Portfolio',
                      onPressed: () => _openSetup(context, user),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: BlocListener<PortfolioEditorCubit, PortfolioEditorState>(
        listener: (context, editorState) {
          if (editorState is PortfolioEditorSaved) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(editorState.message),
                backgroundColor: const Color(0xFF0EA5E9),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          } else if (editorState is PortfolioEditorError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${editorState.message}'),
                backgroundColor: const Color(0xFFEF4444),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          }
        },
        child: BlocBuilder<PortfolioCubit, PortfolioState>(
          buildWhen: (previous, current) {
            // Always rebuild when we have a fresh PortfolioLoaded state.
            // Do NOT rebuild (return false) for transient update states so
            // the last rendered PortfolioLoaded stays visible.
            if (current is PortfolioUpdating || current is PortfolioUpdateSuccess) {
              return false;
            }
            return true;
          },
          builder: (context, state) {
            if (state is PortfolioLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF38BDF8)),
              );
            }

            if (state is PortfolioError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    state.message,
                    style: const TextStyle(color: Color(0xFF94A3B8)),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            if (state is! PortfolioLoaded) {
              return const SizedBox.shrink();
            }

            final user = state.user;
            final vis = user.sectionVisibility;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Incomplete Portfolio Banner ────────────────────────────
                  if (isCurrentUser && !user.portfolioCompleted)
                    _buildIncompleteBanner(context, user),

                  // ── AI Portfolio Import Button ─────────────────────────────
                  if (isCurrentUser) ...[
                    UploadCvButton(
                      userId: userId,
                      onImportComplete: () =>
                          context.read<PortfolioCubit>().loadPortfolio(userId),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // ── Hero Section ───────────────────────────────────────────
                  _HeroSection(
                    user: user,
                    isCurrentUser: isCurrentUser,
                    onEdit: () => _openSetup(context, user),
                    onSwitchToSocial: onSwitchToSocial,
                  ),

                  const SizedBox(height: 24),

                  // ── About Section ──────────────────────────────────────────
                  if (vis.about) ...[
                    _SectionCard(
                      title: 'About',
                      icon: Icons.person_pin_rounded,
                      action: isCurrentUser
                          ? IconButton(
                              icon: const Icon(Icons.edit_outlined,
                                  color: Color(0xFF38BDF8), size: 20),
                              tooltip: 'Edit About',
                              onPressed: () => _openSetup(context, user),
                            )
                          : null,
                      child: user.about != null && user.about!.trim().isNotEmpty
                          ? Text(
                              user.about!.trim(),
                              style: const TextStyle(
                                color: Color(0xFFCBD5E1),
                                fontSize: 14,
                                height: 1.6,
                              ),
                            )
                          : _buildEmptyState(
                              icon: Icons.notes_rounded,
                              message:
                                  'A comprehensive summary of your expertise and professional journey will appear here.',
                            ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // ── Experience Section ─────────────────────────────────────
                  if (vis.experience) ...[
                    _SectionCard(
                      title: 'Experience',
                      icon: Icons.work_outline_rounded,
                      action: isCurrentUser
                          ? IconButton(
                              icon: const Icon(Icons.add_circle_outline,
                                  color: Color(0xFF38BDF8), size: 20),
                              tooltip: 'Add Experience',
                              onPressed: () => ExperienceFormSheet.show(
                                context,
                                uid: userId,
                              ),
                            )
                          : null,
                      child: state.experience.isNotEmpty
                          ? Column(
                              children: state.experience
                                  .where((e) => isCurrentUser || e.isVisible)
                                  .map((exp) => _ExperienceTile(
                                        exp: exp,
                                        isCurrentUser: isCurrentUser,
                                        onEdit: () => ExperienceFormSheet.show(
                                          context,
                                          uid: userId,
                                          experience: exp,
                                        ),
                                        onDelete: () => _confirmDelete(
                                          context,
                                          title: 'Experience',
                                          itemTitle:
                                              '${exp.role} at ${exp.company}',
                                          onConfirmed: () => context
                                              .read<PortfolioEditorCubit>()
                                              .deleteExperience(
                                                uid: userId,
                                                experienceId: exp.id,
                                              ),
                                        ),
                                      ))
                                  .toList(),
                            )
                          : _buildEmptyState(
                              icon: Icons.business_center_outlined,
                              message: isCurrentUser
                                  ? 'No work experience added yet. Tap + to add or import from CV.'
                                  : 'No work experience added yet.',
                            ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // ── Projects Section ───────────────────────────────────────
                  if (vis.projects) ...[
                    _SectionCard(
                      title: 'Projects',
                      icon: Icons.folder_special_outlined,
                      action: isCurrentUser
                          ? IconButton(
                              icon: const Icon(Icons.add_circle_outline,
                                  color: Color(0xFF38BDF8), size: 20),
                              tooltip: 'Add Project',
                              onPressed: () => ProjectFormSheet.show(
                                context,
                                uid: userId,
                              ),
                            )
                          : null,
                      child: state.projects.isNotEmpty
                          ? Column(
                              children: state.projects
                                  .where((p) => isCurrentUser || p.isVisible)
                                  .map((proj) => _ProjectTile(
                                        proj: proj,
                                        isCurrentUser: isCurrentUser,
                                        onEdit: () => ProjectFormSheet.show(
                                          context,
                                          uid: userId,
                                          project: proj,
                                        ),
                                        onDelete: () => _confirmDelete(
                                          context,
                                          title: 'Project',
                                          itemTitle: proj.title,
                                          onConfirmed: () => context
                                              .read<PortfolioEditorCubit>()
                                              .deleteProject(
                                                uid: userId,
                                                projectId: proj.id,
                                              ),
                                        ),
                                      ))
                                  .toList(),
                            )
                          : _buildEmptyState(
                              icon: Icons.code_rounded,
                              message: isCurrentUser
                                  ? 'No projects showcased yet. Tap + to add or import from CV.'
                                  : 'No projects showcased yet.',
                            ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // ── Skills Section ─────────────────────────────────────────
                  if (vis.skills) ...[
                    _SectionCard(
                      title: 'Skills & Technologies',
                      icon: Icons.psychology_outlined,
                      action: isCurrentUser
                          ? IconButton(
                              icon: Icon(
                                user.skills.isEmpty
                                    ? Icons.add_circle_outline
                                    : Icons.edit_outlined,
                                color: const Color(0xFF38BDF8),
                                size: 20,
                              ),
                              tooltip: 'Edit Skills',
                              onPressed: () => SkillsEditorSheet.show(
                                context,
                                uid: userId,
                                initialSkills: user.skills,
                              ),
                            )
                          : null,
                      child: user.skills.isNotEmpty
                          ? Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: user.skills
                                  .map((skill) => Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF0F172A),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border: Border.all(
                                              color: const Color(0xFF334155)),
                                        ),
                                        child: Text(
                                          skill,
                                          style: const TextStyle(
                                            color: Color(0xFF38BDF8),
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ))
                                  .toList(),
                            )
                          : _buildEmptyState(
                              icon: Icons.auto_awesome_outlined,
                              message: isCurrentUser
                                  ? 'No skills added yet. Tap + to add or import from CV.'
                                  : 'No skills showcased yet.',
                            ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // ── Education Section ──────────────────────────────────────
                  if (vis.education) ...[
                    _SectionCard(
                      title: 'Education',
                      icon: Icons.school_outlined,
                      action: isCurrentUser
                          ? IconButton(
                              icon: const Icon(Icons.add_circle_outline,
                                  color: Color(0xFF38BDF8), size: 20),
                              tooltip: 'Add Education',
                              onPressed: () => EducationFormSheet.show(
                                context,
                                uid: userId,
                              ),
                            )
                          : null,
                      child: state.education.isNotEmpty
                          ? Column(
                              children: state.education
                                  .where((e) => isCurrentUser || e.isVisible)
                                  .map((edu) => _EducationTile(
                                        edu: edu,
                                        isCurrentUser: isCurrentUser,
                                        onEdit: () => EducationFormSheet.show(
                                          context,
                                          uid: userId,
                                          education: edu,
                                        ),
                                        onDelete: () => _confirmDelete(
                                          context,
                                          title: 'Education',
                                          itemTitle:
                                              '${edu.degree} at ${edu.institution}',
                                          onConfirmed: () => context
                                              .read<PortfolioEditorCubit>()
                                              .deleteEducation(
                                                uid: userId,
                                                educationId: edu.id,
                                              ),
                                        ),
                                      ))
                                  .toList(),
                            )
                          : _buildEmptyState(
                              icon: Icons.menu_book_rounded,
                              message: isCurrentUser
                                  ? 'No education history added yet. Tap + to add or import from CV.'
                                  : 'No education history added yet.',
                            ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // ── Certificates Section ───────────────────────────────────
                  if (vis.certificates) ...[
                    _SectionCard(
                      title: 'Certificates & Licenses',
                      icon: Icons.workspace_premium_outlined,
                      action: isCurrentUser
                          ? IconButton(
                              icon: const Icon(Icons.add_circle_outline,
                                  color: Color(0xFF38BDF8), size: 20),
                              tooltip: 'Add Certificate',
                              onPressed: () => CertificateFormSheet.show(
                                context,
                                uid: userId,
                              ),
                            )
                          : null,
                      child: state.certificates.isNotEmpty
                          ? Column(
                              children: state.certificates
                                  .where((c) => isCurrentUser || c.isVisible)
                                  .map((cert) => _CertificateTile(
                                        cert: cert,
                                        isCurrentUser: isCurrentUser,
                                        onEdit: () => CertificateFormSheet.show(
                                          context,
                                          uid: userId,
                                          certificate: cert,
                                        ),
                                        onDelete: () => _confirmDelete(
                                          context,
                                          title: 'Certificate',
                                          itemTitle: cert.title,
                                          onConfirmed: () => context
                                              .read<PortfolioEditorCubit>()
                                              .deleteCertificate(
                                                uid: userId,
                                                certificateId: cert.id,
                                              ),
                                        ),
                                      ))
                                  .toList(),
                            )
                          : _buildEmptyState(
                              icon: Icons.verified_outlined,
                              message: isCurrentUser
                                  ? 'No certificates listed yet. Tap + to add or import from CV.'
                                  : 'No licenses or certifications listed yet.',
                            ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // ── Contact Card ───────────────────────────────────────────
                  if (vis.contact) ...[
                    _ContactCard(user: user),
                    const SizedBox(height: 32),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildIncompleteBanner(BuildContext context, UserModel user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF38BDF8).withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: Color(0xFF38BDF8),
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Complete Your Portfolio',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Add your headline, bio, and social links to stand out.',
                  style: TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF38BDF8),
              foregroundColor: const Color(0xFF0F172A),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            onPressed: () => _openSetup(context, user),
            child: const Text(
              'Set Up',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String message,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF475569), size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 13,
                height: 1.45,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context, {
    required String title,
    required String itemTitle,
    required VoidCallback onConfirmed,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Delete $title?',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "$itemTitle"? This cannot be undone.',
          style: const TextStyle(color: Color(0xFF94A3B8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel',
                style: TextStyle(color: Color(0xFF94A3B8))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      onConfirmed();
    }
  }

  void _openSetup(BuildContext context, UserModel user) {
    final cubit = context.read<PortfolioCubit>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: PortfolioSetupView(user: user),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Hero Section
// ─────────────────────────────────────────────────────────────────────────────

class _HeroSection extends StatelessWidget {
  final UserModel user;
  final bool isCurrentUser;
  final VoidCallback onEdit;
  final VoidCallback? onSwitchToSocial;

  const _HeroSection({
    required this.user,
    required this.isCurrentUser,
    required this.onEdit,
    this.onSwitchToSocial,
  });

  @override
  Widget build(BuildContext context) {
    final headline = user.headline?.trim() ?? '';
    final location = user.location?.trim() ?? '';

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner area
          Container(
            height: 100,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF334155)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar overlapping banner
                Transform.translate(
                  offset: const Offset(0, -36),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF38BDF8),
                            width: 2,
                          ),
                        ),
                        child: UserAvatar(
                          name: user.name,
                          size: 78,
                          imageUrl: user.profileImage,
                        ),
                      ),
                      const Spacer(),
                      if (isCurrentUser)
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF334155),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                          ),
                          onPressed: onEdit,
                          icon: const Icon(Icons.edit_outlined, size: 16),
                          label: const Text(
                            'Edit',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Transform.translate(
                  offset: const Offset(0, -20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              user.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFF38BDF8)
                                  .withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'PRO',
                              style: TextStyle(
                                color: Color(0xFF38BDF8),
                                fontWeight: FontWeight.w800,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        headline.isNotEmpty
                            ? headline
                            : (isCurrentUser
                                ? 'Tap Edit to add your professional headline'
                                : 'Professional Member'),
                        style: TextStyle(
                          color: headline.isNotEmpty
                              ? const Color(0xFF38BDF8)
                              : const Color(0xFF64748B),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                        ),
                      ),
                      if (location.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              color: Color(0xFF94A3B8),
                              size: 15,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              location,
                              style: const TextStyle(
                                color: Color(0xFF94A3B8),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                      // If websiteGenerated == true, show only a small Website icon. Otherwise show nothing.
                      if (user.websiteGenerated) ...[
                        const SizedBox(height: 10),
                        Tooltip(
                          message: 'Visit Website',
                          child: InkWell(
                            onTap: () {
                              final targetUrl = user.websiteUrl ??
                                  (user.profileSlug != null
                                      ? PortfolioConfig.buildUrl(user.profileSlug!)
                                      : null);
                              if (targetUrl != null && targetUrl.trim().isNotEmpty) {
                                _ContactCard._launch(context, targetUrl);
                              }
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F172A),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFF38BDF8),
                                  width: 1.2,
                                ),
                              ),
                              child: const Icon(
                                Icons.language_rounded,
                                size: 16,
                                color: Color(0xFF38BDF8),
                              ),
                            ),
                          ),
                        ),
                      ],
                      if (onSwitchToSocial != null) ...[
                        const SizedBox(height: 14),
                        PortfolioSwitchButton(
                          target: ProfileSwitchTarget.social,
                          onPressed: onSwitchToSocial!,
                          isDarkTheme: true,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Reusable Section Card
// ─────────────────────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  final Widget? action;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF38BDF8), size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              ?action,
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Interactive Contact Card
// ─────────────────────────────────────────────────────────────────────────────

class _ContactCard extends StatelessWidget {
  final UserModel user;

  const _ContactCard({required this.user});

  @override
  Widget build(BuildContext context) {
    final links = user.socialLinks;
    final hasPhone = user.phone != null && user.phone!.trim().isNotEmpty;
    final hasLocation =
        user.location != null && user.location!.trim().isNotEmpty;
    final hasWebsite = links.website != null && links.website!.trim().isNotEmpty;
    final hasLinkedin =
        links.linkedin != null && links.linkedin!.trim().isNotEmpty;
    final hasGithub = links.github != null && links.github!.trim().isNotEmpty;
    final hasPortfolio =
        links.portfolio != null && links.portfolio!.trim().isNotEmpty;

    final hasAny = hasPhone ||
        hasLocation ||
        hasWebsite ||
        hasLinkedin ||
        hasGithub ||
        hasPortfolio;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.alternate_email_rounded,
                  color: Color(0xFF38BDF8), size: 20),
              SizedBox(width: 10),
              Text(
                'Contact & Links',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (!hasAny)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: const [
                  Icon(Icons.link_off_rounded,
                      color: Color(0xFF475569), size: 22),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'No contact details or social links provided yet.',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else ...[
            if (hasPhone)
              _ContactActionTile(
                icon: Icons.phone_outlined,
                label: 'Phone',
                value: user.phone!,
                onTap: () => _launch(context, 'tel:${user.phone!}'),
              ),
            if (hasLocation)
              _ContactActionTile(
                icon: Icons.location_on_outlined,
                label: 'Location',
                value: user.location!,
                onTap: () => _launch(
                  context,
                  'https://maps.google.com/?q=${Uri.encodeComponent(user.location!)}',
                ),
              ),
            if (hasWebsite)
              _ContactActionTile(
                icon: Icons.language_rounded,
                label: 'Website',
                value: links.website!,
                onTap: () => _launch(context, links.website!),
              ),
            if (hasLinkedin)
              _ContactActionTile(
                icon: Icons.business_center_outlined,
                label: 'LinkedIn',
                value: links.linkedin!,
                onTap: () => _launch(context, links.linkedin!),
              ),
            if (hasGithub)
              _ContactActionTile(
                icon: Icons.code_rounded,
                label: 'GitHub',
                value: user.githubUsername != null
                    ? '@${user.githubUsername}'
                    : links.github!,
                onTap: () => _launch(
                  context,
                  links.github!.startsWith('http')
                    ? links.github!
                    : 'https://github.com/${links.github!.replaceAll('@', '')}',
                ),
              ),
            if (hasPortfolio)
              _ContactActionTile(
                icon: Icons.web_asset_rounded,
                label: 'Portfolio Website',
                value: links.portfolio!,
                onTap: () => _launch(context, links.portfolio!),
              ),
          ],
        ],
      ),
    );
  }

  static Future<void> _launch(BuildContext context, String rawUrl) async {
    if (rawUrl.trim().isEmpty) return;
    String url = rawUrl.trim();
    if (!url.startsWith('http://') &&
        !url.startsWith('https://') &&
        !url.startsWith('tel:') &&
        !url.startsWith('mailto:')) {
      url = 'https://$url';
    }
    final uri = Uri.parse(url);
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not open $url')),
          );
        }
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open $url')),
        );
      }
    }
  }
}

class _ContactActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  const _ContactActionTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF334155)),
          ),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFF38BDF8), size: 18),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_outward_rounded,
                color: Color(0xFF64748B),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Subcollection Item Tiles (Placeholders for populated data in Phase 2)
// ─────────────────────────────────────────────────────────────────────────────

class _ExperienceTile extends StatelessWidget {
  final ExperienceModel exp;
  final bool isCurrentUser;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _ExperienceTile({
    required this.exp,
    this.isCurrentUser = false,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exp.role,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  exp.company,
                  style: const TextStyle(
                    color: Color(0xFF38BDF8),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (exp.location != null && exp.location!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    exp.location!,
                    style:
                        const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                  ),
                ],
                if (exp.description.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    exp.description,
                    style:
                        const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                  ),
                ],
                if (exp.skills.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: exp.skills
                        .map((s) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E293B),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                s,
                                style: const TextStyle(
                                    color: Color(0xFF38BDF8), fontSize: 10),
                              ),
                            ))
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
          if (isCurrentUser)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (onEdit != null)
                  IconButton(
                    icon: const Icon(Icons.edit_outlined,
                        size: 16, color: Color(0xFF94A3B8)),
                    padding: EdgeInsets.zero,
                    constraints:
                        const BoxConstraints(minWidth: 28, minHeight: 28),
                    onPressed: onEdit,
                    tooltip: 'Edit',
                  ),
                if (onDelete != null)
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded,
                        size: 16, color: Color(0xFFEF4444)),
                    padding: EdgeInsets.zero,
                    constraints:
                        const BoxConstraints(minWidth: 28, minHeight: 28),
                    onPressed: onDelete,
                    tooltip: 'Delete',
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _ProjectTile extends StatelessWidget {
  final ProjectModel proj;
  final bool isCurrentUser;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _ProjectTile({
    required this.proj,
    this.isCurrentUser = false,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        proj.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    if (proj.isFeatured)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color:
                              const Color(0xFF38BDF8).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'FEATURED',
                          style: TextStyle(
                            color: Color(0xFF38BDF8),
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
                if (proj.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    proj.description,
                    style: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 12,
                    ),
                  ),
                ],
                if (proj.technologies.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: proj.technologies
                        .map((t) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E293B),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                t,
                                style: const TextStyle(
                                    color: Color(0xFF38BDF8), fontSize: 10),
                              ),
                            ))
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
          if (isCurrentUser)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (onEdit != null)
                  IconButton(
                    icon: const Icon(Icons.edit_outlined,
                        size: 16, color: Color(0xFF94A3B8)),
                    padding: EdgeInsets.zero,
                    constraints:
                        const BoxConstraints(minWidth: 28, minHeight: 28),
                    onPressed: onEdit,
                    tooltip: 'Edit',
                  ),
                if (onDelete != null)
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded,
                        size: 16, color: Color(0xFFEF4444)),
                    padding: EdgeInsets.zero,
                    constraints:
                        const BoxConstraints(minWidth: 28, minHeight: 28),
                    onPressed: onDelete,
                    tooltip: 'Delete',
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _EducationTile extends StatelessWidget {
  final EducationModel edu;
  final bool isCurrentUser;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _EducationTile({
    required this.edu,
    this.isCurrentUser = false,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  edu.institution,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  edu.degree,
                  style: const TextStyle(
                    color: Color(0xFF38BDF8),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (edu.fieldOfStudy != null &&
                    edu.fieldOfStudy!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    edu.fieldOfStudy!,
                    style:
                        const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                  ),
                ],
                if (edu.grade != null && edu.grade!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Grade: ${edu.grade!}',
                    style:
                        const TextStyle(color: Color(0xFF64748B), fontSize: 11),
                  ),
                ],
              ],
            ),
          ),
          if (isCurrentUser)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (onEdit != null)
                  IconButton(
                    icon: const Icon(Icons.edit_outlined,
                        size: 16, color: Color(0xFF94A3B8)),
                    padding: EdgeInsets.zero,
                    constraints:
                        const BoxConstraints(minWidth: 28, minHeight: 28),
                    onPressed: onEdit,
                    tooltip: 'Edit',
                  ),
                if (onDelete != null)
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded,
                        size: 16, color: Color(0xFFEF4444)),
                    padding: EdgeInsets.zero,
                    constraints:
                        const BoxConstraints(minWidth: 28, minHeight: 28),
                    onPressed: onDelete,
                    tooltip: 'Delete',
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _CertificateTile extends StatelessWidget {
  final CertificateModel cert;
  final bool isCurrentUser;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _CertificateTile({
    required this.cert,
    this.isCurrentUser = false,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cert.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  cert.issuingOrganization,
                  style: const TextStyle(
                    color: Color(0xFF38BDF8),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (cert.credentialId != null &&
                    cert.credentialId!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    'ID: ${cert.credentialId!}',
                    style:
                        const TextStyle(color: Color(0xFF64748B), fontSize: 11),
                  ),
                ],
              ],
            ),
          ),
          if (isCurrentUser)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (onEdit != null)
                  IconButton(
                    icon: const Icon(Icons.edit_outlined,
                        size: 16, color: Color(0xFF94A3B8)),
                    padding: EdgeInsets.zero,
                    constraints:
                        const BoxConstraints(minWidth: 28, minHeight: 28),
                    onPressed: onEdit,
                    tooltip: 'Edit',
                  ),
                if (onDelete != null)
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded,
                        size: 16, color: Color(0xFFEF4444)),
                    padding: EdgeInsets.zero,
                    constraints:
                        const BoxConstraints(minWidth: 28, minHeight: 28),
                    onPressed: onDelete,
                    tooltip: 'Delete',
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
