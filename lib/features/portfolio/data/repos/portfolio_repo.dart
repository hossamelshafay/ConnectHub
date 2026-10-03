import 'package:connecthub/features/profile/data/models/user_model.dart';
import 'package:connecthub/features/portfolio/data/models/project_model.dart';
import 'package:connecthub/features/portfolio/data/models/experience_model.dart';
import 'package:connecthub/features/portfolio/data/models/education_model.dart';
import 'package:connecthub/features/portfolio/data/models/certificate_model.dart';

abstract class PortfolioRepo {
  /// Realtime stream of the portfolio user document.
  Stream<UserModel?> getPortfolioStream(String uid);

  /// Fetch user portfolio profile once by [uid].
  Future<UserModel?> getPortfolio(String uid);

  /// Updates portfolio profile attributes on `users/{uid}`.
  Future<void> updatePortfolio({
    required String uid,
    String? headline,
    String? about,
    String? location,
    String? phone,
    SocialLinksModel? socialLinks,
    String? githubUsername,
    String? profileSlug,
    PortfolioSource? portfolioSource,
    bool? portfolioCompleted,
    int? portfolioVersion,
    SectionVisibilityModel? sectionVisibility,
  });

  // ── Subcollection Streams (users/{uid}/...) ──────────────────────────────
  Stream<List<ProjectModel>> getProjectsStream(String uid);
  Stream<List<ExperienceModel>> getExperienceStream(String uid);
  Stream<List<EducationModel>> getEducationStream(String uid);
  Stream<List<CertificateModel>> getCertificatesStream(String uid);
}
