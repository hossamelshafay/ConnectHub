import 'package:connecthub/features/profile/data/models/user_model.dart';
import 'package:connecthub/features/portfolio/data/models/project_model.dart';
import 'package:connecthub/features/portfolio/data/models/experience_model.dart';
import 'package:connecthub/features/portfolio/data/models/education_model.dart';
import 'package:connecthub/features/portfolio/data/models/certificate_model.dart';
import 'package:connecthub/web_portfolio/models/portfolio_view_data.dart';

/// Test helper providing test data for UI widget responsiveness tests only.
class PortfolioTestHelper {
  PortfolioTestHelper._();

  static PortfolioViewData getTestPortfolio() {
    final user = UserModel(
      uid: 'test_uid',
      name: 'Test User',
      email: 'test@example.com',
      username: 'testuser',
      headline: 'Software Engineer',
      about: 'Test About Description',
      location: 'Test City',
      socialLinks: const SocialLinksModel(
        github: 'https://github.com',
        linkedin: 'https://linkedin.com',
      ),
      skills: ['Flutter', 'Dart'],
      accountType: AccountType.professional,
      portfolioCompleted: true,
    );

    final projects = [
      ProjectModel(
        id: 'proj-1',
        title: 'Test Project',
        description: 'Test Project Description',
        technologies: ['Flutter', 'Dart'],
        isFeatured: true,
        startDate: DateTime(2025, 1, 1),
      ),
    ];

    final experiences = [
      ExperienceModel(
        id: 'exp-1',
        company: 'Test Company',
        role: 'Test Role',
        location: 'Remote',
        isCurrent: true,
        startDate: DateTime(2024, 1, 1),
        description: 'Test Experience Description',
        skills: ['Flutter'],
      ),
    ];

    final educations = [
      EducationModel(
        id: 'edu-1',
        institution: 'Test University',
        degree: 'Bachelor of Science',
        fieldOfStudy: 'Computer Science',
        startDate: DateTime(2016, 9, 1),
        endDate: DateTime(2020, 6, 30),
      ),
    ];

    final certificates = [
      CertificateModel(
        id: 'cert-1',
        title: 'Test Certificate',
        issuingOrganization: 'Test Organization',
        issueDate: DateTime(2023, 1, 1),
      ),
    ];

    final skills = const [
      SkillItem(name: 'Flutter', level: 0.9, category: 'Mobile & Core'),
    ];

    final stats = const [
      StatItem(count: 1, suffix: '+', label: 'Projects'),
    ];

    final roleTitles = const ['Software Engineer'];

    return PortfolioViewData(
      user: user,
      projects: projects,
      experiences: experiences,
      educations: educations,
      certificates: certificates,
      skills: skills,
      stats: stats,
      roleTitles: roleTitles,
    );
  }
}
