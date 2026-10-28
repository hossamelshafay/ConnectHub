import 'package:flutter_test/flutter_test.dart';
import 'package:connecthub/core/config/app_config.dart';
import 'package:connecthub/features/generate_website/data/models/public_portfolio_snapshot.dart';
import 'package:connecthub/features/portfolio/data/models/project_model.dart';
import 'package:connecthub/features/portfolio/data/models/experience_model.dart';
import 'package:connecthub/features/portfolio/data/models/education_model.dart';
import 'package:connecthub/features/portfolio/data/models/certificate_model.dart';
import 'package:connecthub/features/profile/data/models/user_model.dart';
import 'package:connecthub/web_portfolio/data/datasources/web_portfolio_remote_data_source.dart';
import 'package:connecthub/web_portfolio/data/repositories/web_portfolio_repository_impl.dart';

class _FakeWebPortfolioRemoteDataSource implements WebPortfolioRemoteDataSource {
  final PublicPortfolioSnapshot? snapshotToReturn;
  _FakeWebPortfolioRemoteDataSource(this.snapshotToReturn);

  @override
  Future<PublicPortfolioSnapshot?> getPublicPortfolioSnapshot(
    String? identifier, {
    bool forceServer = false,
  }) async {
    return snapshotToReturn;
  }

  @override
  Future<UserModel?> getUserByIdOrUsername(String? identifier) async => null;

  @override
  Future<List<ProjectModel>> getProjects(String uid) async => [];

  @override
  Future<List<ExperienceModel>> getExperiences(String uid) async => [];

  @override
  Future<List<EducationModel>> getEducations(String uid) async => [];

  @override
  Future<List<CertificateModel>> getCertificates(String uid) async => [];
}

void main() {
  group('AppConfig Tests', () {
    test('buildPortfolioUrl constructs correct URL with identifier', () {
      final url = AppConfig.buildPortfolioUrl('elshaf3y');
      expect(url, contains('/#/portfolio/elshaf3y'));
      expect(url.startsWith('http'), isTrue);
    });

    test('buildPortfolioUrl handles spaces and trims input', () {
      final url = AppConfig.buildPortfolioUrl('  johndoe  ');
      expect(url, contains('/#/portfolio/johndoe'));
    });
  });

  group('PublicPortfolioSnapshot Exact Data Reflection Tests', () {
    test('Case A: User has no data -> strictly empty collections, no fabricated content', () async {
      final emptySnapshot = PublicPortfolioSnapshot(
        uid: 'new_user_empty',
        name: 'Brand New User',
        publicPortfolioUrl: 'https://connecthub-57eb5.web.app/#/portfolio/new_user_empty',
      );

      final map = emptySnapshot.toMap(isFirstGeneration: true);
      expect(map['uid'], 'new_user_empty');
      expect(map['projects'], isEmpty);
      expect(map['experience'], isEmpty);
      expect(map['education'], isEmpty);
      expect(map['certificates'], isEmpty);
      expect(map['skills'], isEmpty);
      expect(map['headline'], isNull);
      expect(map['bio'], isNull);

      final repo = WebPortfolioRepositoryImpl(
        remoteDataSource: _FakeWebPortfolioRemoteDataSource(emptySnapshot),
      );
      final viewData = await repo.getPortfolio('new_user_empty');

      expect(viewData.projects, isEmpty);
      expect(viewData.experiences, isEmpty);
      expect(viewData.educations, isEmpty);
      expect(viewData.certificates, isEmpty);
      expect(viewData.skills, isEmpty);
      expect(viewData.roleTitles, isEmpty);
      expect(viewData.user.name, 'Brand New User');
    });

    test('Case B: User has only bio -> bio present, other sections strictly empty', () async {
      final bioOnlySnapshot = PublicPortfolioSnapshot(
        uid: 'user_bio_only',
        name: 'Bio Only User',
        bio: 'Just an engineer getting started with my journey.',
        publicPortfolioUrl: 'https://connecthub-57eb5.web.app/#/portfolio/user_bio_only',
      );

      final repo = WebPortfolioRepositoryImpl(
        remoteDataSource: _FakeWebPortfolioRemoteDataSource(bioOnlySnapshot),
      );
      final viewData = await repo.getPortfolio('user_bio_only');

      expect(viewData.user.bio, 'Just an engineer getting started with my journey.');
      expect(viewData.projects, isEmpty);
      expect(viewData.experiences, isEmpty);
      expect(viewData.educations, isEmpty);
      expect(viewData.certificates, isEmpty);
      expect(viewData.skills, isEmpty);
      expect(viewData.roleTitles, isEmpty);
    });

    test('Case C: User has projects only -> projects populated, other sections empty', () async {
      final projectsOnlySnapshot = PublicPortfolioSnapshot(
        uid: 'user_projects_only',
        name: 'Project Builder',
        projects: const [
          ProjectModel(
            id: 'proj_unique_1',
            title: 'My Custom App',
            description: 'A genuine user project.',
            technologies: ['Dart', 'Flutter'],
          ),
        ],
        publicPortfolioUrl: 'https://connecthub-57eb5.web.app/#/portfolio/user_projects_only',
      );

      final repo = WebPortfolioRepositoryImpl(
        remoteDataSource: _FakeWebPortfolioRemoteDataSource(projectsOnlySnapshot),
      );
      final viewData = await repo.getPortfolio('user_projects_only');

      expect(viewData.projects.length, 1);
      expect(viewData.projects.first.title, 'My Custom App');
      expect(viewData.experiences, isEmpty);
      expect(viewData.educations, isEmpty);
      expect(viewData.certificates, isEmpty);
      expect(viewData.skills, isEmpty);
    });

    test('Case D: User has complete profile -> exact reflection of all Firestore fields', () async {
      final completeSnapshot = PublicPortfolioSnapshot(
        uid: 'user_complete_profile',
        username: 'completeuser',
        profileSlug: 'complete-user-slug',
        name: 'Complete Profile User',
        email: 'complete@example.com',
        headline: 'Lead Mobile Architect',
        bio: 'Passionate Flutter engineer',
        skills: const ['Flutter', 'Dart', 'Bloc'],
        projects: const [
          ProjectModel(
            id: 'proj_1',
            title: 'ConnectHub',
            description: 'Social app',
            technologies: ['Flutter', 'Dart'],
          ),
        ],
        experience: const [
          ExperienceModel(
            id: 'exp_1',
            company: 'Tech Corp',
            role: 'Senior Engineer',
          ),
        ],
        education: const [
          EducationModel(
            id: 'edu_1',
            institution: 'University of Engineering',
            degree: 'BS in Computer Science',
          ),
        ],
        certificates: const [
          CertificateModel(
            id: 'cert_1',
            title: 'Google Cloud Certified',
            issuingOrganization: 'Google',
          ),
        ],
        publicPortfolioUrl: 'https://connecthub-57eb5.web.app/#/portfolio/completeuser',
        websiteVersion: '1.0.0',
      );

      final map = completeSnapshot.toMap(isFirstGeneration: true);
      expect(map['uid'], 'user_complete_profile');
      expect(map['username'], 'completeuser');
      expect(map['profileSlug'], 'complete-user-slug');
      expect((map['projects'] as List).length, 1);
      expect((map['experience'] as List).length, 1);
      expect((map['education'] as List).length, 1);
      expect((map['certificates'] as List).length, 1);

      final reconstructed = PublicPortfolioSnapshot.fromMap(map, docId: 'completeuser');
      expect(reconstructed.uid, 'user_complete_profile');
      expect(reconstructed.projects.first.title, 'ConnectHub');
      expect(reconstructed.experience.first.company, 'Tech Corp');
      expect(reconstructed.education.first.institution, 'University of Engineering');
      expect(reconstructed.certificates.first.title, 'Google Cloud Certified');

      final repo = WebPortfolioRepositoryImpl(
        remoteDataSource: _FakeWebPortfolioRemoteDataSource(completeSnapshot),
      );
      final viewData = await repo.getPortfolio('completeuser');

      expect(viewData.projects.length, 1);
      expect(viewData.experiences.length, 1);
      expect(viewData.educations.length, 1);
      expect(viewData.certificates.length, 1);
      expect(viewData.skills.length, 3);
      expect(viewData.roleTitles, contains('Lead Mobile Architect'));
      expect(viewData.user.name, 'Complete Profile User');
    });
  });
}
