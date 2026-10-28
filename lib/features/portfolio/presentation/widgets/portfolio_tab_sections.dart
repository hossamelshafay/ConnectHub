import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connecthub/features/profile/data/models/user_model.dart';
import 'package:connecthub/features/portfolio/presentation/cubit/portfolio_cubit.dart';
import 'package:connecthub/features/portfolio/presentation/cubit/portfolio_state.dart';
import 'package:connecthub/features/portfolio_import/presentation/cubit/portfolio_editor_cubit.dart';
import 'package:connecthub/features/portfolio_import/presentation/widgets/experience_form_sheet.dart';
import 'package:connecthub/features/portfolio_import/presentation/widgets/project_form_sheet.dart';
import 'package:connecthub/features/portfolio_import/presentation/widgets/education_form_sheet.dart';
import 'package:connecthub/features/portfolio_import/presentation/widgets/certificate_form_sheet.dart';
import 'package:connecthub/features/portfolio_import/presentation/widgets/skills_editor_sheet.dart';
import 'package:connecthub/features/portfolio/presentation/widgets/about_me_card.dart';
import 'package:connecthub/features/portfolio/presentation/widgets/skills_card.dart';
import 'package:connecthub/features/portfolio/presentation/widgets/featured_projects_card.dart';
import 'package:connecthub/features/portfolio/presentation/widgets/experience_card.dart';
import 'package:connecthub/features/portfolio/presentation/widgets/education_card.dart';
import 'package:connecthub/features/portfolio/presentation/widgets/certificates_card.dart';
import 'package:connecthub/features/portfolio/presentation/widgets/contact_card.dart';
import 'package:connecthub/features/portfolio/presentation/widgets/sheets/edit_about_sheet.dart';
import 'package:connecthub/features/portfolio/presentation/widgets/sheets/edit_contact_sheet.dart';
import 'package:connecthub/features/portfolio/presentation/widgets/sheets/portfolio_actions_sheet.dart';

class PortfolioTabSections extends StatelessWidget {
  final int selectedTabIndex;
  final PortfolioLoaded state;
  final UserModel user;
  final SectionVisibilityModel vis;
  final String userId;
  final bool isCurrentUser;

  const PortfolioTabSections({
    super.key,
    required this.selectedTabIndex,
    required this.state,
    required this.user,
    required this.vis,
    required this.userId,
    required this.isCurrentUser,
  });

  @override
  Widget build(BuildContext context) {
    final isOverview = selectedTabIndex == 0;

    final filteredProjects = isCurrentUser
        ? state.projects
        : state.projects.where((p) => p.isVisible).toList();
    final filteredExperience = isCurrentUser
        ? state.experience
        : state.experience.where((e) => e.isVisible).toList();
    final filteredEducation = isCurrentUser
        ? state.education
        : state.education.where((e) => e.isVisible).toList();
    final filteredCerts = isCurrentUser
        ? state.certificates
        : state.certificates.where((c) => c.isVisible).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── About Me
        if ((isOverview || selectedTabIndex == 0) && vis.about) ...[
          AboutMeCard(
            user: user,
            isCurrentUser: isCurrentUser,
            onEdit: () => EditAboutSheet.show(
              context,
              uid: userId,
              initialAbout: user.about,
            ),
          ),
          const SizedBox(height: 16),
        ],

        // ── Skills
        if ((isOverview || selectedTabIndex == 3) && vis.skills) ...[
          SkillsCard(
            skills: user.skills,
            isCurrentUser: isCurrentUser,
            onEdit: () => SkillsEditorSheet.show(
              context,
              uid: userId,
              initialSkills: user.skills,
              onSaved: (_) => context.read<PortfolioCubit>().loadPortfolio(userId),
            ),
            onAdd: () => SkillsEditorSheet.show(
              context,
              uid: userId,
              initialSkills: user.skills,
              onSaved: (_) => context.read<PortfolioCubit>().loadPortfolio(userId),
            ),
          ),
          const SizedBox(height: 16),
        ],

        // ── Featured Projects
        if ((isOverview || selectedTabIndex == 1) && vis.projects) ...[
          FeaturedProjectsCard(
            projects: filteredProjects,
            isCurrentUser: isCurrentUser,
            onAdd: () => ProjectFormSheet.show(
              context,
              uid: userId,
              portfolioCubit: context.read<PortfolioCubit>(),
            ),
            onEdit: (proj) => ProjectFormSheet.show(
              context,
              uid: userId,
              project: proj,
              portfolioCubit: context.read<PortfolioCubit>(),
            ),
            onDelete: (proj) => PortfolioActionsSheet.confirmDeleteItem(
              context,
              title: 'Project',
              itemTitle: proj.title,
              onConfirmed: () {
                context
                    .read<PortfolioEditorCubit>()
                    .deleteProject(uid: userId, projectId: proj.id);
                context.read<PortfolioCubit>().loadPortfolio(userId);
              },
            ),
          ),
          const SizedBox(height: 16),
        ],

        // ── Experience
        if ((isOverview || selectedTabIndex == 2) && vis.experience) ...[
          ExperienceCard(
            experience: filteredExperience,
            isCurrentUser: isCurrentUser,
            onAdd: () => ExperienceFormSheet.show(
              context,
              uid: userId,
              portfolioCubit: context.read<PortfolioCubit>(),
            ),
            onEdit: (exp) => ExperienceFormSheet.show(
              context,
              uid: userId,
              experience: exp,
              portfolioCubit: context.read<PortfolioCubit>(),
            ),
            onDelete: (exp) => PortfolioActionsSheet.confirmDeleteItem(
              context,
              title: 'Experience',
              itemTitle: '${exp.role} at ${exp.company}',
              onConfirmed: () {
                context
                    .read<PortfolioEditorCubit>()
                    .deleteExperience(uid: userId, experienceId: exp.id);
                context.read<PortfolioCubit>().loadPortfolio(userId);
              },
            ),
          ),
          const SizedBox(height: 16),
        ],

        // ── Education
        if ((isOverview || selectedTabIndex == 0) && vis.education) ...[
          EducationCard(
            education: filteredEducation,
            isCurrentUser: isCurrentUser,
            onAdd: () => EducationFormSheet.show(
              context,
              uid: userId,
              portfolioCubit: context.read<PortfolioCubit>(),
            ),
            onEdit: (edu) => EducationFormSheet.show(
              context,
              uid: userId,
              education: edu,
              portfolioCubit: context.read<PortfolioCubit>(),
            ),
            onDelete: (edu) => PortfolioActionsSheet.confirmDeleteItem(
              context,
              title: 'Education',
              itemTitle: '${edu.degree} at ${edu.institution}',
              onConfirmed: () {
                context
                    .read<PortfolioEditorCubit>()
                    .deleteEducation(uid: userId, educationId: edu.id);
                context.read<PortfolioCubit>().loadPortfolio(userId);
              },
            ),
          ),
          const SizedBox(height: 16),
        ],

        // ── Certificates
        if ((isOverview || selectedTabIndex == 4) && vis.certificates) ...[
          CertificatesCard(
            certificates: filteredCerts,
            isCurrentUser: isCurrentUser,
            onAdd: () => CertificateFormSheet.show(
              context,
              uid: userId,
              portfolioCubit: context.read<PortfolioCubit>(),
            ),
            onEdit: (cert) => CertificateFormSheet.show(
              context,
              uid: userId,
              certificate: cert,
              portfolioCubit: context.read<PortfolioCubit>(),
            ),
            onDelete: (cert) => PortfolioActionsSheet.confirmDeleteItem(
              context,
              title: 'Certificate',
              itemTitle: cert.title,
              onConfirmed: () {
                context
                    .read<PortfolioEditorCubit>()
                    .deleteCertificate(uid: userId, certificateId: cert.id);
                context.read<PortfolioCubit>().loadPortfolio(userId);
              },
            ),
          ),
          const SizedBox(height: 16),
        ],

        // ── Contact & Links
        if (isOverview && vis.contact) ...[
          ContactCard(
            user: user,
            isCurrentUser: isCurrentUser,
            onEdit: () => EditContactSheet.show(
              context,
              uid: userId,
              user: user,
            ),
          ),
        ],
      ],
    );
  }
}
