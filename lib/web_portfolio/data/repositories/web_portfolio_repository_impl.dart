import '../../core/exceptions.dart';
import '../../domain/repositories/web_portfolio_repository.dart';
import '../../models/portfolio_view_data.dart';
import '../datasources/web_portfolio_remote_data_source.dart';
import '../../../features/portfolio/data/models/project_model.dart';
import '../../../features/portfolio/data/models/experience_model.dart';
import '../../../features/portfolio/data/models/certificate_model.dart';

/// Production implementation of [WebPortfolioRepository] with in-memory caching.
class WebPortfolioRepositoryImpl implements WebPortfolioRepository {
  final WebPortfolioRemoteDataSource remoteDataSource;

  /// In-memory cache keyed by normalized identifier to prevent redundant Firestore calls.
  final Map<String, PortfolioViewData> _cache = {};

  WebPortfolioRepositoryImpl({
    WebPortfolioRemoteDataSource? remoteDataSource,
  }) : remoteDataSource = remoteDataSource ?? WebPortfolioRemoteDataSourceImpl();

  @override
  void clearCache() {
    _cache.clear();
  }

  @override
  Future<PortfolioViewData> getPortfolio(String? identifier, {bool forceRefresh = false}) async {
    final cacheKey = (identifier ?? '__default__').toLowerCase().trim();

    // 1. Check in-memory cache if not forcing refresh
    if (!forceRefresh && _cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    // 2. Read ONLY public_portfolios snapshot (Zero subcollection reads, keeping users/ private)
    final snapshot = await remoteDataSource.getPublicPortfolioSnapshot(identifier);
    if (snapshot == null) {
      throw PortfolioNotFoundException(identifier ?? 'unknown');
    }

    final user = snapshot.toUserModel();
    final projects = snapshot.projects;
    final experiences = snapshot.experience;
    final educations = snapshot.education;
    final certificates = snapshot.certificates;

    final skillItems = _buildSkillItems(snapshot.skills);
    final roleTitles = _buildRoleTitles(snapshot.headline);
    final stats = _buildStats(
      projects: projects,
      experiences: experiences,
      certificates: certificates,
    );

    final viewData = PortfolioViewData(
      user: user,
      projects: projects,
      experiences: experiences,
      educations: educations,
      certificates: certificates,
      skills: skillItems,
      stats: stats,
      roleTitles: roleTitles,
      resumeUrl: snapshot.resumeUrl ?? user.resumeUrl,
    );

    _cache[cacheKey] = viewData;
    _cache[snapshot.uid.toLowerCase()] = viewData;
    if (snapshot.username != null && snapshot.username!.isNotEmpty) {
      _cache[snapshot.username!.toLowerCase()] = viewData;
    }
    return viewData;
  }

  List<SkillItem> _buildSkillItems(List<String> rawSkills) {
    if (rawSkills.isEmpty) {
      return const [];
    }

    return List.generate(rawSkills.length, (index) {
      final name = rawSkills[index].trim();
      final level = ((rawSkills.length - index) / rawSkills.length)
          .clamp(0.60, 1.0)
          .toDouble();

      return SkillItem(
        name: name,
        level: level,
        category: _categorizeSkill(name),
      );
    });
  }

  String _categorizeSkill(String skill) {
    final lower = skill.toLowerCase();
    if (lower.contains('flutter') ||
        lower.contains('dart') ||
        lower.contains('ui') ||
        lower.contains('frontend') ||
        lower.contains('react') ||
        lower.contains('swift') ||
        lower.contains('kotlin') ||
        lower.contains('mobile')) {
      return 'Mobile & Frontend';
    } else if (lower.contains('firebase') ||
        lower.contains('cloud') ||
        lower.contains('node') ||
        lower.contains('api') ||
        lower.contains('backend') ||
        lower.contains('python') ||
        lower.contains('sql') ||
        lower.contains('docker') ||
        lower.contains('aws')) {
      return 'Backend & Cloud';
    } else if (lower.contains('clean') ||
        lower.contains('bloc') ||
        lower.contains('test') ||
        lower.contains('git') ||
        lower.contains('architect') ||
        lower.contains('devops') ||
        lower.contains('ci')) {
      return 'Architecture & DevOps';
    }
    return 'Core Technologies';
  }

  List<String> _buildRoleTitles(String? headline) {
    if (headline == null || headline.trim().isEmpty) {
      return const [];
    }

    final delimiters = RegExp(r'[|•,]');
    if (delimiters.hasMatch(headline)) {
      final parts = headline
          .split(delimiters)
          .map((p) => p.trim())
          .where((p) => p.isNotEmpty)
          .toList();
      if (parts.isNotEmpty) return parts;
    }

    return [headline.trim()];
  }

  List<StatItem> _buildStats({
    required List<ProjectModel> projects,
    required List<ExperienceModel> experiences,
    required List<CertificateModel> certificates,
  }) {
    final stats = <StatItem>[];
    if (projects.isNotEmpty) {
      stats.add(StatItem(
        count: projects.length,
        suffix: '+',
        label: 'Projects',
      ));
    }
    if (experiences.isNotEmpty) {
      DateTime? earliestStart;
      DateTime latestEnd = DateTime.now();

      for (final exp in experiences) {
        if (exp.startDate != null) {
          if (earliestStart == null || exp.startDate!.isBefore(earliestStart)) {
            earliestStart = exp.startDate;
          }
        }
        if (exp.endDate != null && exp.endDate!.isAfter(latestEnd)) {
          latestEnd = exp.endDate!;
        }
      }

      if (earliestStart != null) {
        final days = latestEnd.difference(earliestStart).inDays;
        final experienceYears = (days / 365).round().clamp(1, 40);
        if (experienceYears > 0) {
          stats.add(StatItem(
            count: experienceYears,
            suffix: '+',
            label: 'Years Exp.',
          ));
        }
      }
    }
    if (certificates.isNotEmpty) {
      stats.add(StatItem(
        count: certificates.length,
        suffix: '+',
        label: 'Certificates',
      ));
    }
    return stats;
  }
}
