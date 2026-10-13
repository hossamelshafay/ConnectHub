import 'package:cloud_firestore/cloud_firestore.dart';
import '../../features/profile/data/models/user_model.dart';
import '../../features/portfolio/data/models/project_model.dart';
import '../../features/portfolio/data/models/experience_model.dart';
import '../../features/portfolio/data/models/education_model.dart';
import '../../features/portfolio/data/models/certificate_model.dart';
import '../models/portfolio_view_data.dart';

/// Service responsible for fetching dynamic portfolio data strictly from Cloud Firestore.
/// Never returns mock, demo, seeded, or fabricated fallback data.
class PortfolioWebService {
  final FirebaseFirestore _firestore;

  PortfolioWebService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Loads a full portfolio for a given username slug or UID.
  /// Fetches user document + all sub-collections strictly from Firestore.
  Future<PortfolioViewData> loadPortfolioData({String? username}) async {
    final targetUsername = (username != null && username.isNotEmpty)
        ? username.toLowerCase().trim()
        : null;

    if (targetUsername == null) {
      throw Exception('Username or identifier required.');
    }

    // ── 1. Resolve user document ────────────────────────────────────────
    DocumentSnapshot? userDoc;

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
      } else {
        final directDoc =
            await _firestore.collection('users').doc(targetUsername).get();
        if (directDoc.exists) {
          userDoc = directDoc;
        }
      }
    }

    if (userDoc == null || !userDoc.exists) {
      throw Exception('Portfolio not found for user: $username');
    }

    final firestoreUser = UserModel.fromDoc(userDoc);
    final uid = firestoreUser.uid;

    // ── 2. Fetch all sub-collections in parallel ─────────────────────────
    final results = await Future.wait([
      _firestore.collection('users').doc(uid).collection('projects').get(),
      _firestore.collection('users').doc(uid).collection('experience').get(),
      _firestore.collection('users').doc(uid).collection('education').get(),
      _firestore.collection('users').doc(uid).collection('certificates').get(),
    ]);

    final projects = results[0]
        .docs
        .map(ProjectModel.fromDoc)
        .where((p) => p.isVisible)
        .toList();

    final experiences = results[1]
        .docs
        .map(ExperienceModel.fromDoc)
        .where((e) => e.isVisible)
        .toList();

    final educations = results[2]
        .docs
        .map(EducationModel.fromDoc)
        .where((e) => e.isVisible)
        .toList();

    final certificates = results[3]
        .docs
        .map(CertificateModel.fromDoc)
        .where((c) => c.isVisible)
        .toList();

    // ── 3. Build skill items strictly from user.skills list ──────────────
    final skillItems = _buildSkillItems(firestoreUser.skills);

    // ── 4. Compute stats strictly from real data ─────────────────────────
    final stats = _buildStats(
      projectCount: projects.length,
      experienceCount: experiences.length,
      certificateCount: certificates.length,
    );

    final roleTitles = (firestoreUser.headline != null &&
            firestoreUser.headline!.trim().isNotEmpty)
        ? [firestoreUser.headline!.trim()]
        : const <String>[];

    return PortfolioViewData(
      user: firestoreUser,
      projects: projects,
      experiences: experiences,
      educations: educations,
      certificates: certificates,
      skills: skillItems,
      stats: stats,
      roleTitles: roleTitles,
      resumeUrl: firestoreUser.resumeUrl,
    );
  }

  List<SkillItem> _buildSkillItems(List<String> userSkills) {
    if (userSkills.isEmpty) return const [];
    return List.generate(userSkills.length, (i) {
      final level = ((userSkills.length - i) / userSkills.length)
          .clamp(0.50, 1.0)
          .toDouble();
      return SkillItem(
        name: userSkills[i].trim(),
        level: level,
        category: 'General',
      );
    });
  }

  List<StatItem> _buildStats({
    required int projectCount,
    required int experienceCount,
    required int certificateCount,
  }) {
    final stats = <StatItem>[];
    if (projectCount > 0) {
      stats.add(StatItem(
        count: projectCount,
        suffix: '+',
        label: 'Projects',
      ));
    }
    if (experienceCount > 0) {
      stats.add(StatItem(
        count: experienceCount,
        suffix: '+',
        label: 'Experience',
      ));
    }
    if (certificateCount > 0) {
      stats.add(StatItem(
        count: certificateCount,
        suffix: '+',
        label: 'Certificates',
      ));
    }
    return stats;
  }
}
