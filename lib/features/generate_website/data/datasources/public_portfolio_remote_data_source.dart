import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connecthub/core/config/portfolio_config.dart';
import 'package:connecthub/features/profile/data/models/user_model.dart';
import 'package:connecthub/features/portfolio/data/models/project_model.dart';
import 'package:connecthub/features/portfolio/data/models/experience_model.dart';
import 'package:connecthub/features/portfolio/data/models/education_model.dart';
import 'package:connecthub/features/portfolio/data/models/certificate_model.dart';
import '../models/public_portfolio_snapshot.dart';

abstract class PublicPortfolioRemoteDataSource {
  /// Aggregates user profile + subcollections, creates/updates snapshot in `public_portfolios/{docId}`,
  /// generates the permanent public URL, and saves it in `users/{uid}`.
  Future<PublicPortfolioSnapshot> generateAndPublishPortfolio({
    required String uid,
    UserModel? cachedUser,
  });

  /// Fetches a public portfolio snapshot from `public_portfolios` collection by username or UID.
  Future<PublicPortfolioSnapshot?> getPublicPortfolio(String? identifier);
}

class PublicPortfolioRemoteDataSourceImpl implements PublicPortfolioRemoteDataSource {
  final FirebaseFirestore _firestore;

  PublicPortfolioRemoteDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<PublicPortfolioSnapshot> generateAndPublishPortfolio({
    required String uid,
    UserModel? cachedUser,
  }) async {
    // 1. Fetch user doc if not cached or to ensure fresh data
    UserModel user;
    if (cachedUser != null) {
      user = cachedUser;
    } else {
      final userDoc = await _firestore.collection('users').doc(uid).get();
      if (!userDoc.exists) {
        throw Exception('User profile not found for uid: $uid');
      }
      user = UserModel.fromDoc(userDoc);
    }

    // 2. Concurrently fetch all subcollections
    final results = await Future.wait([
      _firestore.collection('users').doc(uid).collection('projects').get(),
      _firestore.collection('users').doc(uid).collection('experience').get(),
      _firestore.collection('users').doc(uid).collection('education').get(),
      _firestore.collection('users').doc(uid).collection('certificates').get(),
    ]);

    final projects = (results[0] as QuerySnapshot)
        .docs
        .map(ProjectModel.fromDoc)
        .where((p) => p.isVisible)
        .toList();

    final experience = (results[1] as QuerySnapshot)
        .docs
        .map(ExperienceModel.fromDoc)
        .where((e) => e.isVisible)
        .toList();

    final education = (results[2] as QuerySnapshot)
        .docs
        .map(EducationModel.fromDoc)
        .where((ed) => ed.isVisible)
        .toList();

    final certificates = (results[3] as QuerySnapshot)
        .docs
        .map(CertificateModel.fromDoc)
        .where((c) => c.isVisible)
        .toList();

    // 3. Determine document ID: username, profileSlug, or fallback to uid
    final rawUsername = user.username?.trim();
    final rawSlug = user.profileSlug?.trim();
    final docId = (rawUsername != null && rawUsername.isNotEmpty)
        ? rawUsername.toLowerCase()
        : (rawSlug != null && rawSlug.isNotEmpty)
            ? rawSlug.toLowerCase()
            : user.uid;

    // 4. Generate permanent public URL using PortfolioConfig
    final publicUrl = PortfolioConfig.buildUrl(docId);

    // 5. Check if document already exists
    final targetDocRef = _firestore.collection('public_portfolios').doc(docId);
    final existingDoc = await targetDocRef.get();
    final isFirstGen = !existingDoc.exists;

    // 6. Build snapshot
    final snapshot = PublicPortfolioSnapshot(
      uid: user.uid,
      username: user.username,
      profileSlug: user.profileSlug,
      name: user.name,
      email: user.email,
      headline: user.headline,
      bio: user.bio,
      about: user.about,
      location: user.location,
      phone: user.phone,
      profileImage: user.profileImage,
      skills: user.skills,
      socialLinks: user.socialLinks,
      projects: projects,
      experience: experience,
      education: education,
      certificates: certificates,
      resumeUrl: user.resumeUrl,
      publicPortfolioUrl: publicUrl,
      isPublic: true,
      version: '1.0.0',
      websiteVersion: '1.0.0',
      generatedAt: isFirstGen ? DateTime.now() : (existingDoc.data()?['generatedAt'] as Timestamp?)?.toDate(),
      updatedAt: DateTime.now(),
    );

    // 7. Write snapshot to public_portfolios collection
    await targetDocRef.set(
      snapshot.toMap(isFirstGeneration: isFirstGen),
      SetOptions(merge: true),
    );

    // 8. Save generated metadata in users/{uid}
    await _firestore.collection('users').doc(user.uid).set({
      'websiteGenerated': true,
      'websiteUrl': publicUrl,
      'generatedAt': FieldValue.serverTimestamp(),
      'publicPortfolioUrl': publicUrl,
      'publicPortfolioDocId': docId,
      'publicPortfolioUpdatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    return snapshot;
  }

  @override
  Future<PublicPortfolioSnapshot?> getPublicPortfolio(String? identifier) async {
    final cleanId = identifier?.trim();
    if (cleanId == null || cleanId.isEmpty) {
      return null;
    }

    try {
      // 1. Direct doc lookup by lowercased username/identifier
      final docByLower = await _firestore
          .collection('public_portfolios')
          .doc(cleanId.toLowerCase())
          .get();
      if (docByLower.exists) {
        return PublicPortfolioSnapshot.fromDoc(docByLower);
      }

      // 2. Direct doc lookup by exact identifier (e.g. UID)
      final docExact = await _firestore
          .collection('public_portfolios')
          .doc(cleanId)
          .get();
      if (docExact.exists) {
        return PublicPortfolioSnapshot.fromDoc(docExact);
      }

      // 3. Fallback: Query where uid == cleanId
      final uidQuery = await _firestore
          .collection('public_portfolios')
          .where('uid', isEqualTo: cleanId)
          .limit(1)
          .get();
      if (uidQuery.docs.isNotEmpty) {
        return PublicPortfolioSnapshot.fromDoc(uidQuery.docs.first);
      }

      // 4. Fallback: Query where username == cleanId (lowercased)
      final usernameQuery = await _firestore
          .collection('public_portfolios')
          .where('username', isEqualTo: cleanId.toLowerCase())
          .limit(1)
          .get();
      if (usernameQuery.docs.isNotEmpty) {
        return PublicPortfolioSnapshot.fromDoc(usernameQuery.docs.first);
      }

      // 5. Fallback: Query where profileSlug == cleanId (lowercased)
      final slugQuery = await _firestore
          .collection('public_portfolios')
          .where('profileSlug', isEqualTo: cleanId.toLowerCase())
          .limit(1)
          .get();
      if (slugQuery.docs.isNotEmpty) {
        return PublicPortfolioSnapshot.fromDoc(slugQuery.docs.first);
      }

      return null;
    } catch (_) {
      return null;
    }
  }
}
