import '../../features/profile/data/models/user_model.dart';
import '../../features/portfolio/data/models/project_model.dart';
import '../../features/portfolio/data/models/experience_model.dart';
import '../../features/portfolio/data/models/education_model.dart';
import '../../features/portfolio/data/models/certificate_model.dart';

/// Skill with proficiency level for the animated skill bars
class SkillItem {
  final String name;
  final double level; // 0.0 to 1.0
  final String category;

  const SkillItem({
    required this.name,
    required this.level,
    required this.category,
  });
}

/// Stat metric displayed in the hero section
class StatItem {
  final int count;
  final String suffix;
  final String label;

  const StatItem({
    required this.count,
    required this.suffix,
    required this.label,
  });
}

/// Comprehensive immutable view data for the Web Portfolio.
class PortfolioViewData {
  final UserModel user;
  final List<ProjectModel> projects;
  final List<ExperienceModel> experiences;
  final List<EducationModel> educations;
  final List<CertificateModel> certificates;
  final List<SkillItem> skills;
  final List<StatItem> stats;
  final List<String> roleTitles;
  final String? resumeUrl;

  const PortfolioViewData({
    required this.user,
    required this.projects,
    required this.experiences,
    required this.educations,
    required this.certificates,
    required this.skills,
    required this.stats,
    required this.roleTitles,
    this.resumeUrl,
  });
}
