import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connecthub/features/profile/data/models/user_model.dart';
import 'package:connecthub/features/portfolio/data/models/project_model.dart';
import 'package:connecthub/features/portfolio/data/models/experience_model.dart';
import 'package:connecthub/features/portfolio/data/models/education_model.dart';
import 'package:connecthub/features/portfolio/data/models/certificate_model.dart';

/// Denormalized, self-contained snapshot document stored in `public_portfolios/{docId}`.
/// Designed for high-speed public web portfolio serving without subcollection reads.
class PublicPortfolioSnapshot {
  final String uid;
  final String? username;
  final String name;
  final String email;
  final String? headline;
  final String? bio;
  final String? about;
  final String? location;
  final String? phone;
  final String? profileImage;
  final List<String> skills;
  final SocialLinksModel socialLinks;
  final List<ProjectModel> projects;
  final List<ExperienceModel> experience;
  final List<EducationModel> education;
  final List<CertificateModel> certificates;
  final String? resumeUrl;
  final String publicPortfolioUrl;
  final bool isPublic;
  final String version;
  final String websiteVersion;
  final DateTime? generatedAt;
  final DateTime? updatedAt;

  String get displayName => name;

  const PublicPortfolioSnapshot({
    required this.uid,
    this.username,
    required this.name,
    this.email = '',
    this.headline,
    this.bio,
    this.about,
    this.location,
    this.phone,
    this.profileImage,
    this.skills = const [],
    this.socialLinks = const SocialLinksModel(),
    this.projects = const [],
    this.experience = const [],
    this.education = const [],
    this.certificates = const [],
    this.resumeUrl,
    required this.publicPortfolioUrl,
    this.isPublic = true,
    this.version = '1.0.0',
    this.websiteVersion = '1.0.0',
    this.generatedAt,
    this.updatedAt,
  });

  /// Creates a snapshot from raw Firestore document data.
  factory PublicPortfolioSnapshot.fromMap(Map<String, dynamic> data, {String? docId}) {
    DateTime? parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val);
      return null;
    }

    final rawProjects = data['projects'] as List<dynamic>? ?? [];
    final projects = rawProjects
        .whereType<Map<String, dynamic>>()
        .map((m) => ProjectModel.fromMap(m, id: m['id'] as String? ?? ''))
        .toList();

    final rawExperience = data['experience'] as List<dynamic>? ?? [];
    final experience = rawExperience
        .whereType<Map<String, dynamic>>()
        .map((m) => ExperienceModel.fromMap(m, id: m['id'] as String? ?? ''))
        .toList();

    final rawEducation = data['education'] as List<dynamic>? ?? [];
    final education = rawEducation
        .whereType<Map<String, dynamic>>()
        .map((m) => EducationModel.fromMap(m, id: m['id'] as String? ?? ''))
        .toList();

    final rawCertificates = data['certificates'] as List<dynamic>? ?? [];
    final certificates = rawCertificates
        .whereType<Map<String, dynamic>>()
        .map((m) => CertificateModel.fromMap(m, id: m['id'] as String? ?? ''))
        .toList();

    final rawSkills = (data['skills'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        const <String>[];

    final rawSocial = data['socialLinks'] as Map<String, dynamic>?;

    return PublicPortfolioSnapshot(
      uid: data['uid'] as String? ?? docId ?? '',
      username: data['username'] as String?,
      name: data['displayName'] as String? ?? data['name'] as String? ?? 'Portfolio User',
      email: data['email'] as String? ?? '',
      headline: data['headline'] as String?,
      bio: data['bio'] as String?,
      about: data['about'] as String?,
      location: data['location'] as String?,
      phone: data['phone'] as String?,
      profileImage: data['profileImage'] as String?,
      skills: rawSkills,
      socialLinks: SocialLinksModel.fromMap(rawSocial),
      projects: projects,
      experience: experience,
      education: education,
      certificates: certificates,
      resumeUrl: data['resumeUrl'] as String? ?? data['cvUrl'] as String?,
      publicPortfolioUrl: data['publicPortfolioUrl'] as String? ?? '',
      isPublic: (data['isPublic'] as bool?) ?? true,
      version: data['version'] as String? ?? '1.0.0',
      websiteVersion: data['websiteVersion'] as String? ?? '1.0.0',
      generatedAt: parseDate(data['generatedAt']),
      updatedAt: parseDate(data['updatedAt']),
    );
  }

  factory PublicPortfolioSnapshot.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return PublicPortfolioSnapshot.fromMap(data, docId: doc.id);
  }

  /// Converts snapshot to Firestore map for storage.
  Map<String, dynamic> toMap({bool isFirstGeneration = false}) {
    return {
      'uid': uid,
      if (username != null && username!.trim().isNotEmpty)
        'username': username!.trim().toLowerCase(),
      'displayName': name,
      'name': name,
      'email': email,
      if (headline != null) 'headline': headline,
      if (bio != null) 'bio': bio,
      if (about != null) 'about': about,
      if (location != null) 'location': location,
      if (phone != null) 'phone': phone,
      if (profileImage != null) 'profileImage': profileImage,
      if (resumeUrl != null && resumeUrl!.trim().isNotEmpty) 'resumeUrl': resumeUrl!.trim(),
      'skills': skills,
      'socialLinks': socialLinks.toMap(),
      'projects': projects.map((p) => p.toMap(includeId: true)).toList(),
      'experience': experience.map((e) => e.toMap(includeId: true)).toList(),
      'education': education.map((e) => e.toMap(includeId: true)).toList(),
      'certificates': certificates.map((c) => c.toMap(includeId: true)).toList(),
      'publicPortfolioUrl': publicPortfolioUrl,
      'isPublic': isPublic,
      'version': version,
      'websiteVersion': websiteVersion,
      'updatedAt': FieldValue.serverTimestamp(),
      if (isFirstGeneration) 'generatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Converts this snapshot into a [UserModel] for rendering with web/mobile widgets.
  UserModel toUserModel() {
    return UserModel(
      uid: uid,
      name: name,
      email: email,
      username: username,
      headline: headline,
      bio: bio,
      about: about,
      location: location,
      phone: phone,
      profileImage: profileImage,
      skills: skills,
      socialLinks: socialLinks,
      profileSlug: username,
      portfolioCompleted: true,
      resumeUrl: resumeUrl,
      publicPortfolioUrl: publicPortfolioUrl,
      createdAt: generatedAt,
    );
  }
}
