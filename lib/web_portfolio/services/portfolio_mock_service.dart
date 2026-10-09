import '../../features/profile/data/models/user_model.dart';
import '../../features/portfolio/data/models/project_model.dart';
import '../../features/portfolio/data/models/experience_model.dart';
import '../../features/portfolio/data/models/education_model.dart';
import '../../features/portfolio/data/models/certificate_model.dart';
import '../models/portfolio_view_data.dart';

/// Provides placeholder portfolio data for initial UI rendering.
/// In the next phase, this will be substituted by a Firebase-backed service.
class PortfolioMockService {
  PortfolioMockService._();

  static PortfolioViewData getMockPortfolio() {
    final user = UserModel(
      uid: 'mock_uid_shafay',
      name: 'Hossam Shafay',
      email: 'hossam.shafay@example.com',
      username: 'shafay',
      headline: 'Senior Flutter Engineer & Mobile System Architect',
      about:
          'Passionate Senior Software Engineer specializing in cross-platform mobile development, '
          'clean architecture, and reactive state management. Over 5 years of experience building '
          'resilient, high-scale applications with Flutter, Dart, Firebase, and cloud backends. '
          'Dedicated to crafting pixel-perfect interfaces, robust architectures, and fluid animations.',
      location: 'Cairo, Egypt • Open to Remote Worldwide',
      phone: '+20 100 000 0000',
      socialLinks: const SocialLinksModel(
        github: 'https://github.com/hossamelshafay',
        linkedin: 'https://linkedin.com/in/hossamelshafay',
        website: 'https://connecthub.app',
      ),
      skills: [
        'Flutter',
        'Dart',
        'Bloc / Cubit',
        'Clean Architecture',
        'Firebase',
        'REST APIs',
        'CI/CD Pipelines',
        'State Management',
      ],
      sectionVisibility: const SectionVisibilityModel(),
      accountType: AccountType.professional,
      portfolioCompleted: true,
      followersCount: 1420,
      followingCount: 380,
    );

    final projects = [
      ProjectModel(
        id: 'proj-1',
        title: 'ConnectHub Social & AI Portfolio',
        description:
          'A cross-platform professional social networking platform featuring automated AI CV parsing, '
          'interactive portfolios, real-time messaging, clean architecture, and reactive Firestore streams.',
        technologies: ['Flutter', 'Bloc', 'FastAPI', 'Gemini AI', 'Firebase', 'Clean Arch'],
        githubUrl: 'https://github.com/hossamelshafay/ConnectHub',
        projectUrl: 'https://connecthub.app',
        isFeatured: true,
        startDate: DateTime(2025, 6, 1),
      ),
      ProjectModel(
        id: 'proj-2',
        title: 'Apex Market & E-Commerce Suite',
        description:
          'Enterprise-grade multi-vendor e-commerce application with real-time inventory updates, '
          'Stripe payments integration, localized multi-language support, and optimized caching.',
        technologies: ['Flutter', 'Riverpod', 'Node.js', 'Stripe', 'Redis', 'Docker'],
        githubUrl: 'https://github.com/hossamelshafay/apex-market',
        projectUrl: 'https://apexmarket.demo',
        isFeatured: true,
        startDate: DateTime(2024, 8, 1),
        endDate: DateTime(2025, 2, 1),
      ),
      ProjectModel(
        id: 'proj-3',
        title: 'Pulse Analytics & Health Tracker',
        description:
          'Real-time biometric data visualization engine with custom Canvas charts, BLE health peripheral '
          'synchronization, and offline-first encrypted SQLite database.',
        technologies: ['Flutter', 'CustomPainter', 'BLE', 'SQLite', 'Clean Arch', 'RxDart'],
        githubUrl: 'https://github.com/hossamelshafay/pulse-analytics',
        projectUrl: null,
        isFeatured: false,
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 7, 1),
      ),
      ProjectModel(
        id: 'proj-4',
        title: 'CloudVault Encrypted File Sync',
        description:
          'Zero-knowledge end-to-end encrypted cloud storage client with chunked file uploads, '
          'background download managers, and biometric authentication.',
        technologies: ['Flutter', 'AES-256 GCM', 'WebSockets', 'AWS S3', 'Bloc'],
        githubUrl: 'https://github.com/hossamelshafay/cloud-vault',
        projectUrl: null,
        isFeatured: false,
        startDate: DateTime(2023, 5, 1),
        endDate: DateTime(2023, 11, 1),
      ),
    ];

    final experiences = [
      ExperienceModel(
        id: 'exp-1',
        company: 'Vanguard Tech Solutions',
        role: 'Lead Mobile Architect',
        location: 'Remote',
        isCurrent: true,
        startDate: DateTime(2024, 3, 1),
        description:
          'Orchestrated cross-platform application architecture across 4 mission-critical applications. '
          'Reduced build times by 40% using automated CI/CD pipelines. Mentored junior and mid-level engineers.',
        skills: ['Flutter', 'Dart', 'Bloc', 'CI/CD', 'System Design'],
      ),
      ExperienceModel(
        id: 'exp-2',
        company: 'Nova Digital Agency',
        role: 'Senior Flutter Developer',
        location: 'Cairo, Egypt',
        isCurrent: false,
        startDate: DateTime(2022, 6, 1),
        endDate: DateTime(2024, 2, 28),
        description:
          'Engineered and shipped 8+ commercial Flutter applications across FinTech and healthcare sectors. '
          'Implemented custom physics-based animations and maintained 99.8% crash-free user sessions.',
        skills: ['Flutter', 'Firebase', 'REST APIs', 'App Store / Play Store Deployment'],
      ),
      ExperienceModel(
        id: 'exp-3',
        company: 'ByteCraft Interactive',
        role: 'Mobile Software Engineer',
        location: 'Alexandria, Egypt',
        isCurrent: false,
        startDate: DateTime(2020, 9, 1),
        endDate: DateTime(2022, 5, 31),
        description:
          'Developed responsive user interfaces, integrated third-party payment gateways, and wrote unit/integration tests '
          'achieving 85%+ test coverage across core modules.',
        skills: ['Dart', 'Flutter', 'Git', 'Unit Testing', 'Clean Architecture'],
      ),
    ];

    final educations = [
      EducationModel(
        id: 'edu-1',
        institution: 'Cairo University — Faculty of Computers and Artificial Intelligence',
        degree: 'Bachelor of Science in Computer Science',
        fieldOfStudy: 'Software Engineering & Intelligent Systems',
        startDate: DateTime(2016, 9, 1),
        endDate: DateTime(2020, 6, 30),
        grade: 'Very Good with Honors (GPA 3.6 / 4.0)',
        activities: 'Lead of Google Developer Student Club (GDSC), ICPC Competitive Programmer',
        description:
          'Specialized in Software Architecture, Distributed Systems, Data Structures & Algorithms, and Machine Learning.',
      ),
    ];

    final certificates = [
      CertificateModel(
        id: 'cert-1',
        title: 'Google Associate Android Developer Certification',
        issuingOrganization: 'Google',
        issueDate: DateTime(2023, 4, 1),
        credentialId: 'AAD-849204-FL',
        credentialUrl: 'https://credentials.google.com/verify/AAD-849204-FL',
      ),
      CertificateModel(
        id: 'cert-2',
        title: 'Flutter Advanced Architecture & State Management Specialist',
        issuingOrganization: 'Very Good Ventures / Google Developers',
        issueDate: DateTime(2022, 11, 1),
        credentialId: 'VGV-ARCH-9921',
        credentialUrl: 'https://credentials.example.com/verify/VGV-ARCH-9921',
      ),
      CertificateModel(
        id: 'cert-3',
        title: 'Meta Front-End & Mobile Professional Certificate',
        issuingOrganization: 'Meta',
        issueDate: DateTime(2021, 8, 1),
        credentialId: 'META-CERT-3819',
        credentialUrl: 'https://coursera.org/verify/META-CERT-3819',
      ),
    ];

    final skills = const [
      // Core & Mobile
      SkillItem(name: 'Flutter & Dart SDK', level: 0.96, category: 'Mobile & Core'),
      SkillItem(name: 'Clean Architecture & BLoC', level: 0.94, category: 'Mobile & Core'),
      SkillItem(name: 'Responsive & Adaptive UI/UX', level: 0.95, category: 'Mobile & Core'),
      SkillItem(name: 'Custom Animations & Shaders', level: 0.88, category: 'Mobile & Core'),

      // Cloud & Backend
      SkillItem(name: 'Firebase (Auth, Firestore, Storage)', level: 0.92, category: 'Cloud & Services'),
      SkillItem(name: 'RESTful APIs & WebSockets (Dio)', level: 0.92, category: 'Cloud & Services'),
      SkillItem(name: 'FastAPI & Python AI Integrations', level: 0.82, category: 'Cloud & Services'),

      // DevOps & Quality
      SkillItem(name: 'Git, GitHub Actions & CI/CD', level: 0.89, category: 'DevOps & Quality'),
      SkillItem(name: 'Unit, Widget & Integration Testing', level: 0.86, category: 'DevOps & Quality'),
      SkillItem(name: 'App Store & Play Console Deployment', level: 0.91, category: 'DevOps & Quality'),
    ];

    final stats = const [
      StatItem(count: 5, suffix: '+', label: 'Years Experience'),
      StatItem(count: 24, suffix: '+', label: 'Shipped Apps'),
      StatItem(count: 99, suffix: '%', label: 'Client Satisfaction'),
      StatItem(count: 15, suffix: 'k+', label: 'Github Commits'),
    ];

    final roleTitles = const [
      'Senior Flutter Engineer',
      'Mobile System Architect',
      'Clean Architecture Advocate',
      'Cross-Platform Specialist',
    ];

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
