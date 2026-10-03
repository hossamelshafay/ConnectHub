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

  PortfolioLoaded({
    required this.user,
    this.projects = const [],
    this.experience = const [],
    this.education = const [],
    this.certificates = const [],
  });

  PortfolioLoaded copyWith({
    UserModel? user,
    List<ProjectModel>? projects,
    List<ExperienceModel>? experience,
    List<EducationModel>? education,
    List<CertificateModel>? certificates,
  }) {
    return PortfolioLoaded(
      user: user ?? this.user,
      projects: projects ?? this.projects,
      experience: experience ?? this.experience,
      education: education ?? this.education,
      certificates: certificates ?? this.certificates,
    );
  }
}

class PortfolioUpdating extends PortfolioState {}

class PortfolioUpdateSuccess extends PortfolioState {}

class PortfolioError extends PortfolioState {
  final String message;
  PortfolioError(this.message);
}
