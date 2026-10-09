import 'package:flutter_test/flutter_test.dart';
import 'package:connecthub/core/config/app_config.dart';
import 'package:connecthub/features/generate_website/data/models/public_portfolio_snapshot.dart';
import 'package:connecthub/features/portfolio/data/models/project_model.dart';
import 'package:connecthub/features/portfolio/data/models/experience_model.dart';

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

  group('PublicPortfolioSnapshot Tests', () {
    test('serializes toMap and deserializes fromMap correctly', () {
      final snapshot = PublicPortfolioSnapshot(
        uid: 'user_123',
        username: 'devpro',
        name: 'Developer Pro',
        headline: 'Lead Mobile Architect',
        bio: 'Passionate Flutter engineer',
        skills: ['Flutter', 'Dart', 'Firebase'],
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
        publicPortfolioUrl: 'https://connecthub.app/#/portfolio/devpro',
        websiteVersion: '1.0.0',
      );

      final map = snapshot.toMap(isFirstGeneration: true);
      expect(map['uid'], 'user_123');
      expect(map['username'], 'devpro');
      expect(map['name'], 'Developer Pro');
      expect(map['projects'], isA<List>());
      expect((map['projects'] as List).length, 1);
      expect(map['publicPortfolioUrl'], 'https://connecthub.app/#/portfolio/devpro');

      final reconstructed = PublicPortfolioSnapshot.fromMap(map, docId: 'devpro');
      expect(reconstructed.uid, 'user_123');
      expect(reconstructed.username, 'devpro');
      expect(reconstructed.name, 'Developer Pro');
      expect(reconstructed.skills, contains('Flutter'));
      expect(reconstructed.projects.first.title, 'ConnectHub');
      expect(reconstructed.experience.first.company, 'Tech Corp');

      final userModel = reconstructed.toUserModel();
      expect(userModel.uid, 'user_123');
      expect(userModel.name, 'Developer Pro');
      expect(userModel.headline, 'Lead Mobile Architect');
      expect(userModel.skills, contains('Flutter'));
    });
  });
}
