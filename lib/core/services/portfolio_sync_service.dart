import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:connecthub/core/config/portfolio_config.dart';
import 'package:connecthub/features/profile/data/models/user_model.dart';
import 'package:connecthub/features/portfolio/data/models/project_model.dart';
import 'package:connecthub/features/portfolio/data/models/experience_model.dart';
import 'package:connecthub/features/portfolio/data/models/education_model.dart';
import 'package:connecthub/features/portfolio/data/models/certificate_model.dart';
import 'package:connecthub/features/generate_website/data/models/public_portfolio_snapshot.dart';

/// Responsible for keeping `public_portfolios/{docId}` in sync with the
/// latest user data whenever any portfolio section changes.
///
/// Rules:
/// - Only syncs if the user already has a published portfolio (websiteGenerated == true).
/// - Never creates a new portfolio document — only merges into the existing one.
/// - Never changes the generatedAt timestamp or the public URL.
/// - Always updates updatedAt on every successful sync.
/// - All subcollection reads are parallelised via Future.wait().
/// - Failures are swallowed silently so the caller's UX is never blocked.
class PortfolioSyncService {
  final FirebaseFirestore _firestore;

  PortfolioSyncService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> syncCurrentUserPortfolio() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || uid.isEmpty) return;
    await syncUserPortfolio(uid);
  }

  Future<void> syncUserPortfolio(String uid) async {
    if (uid.isEmpty) return;
    try {
      final userDoc = await _firestore.collection('users').doc(uid).get();
      if (!userDoc.exists) return;

      final userData = userDoc.data() ?? {};
      final user = UserModel.fromDoc(userDoc);
      final websiteGenerated = user.websiteGenerated;

      if (!websiteGenerated) {
        debugPrint('[PortfolioSync] Skipping sync — websiteGenerated=false for $uid');
        return;
      }

      final explicitDocId = (userData['publicPortfolioDocId'] as String?)?.trim();
      String docId = (explicitDocId != null && explicitDocId.isNotEmpty)
          ? explicitDocId
          : _resolveDocId(user);

      DocumentReference portfolioRef = _firestore.collection('public_portfolios').doc(docId);
      DocumentSnapshot existingDoc = await portfolioRef.get();

      if (!existingDoc.exists || (existingDoc.data() as Map<String, dynamic>?)?['uid'] != uid) {
        final querySnap = await _firestore
            .collection('public_portfolios')
            .where('uid', isEqualTo: uid)
            .limit(1)
            .get();
        if (querySnap.docs.isNotEmpty) {
          existingDoc = querySnap.docs.first;
          portfolioRef = existingDoc.reference;
          docId = portfolioRef.id;
        } else {
          debugPrint('[PortfolioSync] No public_portfolios owned by $uid found — skipping sync.');
          return;
        }
      }

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

      final existingData = existingDoc.data() as Map<String, dynamic>? ?? {};
      final publicUrl = existingData['publicPortfolioUrl'] as String? ??
          PortfolioConfig.buildUrl(docId);

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
        cvLink: user.cvLink ?? user.resumeUrl,
        resumeUrl: user.cvLink ?? user.resumeUrl,
        publicPortfolioUrl: publicUrl,
        isPublic: true,
        version: '1.0.0',
        websiteVersion: '1.0.0',
        updatedAt: DateTime.now(),
      );

      await portfolioRef.set(
        _buildUpdateMap(snapshot),
        SetOptions(merge: true),
      );

      await _firestore.collection('users').doc(uid).set({
        'publicPortfolioUpdatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      debugPrint('[PortfolioSync] Synced public_portfolios/$docId for $uid');
    } catch (e, st) {
      debugPrint('[PortfolioSync] Sync failed for $uid: $e\n$st');
    }
  }

  String _resolveDocId(UserModel user) {
    final rawUsername = user.username?.trim();
    final rawSlug = user.profileSlug?.trim();
    if (rawUsername != null && rawUsername.isNotEmpty) {
      return rawUsername.toLowerCase();
    }
    if (rawSlug != null && rawSlug.isNotEmpty) {
      return rawSlug.toLowerCase();
    }
    return user.uid;
  }

  Map<String, dynamic> _buildUpdateMap(PublicPortfolioSnapshot snapshot) {
    return {
      'uid': snapshot.uid,
      if (snapshot.username != null && snapshot.username!.trim().isNotEmpty)
        'username': snapshot.username!.trim().toLowerCase(),
      if (snapshot.profileSlug != null && snapshot.profileSlug!.trim().isNotEmpty)
        'profileSlug': snapshot.profileSlug!.trim().toLowerCase(),
      'displayName': snapshot.name,
      'name': snapshot.name,
      'email': snapshot.email,
      if (snapshot.headline != null) 'headline': snapshot.headline,
      if (snapshot.bio != null) 'bio': snapshot.bio,
      if (snapshot.about != null) 'about': snapshot.about,
      if (snapshot.location != null) 'location': snapshot.location,
      if (snapshot.phone != null) 'phone': snapshot.phone,
      if (snapshot.profileImage != null) 'profileImage': snapshot.profileImage,
      if (snapshot.resumeUrl != null && snapshot.resumeUrl!.trim().isNotEmpty)
        'resumeUrl': snapshot.resumeUrl!.trim(),
      'skills': snapshot.skills,
      'socialLinks': snapshot.socialLinks.toMap(),
      'projects': snapshot.projects.map((p) => p.toMap(includeId: true)).toList(),
      'experience': snapshot.experience.map((e) => e.toMap(includeId: true)).toList(),
      'education': snapshot.education.map((e) => e.toMap(includeId: true)).toList(),
      'certificates': snapshot.certificates.map((c) => c.toMap(includeId: true)).toList(),
      'publicPortfolioUrl': snapshot.publicPortfolioUrl,
      'isPublic': snapshot.isPublic,
      'version': snapshot.version,
      'websiteVersion': snapshot.websiteVersion,
      'updatedAt': FieldValue.serverTimestamp(),
      // generatedAt intentionally omitted — never overwrite it
    };
  }
}
