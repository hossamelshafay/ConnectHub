import 'package:cloud_firestore/cloud_firestore.dart';

/// Supported account types in ConnectHub.
enum AccountType {
  personal,
  professional;

  static AccountType fromString(String? value) {
    if (value == 'professional') {
      return AccountType.professional;
    }
    return AccountType.personal;
  }

  String get value => name;
}

/// How the portfolio was created/populated.
enum PortfolioSource {
  manual,
  cvAi,
  mixed;

  static PortfolioSource fromString(String? value) {
    switch (value) {
      case 'cv_ai':
        return PortfolioSource.cvAi;
      case 'mixed':
        return PortfolioSource.mixed;
      default:
        return PortfolioSource.manual;
    }
  }

  String get value {
    switch (this) {
      case PortfolioSource.cvAi:
        return 'cv_ai';
      case PortfolioSource.mixed:
        return 'mixed';
      case PortfolioSource.manual:
        return 'manual';
    }
  }
}

/// Extensible social and professional links object.
class SocialLinksModel {
  final String? github;
  final String? linkedin;
  final String? website;
  final String? portfolio;
  final Map<String, String> customLinks;

  const SocialLinksModel({
    this.github,
    this.linkedin,
    this.website,
    this.portfolio,
    this.customLinks = const {},
  });

  bool get isEmpty =>
      (github == null || github!.trim().isEmpty) &&
      (linkedin == null || linkedin!.trim().isEmpty) &&
      (website == null || website!.trim().isEmpty) &&
      (portfolio == null || portfolio!.trim().isEmpty) &&
      customLinks.isEmpty;

  bool get isNotEmpty => !isEmpty;

  factory SocialLinksModel.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const SocialLinksModel();
    final custom = <String, String>{};
    map.forEach((key, value) {
      if (key != 'github' &&
          key != 'linkedin' &&
          key != 'website' &&
          key != 'portfolio' &&
          value is String &&
          value.isNotEmpty) {
        custom[key] = value;
      }
    });

    return SocialLinksModel(
      github: map['github'] as String?,
      linkedin: map['linkedin'] as String?,
      website: map['website'] as String?,
      portfolio: map['portfolio'] as String?,
      customLinks: custom,
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};
    if (github != null && github!.trim().isNotEmpty) {
      map['github'] = github!.trim();
    }
    if (linkedin != null && linkedin!.trim().isNotEmpty) {
      map['linkedin'] = linkedin!.trim();
    }
    if (website != null && website!.trim().isNotEmpty) {
      map['website'] = website!.trim();
    }
    if (portfolio != null && portfolio!.trim().isNotEmpty) {
      map['portfolio'] = portfolio!.trim();
    }
    customLinks.forEach((k, v) {
      if (v.trim().isNotEmpty) {
        map[k] = v.trim();
      }
    });
    return map;
  }
}

/// Section visibility preferences for a professional portfolio.
class SectionVisibilityModel {
  final bool about;
  final bool experience;
  final bool projects;
  final bool skills;
  final bool education;
  final bool certificates;
  final bool contact;

  const SectionVisibilityModel({
    this.about = true,
    this.experience = true,
    this.projects = true,
    this.skills = true,
    this.education = true,
    this.certificates = true,
    this.contact = true,
  });

  factory SectionVisibilityModel.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const SectionVisibilityModel();
    return SectionVisibilityModel(
      about: (map['about'] as bool?) ?? true,
      experience: (map['experience'] as bool?) ?? true,
      projects: (map['projects'] as bool?) ?? true,
      skills: (map['skills'] as bool?) ?? true,
      education: (map['education'] as bool?) ?? true,
      certificates: (map['certificates'] as bool?) ?? true,
      contact: (map['contact'] as bool?) ?? true,
    );
  }

  Map<String, dynamic> toMap() => {
        'about': about,
        'experience': experience,
        'projects': projects,
        'skills': skills,
        'education': education,
        'certificates': certificates,
        'contact': contact,
      };

  SectionVisibilityModel copyWith({
    bool? about,
    bool? experience,
    bool? projects,
    bool? skills,
    bool? education,
    bool? certificates,
    bool? contact,
  }) {
    return SectionVisibilityModel(
      about: about ?? this.about,
      experience: experience ?? this.experience,
      projects: projects ?? this.projects,
      skills: skills ?? this.skills,
      education: education ?? this.education,
      certificates: certificates ?? this.certificates,
      contact: contact ?? this.contact,
    );
  }
}

/// Core User entity in ConnectHub.
class UserModel {
  final String uid;
  final String name;
  final String email;
  final String? username;
  final String? bio;
  final String? profileImage;
  final AccountType accountType;

  // ── Professional Fields ──────────────────────────────────────────────────
  final String? headline;
  final String? about;
  final String? location;
  final String? phone;
  final SocialLinksModel socialLinks;
  final String? githubUsername;
  final String? profileSlug;
  final List<String> skills;
  final PortfolioSource portfolioSource;
  final bool portfolioCompleted;
  final int portfolioVersion;
  final SectionVisibilityModel sectionVisibility;

  // ── Social Metrics ───────────────────────────────────────────────────────
  final int followersCount;
  final int followingCount;
  final DateTime? createdAt;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.username,
    this.bio,
    this.profileImage,
    this.accountType = AccountType.personal,
    this.headline,
    this.about,
    this.location,
    this.phone,
    this.socialLinks = const SocialLinksModel(),
    this.githubUsername,
    this.profileSlug,
    this.skills = const [],
    this.portfolioSource = PortfolioSource.manual,
    this.portfolioCompleted = false,
    this.portfolioVersion = 1,
    this.sectionVisibility = const SectionVisibilityModel(),
    this.followersCount = 0,
    this.followingCount = 0,
    this.createdAt,
  });

  bool get isProfessional => accountType == AccountType.professional;

  factory UserModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return UserModel.fromMap(data, id: doc.id);
  }

  factory UserModel.fromMap(Map<String, dynamic> data, {String? id}) {
    final rawLinks = data['socialLinks'] as Map<String, dynamic>?;
    final socialLinks = rawLinks != null
        ? SocialLinksModel.fromMap(rawLinks)
        : SocialLinksModel(
            github: data['github'] as String?,
            linkedin: data['linkedin'] as String?,
            website: data['website'] as String?,
            portfolio: data['portfolioWebsite'] as String?,
          );

    final rawVis = data['sectionVisibility'] as Map<String, dynamic>?;

    return UserModel(
      uid: id ?? (data['uid'] as String? ?? ''),
      name: data['name'] as String? ?? 'User',
      email: data['email'] as String? ?? '',
      username: data['username'] as String?,
      bio: data['bio'] as String?,
      profileImage: data['profileImage'] as String?,
      accountType: AccountType.fromString(data['accountType'] as String?),
      headline: data['headline'] as String?,
      about: data['about'] as String?,
      location: data['location'] as String?,
      phone: data['phone'] as String?,
      socialLinks: socialLinks,
      githubUsername: data['githubUsername'] as String? ??
          _extractGithubUsername(socialLinks.github),
      profileSlug: data['profileSlug'] as String?,
      skills: (data['skills'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      portfolioSource:
          PortfolioSource.fromString(data['portfolioSource'] as String?),
      portfolioCompleted: (data['portfolioCompleted'] as bool?) ?? false,
      portfolioVersion: (data['portfolioVersion'] as int?) ?? 1,
      sectionVisibility: SectionVisibilityModel.fromMap(rawVis),
      followersCount: (data['followersCount'] as int?) ?? 0,
      followingCount: (data['followingCount'] as int?) ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      if (username != null) 'username': username,
      if (bio != null) 'bio': bio,
      if (profileImage != null) 'profileImage': profileImage,
      'accountType': accountType.value,
      if (headline != null) 'headline': headline,
      if (about != null) 'about': about,
      if (location != null) 'location': location,
      if (phone != null) 'phone': phone,
      'socialLinks': socialLinks.toMap(),
      if (githubUsername != null) 'githubUsername': githubUsername,
      if (profileSlug != null) 'profileSlug': profileSlug,
      'skills': skills,
      'portfolioSource': portfolioSource.value,
      'portfolioCompleted': portfolioCompleted,
      'portfolioVersion': portfolioVersion,
      'sectionVisibility': sectionVisibility.toMap(),
      'followersCount': followersCount,
      'followingCount': followingCount,
    };
  }

  static String? _extractGithubUsername(String? url) {
    if (url == null || url.trim().isEmpty) return null;
    final cleaned = url.trim().replaceAll(RegExp(r'^https?:\/\/(www\.)?github\.com\/'), '');
    final parts = cleaned.split('/');
    if (parts.isNotEmpty && parts.first.isNotEmpty) {
      return parts.first.replaceAll('@', '');
    }
    return null;
  }
}
