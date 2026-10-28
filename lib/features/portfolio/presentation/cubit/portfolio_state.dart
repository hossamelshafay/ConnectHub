import 'package:connecthub/features/profile/data/models/user_model.dart';
import 'package:connecthub/features/portfolio/data/models/project_model.dart';
import 'package:connecthub/features/portfolio/data/models/experience_model.dart';
import 'package:connecthub/features/portfolio/data/models/education_model.dart';
import 'package:connecthub/features/portfolio/data/models/certificate_model.dart';

abstract class PortfolioState {}

class PortfolioInitial extends PortfolioState {}

class PortfolioLoading extends PortfolioState {}

class PortfolioLoaded extends PortfolioState {
  final UserModel user;
  final List<ProjectModel> projects;
  final List<ExperienceModel> experience;
  final List<EducationModel> education;
  final List<CertificateModel> certificates;
  final String experienceYears;

  PortfolioLoaded({
    required this.user,
    this.projects = const [],
    this.experience = const [],
    this.education = const [],
    this.certificates = const [],
    String? experienceYears,
  }) : experienceYears = experienceYears ?? calculateExperienceYears(experience);

  PortfolioLoaded copyWith({
    UserModel? user,
    List<ProjectModel>? projects,
    List<ExperienceModel>? experience,
    List<EducationModel>? education,
    List<CertificateModel>? certificates,
  }) {
    final updatedExp = experience ?? this.experience;
    return PortfolioLoaded(
      user: user ?? this.user,
      projects: projects ?? this.projects,
      experience: updatedExp,
      education: education ?? this.education,
      certificates: certificates ?? this.certificates,
      experienceYears: experience != null
          ? calculateExperienceYears(updatedExp)
          : experienceYears,
    );
  }

  static String calculateExperienceYears(List<ExperienceModel> exps) {
    if (exps.isEmpty) return '0';
    int totalMonths = 0;
    final now = DateTime.now();
    for (final e in exps) {
      if (e.startDate != null) {
        final end =
            (e.isCurrent || e.endDate == null) ? now : (e.endDate ?? now);
        final diff = end.difference(e.startDate!);
        if (diff.inDays > 0) {
          totalMonths += (diff.inDays / 30.44).round();
        }
      }
    }
    if (totalMonths <= 0) {
      return exps.length.toString();
    }
    final years = totalMonths / 12;
    if (years < 1) return '<1';
    return years >= 10
        ? '${years.round()}+'
        : years.toStringAsFixed(years % 1 == 0 ? 0 : 1);
  }
}

class PortfolioUpdating extends PortfolioState {}

class PortfolioUpdateSuccess extends PortfolioState {}

class PortfolioError extends PortfolioState {
  final String message;
  PortfolioError(this.message);
}
