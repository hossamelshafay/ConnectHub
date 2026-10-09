import 'package:cloud_firestore/cloud_firestore.dart';
import '../../features/profile/data/models/user_model.dart';
import '../../features/portfolio/data/models/project_model.dart';
import '../../features/portfolio/data/models/experience_model.dart';
import '../../features/portfolio/data/models/education_model.dart';
import '../../features/portfolio/data/models/certificate_model.dart';
import '../models/portfolio_view_data.dart';
import 'portfolio_mock_service.dart';

/// Service responsible for fetching dynamic portfolio data from Firebase/Firestore,
/// with seamless fallback to curated mock data when data is unavailable.
class PortfolioWebService {
  final FirebaseFirestore _firestore;

  PortfolioWebService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Loads a full portfolio for a given username slug.
  /// Fetches user document + all sub-collections from Firestore.
  Future<PortfolioViewData> loadPortfolioData({String? username}) async {
    final fallback = PortfolioMockService.getMockPortfolio();

    try {
      final targetUsername = (username != null && username.isNotEmpty)
          ? username.toLowerCase().trim()
          : null;

      // ── 1. Resolve user document ────────────────────────────────────────
      DocumentSnapshot? userDoc;

      if (targetUsername != null) {
        // Query by profileSlug first, then fall back to username field
        final slugQuery = await _firestore
            .collection('users')
            .where('profileSlug', isEqualTo: targetUsername)
            .limit(1)
            .get();

        if (slugQuery.docs.isNotEmpty) {
          userDoc = slugQuery.docs.first;
        } else {
          final usernameQuery = await _firestore
              .collection('users')
              .where('username', isEqualTo: targetUsername)
              .limit(1)
              .get();

          if (usernameQuery.docs.isNotEmpty) {
            userDoc = usernameQuery.docs.first;
          }
        }
      }

      if (userDoc == null || !userDoc.exists) return fallback;

      final firestoreUser = UserModel.fromDoc(userDoc);
      final uid = firestoreUser.uid;

      // ── 2. Fetch all sub-collections in parallel ─────────────────────────
      final results = await Future.wait([
        _firestore.collection('users').doc(uid).collection('projects').get(),
        _firestore.collection('users').doc(uid).collection('experience').get(),
        _firestore.collection('users').doc(uid).collection('education').get(),
        _firestore.collection('users').doc(uid).collection('certificates').get(),
      ]);

      final projectDocs     = results[0].docs;
      final experienceDocs  = results[1].docs;
      final educationDocs   = results[2].docs;
      final certificateDocs = results[3].docs;

      final projects = projectDocs
          .map(ProjectModel.fromDoc)
          .toList();

      final experiences = experienceDocs
          .map(ExperienceModel.fromDoc)
          .toList();

      final educations = educationDocs
          .map(EducationModel.fromDoc)
          .toList();

      final certificates = certificateDocs
          .map(CertificateModel.fromDoc)
          .toList();

      // ── 3. Build skill items from user.skills list ───────────────────────
      final skillItems = _buildSkillItems(firestoreUser.skills, fallback.skills);

      // ── 4. Compute stats from real data ──────────────────────────────────
      final stats = _buildStats(
        projectCount: projects.isEmpty ? fallback.stats[0].count : projects.length,
        experienceYears: fallback.stats[1].count, // keep experience years from mock
        certificateCount: certificates.isEmpty ? fallback.stats[2].count : certificates.length,
      );

      // ── 5. Profile image — fall back to mock avatar if missing ───────────
      final user = (firestoreUser.profileImage != null &&
              firestoreUser.profileImage!.isNotEmpty)
          ? firestoreUser
          : firestoreUser.copyWith(profileImage: fallback.user.profileImage);

      return PortfolioViewData(
        user: user,
        projects: projects.isEmpty ? fallback.projects : projects,
        experiences: experiences.isEmpty ? fallback.experiences : experiences,
        educations: educations.isEmpty ? fallback.educations : educations,
        certificates: certificates.isEmpty ? fallback.certificates : certificates,
        skills: skillItems,
        stats: stats,
        roleTitles: fallback.roleTitles,
      );
    } catch (e) {
      // Network / permission / offline — silently return curated mock portfolio
      return fallback;
    }
  }

  List<SkillItem> _buildSkillItems(
    List<String> userSkills,
    List<SkillItem> fallbackSkills,
  ) {
    if (userSkills.isEmpty) return fallbackSkills;
    // Assign plausible proficiency levels based on position (first = most known)
    return List.generate(userSkills.length, (i) {
      final level = ((userSkills.length - i) / userSkills.length)
          .clamp(0.45, 1.0)
          .toDouble();
      return SkillItem(
        name: userSkills[i],
        level: level,
        category: 'General',
      );
    });
  }

  List<StatItem> _buildStats({
    required int projectCount,
    required int experienceYears,
    required int certificateCount,
  }) {
    return [
      StatItem(count: projectCount, suffix: '+', label: 'Projects'),
      StatItem(count: experienceYears, suffix: '+', label: 'Years Exp.'),
      StatItem(count: certificateCount, suffix: '+', label: 'Certificates'),
      const StatItem(count: 100, suffix: '%', label: 'Passion'),
    ];
  }
}
