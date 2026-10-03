/// ConnectHub — CV Portfolio Model
///
/// Mirrors the backend CVPortfolio schema exactly.
/// Immutable, copyWith-able, zero external dependencies.
library;

class CvPortfolioModel {
  final String name;
  final String title;
  final String headline;
  final String summary;
  final String location;
  final String email;
  final String phone;
  final String website;
  final String github;
  final String linkedin;
  final List<String> skills;
  final List<CvProjectModel> projects;
  final List<CvExperienceModel> experience;
  final List<CvEducationModel> education;
  final List<CvCertificateModel> certificates;

  const CvPortfolioModel({
    this.name = '',
    this.title = '',
    this.headline = '',
    this.summary = '',
    this.location = '',
    this.email = '',
    this.phone = '',
    this.website = '',
    this.github = '',
    this.linkedin = '',
    this.skills = const [],
    this.projects = const [],
    this.experience = const [],
    this.education = const [],
    this.certificates = const [],
  });

  factory CvPortfolioModel.fromJson(Map<String, dynamic> json) {
    return CvPortfolioModel(
      name: json['name'] as String? ?? '',
      title: json['title'] as String? ?? '',
      headline: json['headline'] as String? ?? '',
      summary: json['summary'] as String? ?? '',
      location: json['location'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      website: json['website'] as String? ?? '',
      github: json['github'] as String? ?? '',
      linkedin: json['linkedin'] as String? ?? '',
      skills: List<String>.from(json['skills'] as List? ?? []),
      projects: ((json['projects'] as List?) ?? [])
          .map((e) => CvProjectModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      experience: ((json['experience'] as List?) ?? [])
          .map((e) => CvExperienceModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      education: ((json['education'] as List?) ?? [])
          .map((e) => CvEducationModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      certificates: ((json['certificates'] as List?) ?? [])
          .map((e) => CvCertificateModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  CvPortfolioModel copyWith({
    String? name,
    String? title,
    String? headline,
    String? summary,
    String? location,
    String? email,
    String? phone,
    String? website,
    String? github,
    String? linkedin,
    List<String>? skills,
    List<CvProjectModel>? projects,
    List<CvExperienceModel>? experience,
    List<CvEducationModel>? education,
    List<CvCertificateModel>? certificates,
  }) {
    return CvPortfolioModel(
      name: name ?? this.name,
      title: title ?? this.title,
      headline: headline ?? this.headline,
      summary: summary ?? this.summary,
      location: location ?? this.location,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      website: website ?? this.website,
      github: github ?? this.github,
      linkedin: linkedin ?? this.linkedin,
      skills: skills ?? this.skills,
      projects: projects ?? this.projects,
      experience: experience ?? this.experience,
      education: education ?? this.education,
      certificates: certificates ?? this.certificates,
    );
  }
}

// ─── Sub-models ──────────────────────────────────────────────────────────────

class CvProjectModel {
  final String title;
  final String description;
  final List<String> techStack;
  final String github;
  final String liveDemo;

  const CvProjectModel({
    this.title = '',
    this.description = '',
    this.techStack = const [],
    this.github = '',
    this.liveDemo = '',
  });

  factory CvProjectModel.fromJson(Map<String, dynamic> json) {
    return CvProjectModel(
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      techStack: List<String>.from(json['techStack'] as List? ?? []),
      github: json['github'] as String? ?? '',
      liveDemo: json['liveDemo'] as String? ?? '',
    );
  }

  CvProjectModel copyWith({
    String? title,
    String? description,
    List<String>? techStack,
    String? github,
    String? liveDemo,
  }) {
    return CvProjectModel(
      title: title ?? this.title,
      description: description ?? this.description,
      techStack: techStack ?? this.techStack,
      github: github ?? this.github,
      liveDemo: liveDemo ?? this.liveDemo,
    );
  }
}

class CvExperienceModel {
  final String company;
  final String position;
  final String startDate;
  final String endDate;
  final String description;

  const CvExperienceModel({
    this.company = '',
    this.position = '',
    this.startDate = '',
    this.endDate = '',
    this.description = '',
  });

  factory CvExperienceModel.fromJson(Map<String, dynamic> json) {
    return CvExperienceModel(
      company: json['company'] as String? ?? '',
      position: json['position'] as String? ?? '',
      startDate: json['startDate'] as String? ?? '',
      endDate: json['endDate'] as String? ?? '',
      description: json['description'] as String? ?? '',
    );
  }

  CvExperienceModel copyWith({
    String? company,
    String? position,
    String? startDate,
    String? endDate,
    String? description,
  }) {
    return CvExperienceModel(
      company: company ?? this.company,
      position: position ?? this.position,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      description: description ?? this.description,
    );
  }
}

class CvEducationModel {
  final String institution;
  final String degree;
  final String field;
  final String startDate;
  final String endDate;

  const CvEducationModel({
    this.institution = '',
    this.degree = '',
    this.field = '',
    this.startDate = '',
    this.endDate = '',
  });

  factory CvEducationModel.fromJson(Map<String, dynamic> json) {
    return CvEducationModel(
      institution: json['institution'] as String? ?? '',
      degree: json['degree'] as String? ?? '',
      field: json['field'] as String? ?? '',
      startDate: json['startDate'] as String? ?? '',
      endDate: json['endDate'] as String? ?? '',
    );
  }

  CvEducationModel copyWith({
    String? institution,
    String? degree,
    String? field,
    String? startDate,
    String? endDate,
  }) {
    return CvEducationModel(
      institution: institution ?? this.institution,
      degree: degree ?? this.degree,
      field: field ?? this.field,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }
}

class CvCertificateModel {
  final String title;
  final String issuer;
  final String date;
  final String url;

  const CvCertificateModel({
    this.title = '',
    this.issuer = '',
    this.date = '',
    this.url = '',
  });

  factory CvCertificateModel.fromJson(Map<String, dynamic> json) {
    return CvCertificateModel(
      title: json['title'] as String? ?? '',
      issuer: json['issuer'] as String? ?? '',
      date: json['date'] as String? ?? '',
      url: json['url'] as String? ?? '',
    );
  }

  CvCertificateModel copyWith({
    String? title,
    String? issuer,
    String? date,
    String? url,
  }) {
    return CvCertificateModel(
      title: title ?? this.title,
      issuer: issuer ?? this.issuer,
      date: date ?? this.date,
      url: url ?? this.url,
    );
  }
}
