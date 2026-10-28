import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connecthub/features/profile/data/models/user_model.dart';
import 'package:connecthub/features/portfolio/data/models/project_model.dart';
import 'package:connecthub/features/portfolio/data/models/experience_model.dart';
import 'package:connecthub/features/portfolio/data/models/education_model.dart';
import 'package:connecthub/features/portfolio/data/models/certificate_model.dart';
import 'package:connecthub/core/services/portfolio_sync_service.dart';
import 'package:connecthub/features/portfolio/data/repos/portfolio_repo.dart';

class PortfolioRepoImp implements PortfolioRepo {
  final FirebaseFirestore _firestore;

  PortfolioRepoImp({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference get _users => _firestore.collection('users');

  CollectionReference _projects(String uid) =>
      _users.doc(uid).collection('projects');

  CollectionReference _experience(String uid) =>
      _users.doc(uid).collection('experience');

  CollectionReference _education(String uid) =>
      _users.doc(uid).collection('education');

  CollectionReference _certificates(String uid) =>
      _users.doc(uid).collection('certificates');

  @override
  Stream<UserModel?> getPortfolioStream(String uid) {
    return _users.doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserModel.fromDoc(doc);
    });
  }

  @override
  Future<UserModel?> getPortfolio(String uid) async {
    final doc = await _users.doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromDoc(doc);
  }

  @override
  Future<void> updatePortfolio({
    required String uid,
    String? headline,
    String? about,
    String? location,
    String? phone,
    String? cvLink,
    SocialLinksModel? socialLinks,
    String? githubUsername,
    String? profileSlug,
    PortfolioSource? portfolioSource,
    bool? portfolioCompleted,
    int? portfolioVersion,
    SectionVisibilityModel? sectionVisibility,
  }) async {
    final data = <String, dynamic>{};

    if (headline != null) data['headline'] = headline.trim();
    if (about != null) data['about'] = about.trim();
    if (location != null) data['location'] = location.trim();
    if (phone != null) data['phone'] = phone.trim();
    if (cvLink != null) {
      final trimmed = cvLink.trim();
      data['cvLink'] = trimmed;
      data['resumeUrl'] = trimmed;
    }

    if (socialLinks != null) {
      data['socialLinks'] = socialLinks.toMap();
      if (githubUsername == null && socialLinks.github != null) {
        final extracted = _extractGithubUsername(socialLinks.github);
        if (extracted != null) data['githubUsername'] = extracted;
      }
    }

    if (githubUsername != null) {
      data['githubUsername'] = githubUsername.trim().replaceAll('@', '');
    }

    if (profileSlug != null && profileSlug.trim().isNotEmpty) {
      data['profileSlug'] = _normalizeSlug(profileSlug.trim());
    }

    if (portfolioSource != null) {
      data['portfolioSource'] = portfolioSource.value;
    }

    if (portfolioCompleted != null) {
      data['portfolioCompleted'] = portfolioCompleted;
    }

    if (portfolioVersion != null) {
      data['portfolioVersion'] = portfolioVersion;
    }

    if (sectionVisibility != null) {
      data['sectionVisibility'] = sectionVisibility.toMap();
    }

    if (data.isNotEmpty) {
      await _users.doc(uid).set(data, SetOptions(merge: true));
      PortfolioSyncService().syncUserPortfolio(uid).ignore();
    }
  }

  // ── Subcollection Streams (users/{uid}/...) ──────────────────────────────

  @override
  Stream<List<ProjectModel>> getProjectsStream(String uid) {
    return _projects(uid).snapshots().map((snap) =>
        snap.docs.map((doc) => ProjectModel.fromDoc(doc)).toList());
  }

  @override
  Stream<List<ExperienceModel>> getExperienceStream(String uid) {
    return _experience(uid).snapshots().map((snap) =>
        snap.docs.map((doc) => ExperienceModel.fromDoc(doc)).toList());
  }

  @override
  Stream<List<EducationModel>> getEducationStream(String uid) {
    return _education(uid).snapshots().map((snap) =>
        snap.docs.map((doc) => EducationModel.fromDoc(doc)).toList());
  }

  @override
  Stream<List<CertificateModel>> getCertificatesStream(String uid) {
    return _certificates(uid).snapshots().map((snap) =>
        snap.docs.map((doc) => CertificateModel.fromDoc(doc)).toList());
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  static String? _extractGithubUsername(String? url) {
    if (url == null || url.trim().isEmpty) return null;
    final cleaned =
        url.trim().replaceAll(RegExp(r'^https?:\/\/(www\.)?github\.com\/'), '');
    final parts = cleaned.split('/');
    if (parts.isNotEmpty && parts.first.isNotEmpty) {
      return parts.first.replaceAll('@', '');
    }
    return null;
  }

  static String _normalizeSlug(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9_-]'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
  }
}
