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

/// Represents an active, non-empty social platform link item for display and interaction.
class SocialPlatformItem {
  final String key;
  final String title;
  final String value;
  final String url;

  const SocialPlatformItem({
    required this.key,
    required this.title,
    required this.value,
    required this.url,
  });
}

/// Extensible social and professional links object supporting multiple platforms.
class SocialLinksModel {
  final String? github;
  final String? linkedin;
  final String? website;
  final String? instagram;
  final String? twitter;
  final String? facebook;
  final String? behance;
  final String? dribbble;
  final String? medium;
  final String? youtube;
  final String? tiktok;
  final String? discord;
  final String? telegram;
  final String? portfolio;
  final Map<String, String> customLinks;

  const SocialLinksModel({
    this.github,
    this.linkedin,
    this.website,
    this.instagram,
    this.twitter,
    this.facebook,
    this.behance,
    this.dribbble,
    this.medium,
    this.youtube,
    this.tiktok,
    this.discord,
    this.telegram,
    this.portfolio,
    this.customLinks = const {},
  });

  bool get isEmpty =>
      (github == null || github!.trim().isEmpty) &&
      (linkedin == null || linkedin!.trim().isEmpty) &&
      (website == null || website!.trim().isEmpty) &&
      (instagram == null || instagram!.trim().isEmpty) &&
      (twitter == null || twitter!.trim().isEmpty) &&
      (facebook == null || facebook!.trim().isEmpty) &&
      (behance == null || behance!.trim().isEmpty) &&
      (dribbble == null || dribbble!.trim().isEmpty) &&
      (medium == null || medium!.trim().isEmpty) &&
      (youtube == null || youtube!.trim().isEmpty) &&
      (tiktok == null || tiktok!.trim().isEmpty) &&
      (discord == null || discord!.trim().isEmpty) &&
      (telegram == null || telegram!.trim().isEmpty) &&
      (portfolio == null || portfolio!.trim().isEmpty) &&
      customLinks.isEmpty;

  bool get isNotEmpty => !isEmpty;

  /// Returns list of all non-empty social platforms ready for UI display.
  List<SocialPlatformItem> get activeLinks {
    final list = <SocialPlatformItem>[];

    void addIfValid(String key, String title, String? val) {
      if (val != null && val.trim().isNotEmpty) {
        final clean = val.trim();
        list.add(SocialPlatformItem(
          key: key,
          title: title,
          value: clean,
          url: formatUrl(key, clean),
        ));
      }
    }

    addIfValid('website', 'Website', website);
    addIfValid('github', 'GitHub', github);
    addIfValid('linkedin', 'LinkedIn', linkedin);
    addIfValid('instagram', 'Instagram', instagram);
    addIfValid('twitter', 'X (Twitter)', twitter);
    addIfValid('facebook', 'Facebook', facebook);
    addIfValid('behance', 'Behance', behance);
    addIfValid('dribbble', 'Dribbble', dribbble);
    addIfValid('medium', 'Medium', medium);
    addIfValid('youtube', 'YouTube', youtube);
    addIfValid('tiktok', 'TikTok', tiktok);
    addIfValid('discord', 'Discord', discord);
    addIfValid('telegram', 'Telegram', telegram);
    addIfValid('portfolio', 'Portfolio', portfolio);

    customLinks.forEach((key, val) {
      if (val.trim().isNotEmpty) {
        final clean = val.trim();
        list.add(SocialPlatformItem(
          key: key.toLowerCase(),
          title: key,
          value: clean,
          url: formatUrl(key, clean),
        ));
      }
    });

    return list;
  }

  /// Builds a proper, fully-qualified web URL for any platform or custom link.
  static String formatUrl(String platform, String input) {
    final raw = input.trim();
    if (raw.isEmpty) return '';
    if (raw.startsWith('http://') || raw.startsWith('https://')) {
      return raw;
    }
    final cleanHandle = raw.replaceAll('@', '');
    switch (platform.toLowerCase()) {
      case 'github':
        return 'https://github.com/$cleanHandle';
      case 'linkedin':
        return raw.contains('linkedin.com')
            ? 'https://$raw'
            : 'https://www.linkedin.com/in/$cleanHandle';
      case 'instagram':
        return 'https://instagram.com/$cleanHandle';
      case 'twitter':
      case 'x':
        return 'https://x.com/$cleanHandle';
      case 'facebook':
        return raw.contains('facebook.com')
            ? 'https://$raw'
            : 'https://facebook.com/$cleanHandle';
      case 'behance':
        return 'https://behance.net/$cleanHandle';
      case 'dribbble':
        return 'https://dribbble.com/$cleanHandle';
      case 'medium':
        return 'https://medium.com/@$cleanHandle';
      case 'youtube':
        return raw.contains('youtube.com') || raw.contains('youtu.be')
            ? 'https://$raw'
            : 'https://youtube.com/@$cleanHandle';
      case 'tiktok':
        return 'https://tiktok.com/@$cleanHandle';
      case 'telegram':
        return 'https://t.me/$cleanHandle';
      case 'discord':
        return raw.contains('discord.gg') || raw.contains('discord.com')
            ? 'https://$raw'
            : 'https://discord.gg/$cleanHandle';
      default:
        return 'https://$raw';
    }
  }

  factory SocialLinksModel.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const SocialLinksModel();
    final custom = <String, String>{};
    const standardKeys = {
      'github',
      'linkedin',
      'website',
      'instagram',
      'twitter',
      'x',
      'facebook',
      'behance',
      'dribbble',
      'medium',
      'youtube',
      'tiktok',
      'discord',
      'telegram',
      'portfolio',
    };

    map.forEach((key, value) {
      if (!standardKeys.contains(key.toLowerCase()) &&
          value is String &&
          value.trim().isNotEmpty) {
        custom[key] = value.trim();
      }
    });

    return SocialLinksModel(
      github: map['github'] as String?,
      linkedin: map['linkedin'] as String?,
      website: map['website'] as String?,
      instagram: map['instagram'] as String?,
      twitter: (map['twitter'] ?? map['x']) as String?,
      facebook: map['facebook'] as String?,
      behance: map['behance'] as String?,
      dribbble: map['dribbble'] as String?,
      medium: map['medium'] as String?,
      youtube: map['youtube'] as String?,
      tiktok: map['tiktok'] as String?,
      discord: map['discord'] as String?,
      telegram: map['telegram'] as String?,
      portfolio: map['portfolio'] as String?,
      customLinks: custom,
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};
    void putIfNonEmpty(String key, String? val) {
      if (val != null && val.trim().isNotEmpty) {
        map[key] = val.trim();
      }
    }

    putIfNonEmpty('github', github);
    putIfNonEmpty('linkedin', linkedin);
    putIfNonEmpty('website', website);
    putIfNonEmpty('instagram', instagram);
    putIfNonEmpty('twitter', twitter);
    putIfNonEmpty('facebook', facebook);
    putIfNonEmpty('behance', behance);
    putIfNonEmpty('dribbble', dribbble);
    putIfNonEmpty('medium', medium);
    putIfNonEmpty('youtube', youtube);
    putIfNonEmpty('tiktok', tiktok);
    putIfNonEmpty('discord', discord);
    putIfNonEmpty('telegram', telegram);
    putIfNonEmpty('portfolio', portfolio);

    customLinks.forEach((k, v) {
      if (v.trim().isNotEmpty) {
        map[k] = v.trim();
      }
    });
    return map;
  }

  SocialLinksModel copyWith({
    String? github,
    String? linkedin,
    String? website,
    String? instagram,
    String? twitter,
    String? facebook,
    String? behance,
    String? dribbble,
    String? medium,
    String? youtube,
    String? tiktok,
    String? discord,
    String? telegram,
    String? portfolio,
    Map<String, String>? customLinks,
  }) {
    return SocialLinksModel(
      github: github ?? this.github,
      linkedin: linkedin ?? this.linkedin,
      website: website ?? this.website,
      instagram: instagram ?? this.instagram,
      twitter: twitter ?? this.twitter,
      facebook: facebook ?? this.facebook,
      behance: behance ?? this.behance,
      dribbble: dribbble ?? this.dribbble,
      medium: medium ?? this.medium,
      youtube: youtube ?? this.youtube,
      tiktok: tiktok ?? this.tiktok,
      discord: discord ?? this.discord,
      telegram: telegram ?? this.telegram,
      portfolio: portfolio ?? this.portfolio,
      customLinks: customLinks ?? this.customLinks,
    );
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

  final String? cvLink;
  final String? resumeUrl;
  final String? publicPortfolioUrl;
  final bool websiteGenerated;
  final String? websiteUrl;
  final DateTime? websiteGeneratedAt;

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
    this.cvLink,
    this.resumeUrl,
    this.publicPortfolioUrl,
    this.websiteGenerated = false,
    this.websiteUrl,
    this.websiteGeneratedAt,
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
      cvLink: data['cvLink'] as String? ?? data['resumeUrl'] as String? ?? data['cvUrl'] as String?,
      resumeUrl: data['cvLink'] as String? ?? data['resumeUrl'] as String? ?? data['cvUrl'] as String?,
      publicPortfolioUrl: data['publicPortfolioUrl'] as String?,
      websiteGenerated: (data['websiteGenerated'] as bool?) ?? false,
      websiteUrl: data['websiteUrl'] as String? ?? data['publicPortfolioUrl'] as String?,
      websiteGeneratedAt: (data['generatedAt'] as Timestamp?)?.toDate() ??
          (data['publicPortfolioUpdatedAt'] as Timestamp?)?.toDate(),
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
      if (cvLink != null) 'cvLink': cvLink,
      if (resumeUrl != null || cvLink != null) 'resumeUrl': cvLink ?? resumeUrl,
      if (publicPortfolioUrl != null) 'publicPortfolioUrl': publicPortfolioUrl,
      'websiteGenerated': websiteGenerated,
      if (websiteUrl != null) 'websiteUrl': websiteUrl,
      if (websiteGeneratedAt != null)
        'generatedAt': Timestamp.fromDate(websiteGeneratedAt!),
      'followersCount': followersCount,
      'followingCount': followingCount,
    };
  }

  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? username,
    String? bio,
    String? profileImage,
    AccountType? accountType,
    String? headline,
    String? about,
    String? location,
    String? phone,
    SocialLinksModel? socialLinks,
    String? githubUsername,
    String? profileSlug,
    List<String>? skills,
    PortfolioSource? portfolioSource,
    bool? portfolioCompleted,
    int? portfolioVersion,
    SectionVisibilityModel? sectionVisibility,
    String? cvLink,
    String? resumeUrl,
    String? publicPortfolioUrl,
    bool? websiteGenerated,
    String? websiteUrl,
    DateTime? websiteGeneratedAt,
    int? followersCount,
    int? followingCount,
    DateTime? createdAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      username: username ?? this.username,
      bio: bio ?? this.bio,
      profileImage: profileImage ?? this.profileImage,
      accountType: accountType ?? this.accountType,
      headline: headline ?? this.headline,
      about: about ?? this.about,
      location: location ?? this.location,
      phone: phone ?? this.phone,
      socialLinks: socialLinks ?? this.socialLinks,
      githubUsername: githubUsername ?? this.githubUsername,
      profileSlug: profileSlug ?? this.profileSlug,
      skills: skills ?? this.skills,
      portfolioSource: portfolioSource ?? this.portfolioSource,
      portfolioCompleted: portfolioCompleted ?? this.portfolioCompleted,
      portfolioVersion: portfolioVersion ?? this.portfolioVersion,
      sectionVisibility: sectionVisibility ?? this.sectionVisibility,
      cvLink: cvLink ?? this.cvLink,
      resumeUrl: resumeUrl ?? (cvLink ?? this.resumeUrl),
      publicPortfolioUrl: publicPortfolioUrl ?? this.publicPortfolioUrl,
      websiteGenerated: websiteGenerated ?? this.websiteGenerated,
      websiteUrl: websiteUrl ?? this.websiteUrl,
      websiteGeneratedAt: websiteGeneratedAt ?? this.websiteGeneratedAt,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      createdAt: createdAt ?? this.createdAt,
    );
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
