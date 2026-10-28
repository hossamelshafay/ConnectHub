import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
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

  /// Helper to execute Firestore operations with detailed error logging.
  /// Reports collection, document path, operation, and the exact exception.
  Future<T> _runLoggedOp<T>({
    required String collection,
    required String docPath,
    required String operation,
    required Future<T> Function() action,
  }) async {
    try {
      return await action();
    } on FirebaseException catch (e, st) {
      final detailedMsg =
          '[Firestore Operation Error] Collection: "$collection", Document: "$docPath", Operation: "$operation", Code: "${e.code}", Message: "${e.message ?? e.toString()}"';
      debugPrint('$detailedMsg\nStack trace:\n$st');
      throw FirebaseException(
        plugin: e.plugin,
        code: e.code,
        message: detailedMsg,
      );
    } catch (e, st) {
      final detailedMsg =
          '[Firestore Operation Error] Collection: "$collection", Document: "$docPath", Operation: "$operation", Exception: "$e"';
      debugPrint('$detailedMsg\nStack trace:\n$st');
      throw Exception(detailedMsg);
    }
  }

  @override
  Future<PublicPortfolioSnapshot> generateAndPublishPortfolio({
    required String uid,
    UserModel? cachedUser,
  }) async {
    // 1. Fetch fresh user document directly from Firestore
    final userDoc = await _runLoggedOp(
      collection: 'users',
      docPath: 'users/$uid',
      operation: 'read',
      action: () => _firestore.collection('users').doc(uid).get(),
    );

    if (!userDoc.exists) {
      throw Exception('[Firestore Error] User profile document not found at "users/$uid" for uid: $uid');
    }
    final userData = userDoc.data() ?? {};
    final user = UserModel.fromDoc(userDoc);

    // 2. Concurrently fetch all subcollections
    final results = await Future.wait([
      _runLoggedOp(
        collection: 'projects',
        docPath: 'users/$uid/projects',
        operation: 'read subcollection',
        action: () => _firestore.collection('users').doc(uid).collection('projects').get(),
      ),
      _runLoggedOp(
        collection: 'experience',
        docPath: 'users/$uid/experience',
        operation: 'read subcollection',
        action: () => _firestore.collection('users').doc(uid).collection('experience').get(),
      ),
      _runLoggedOp(
        collection: 'education',
        docPath: 'users/$uid/education',
        operation: 'read subcollection',
        action: () => _firestore.collection('users').doc(uid).collection('education').get(),
      ),
      _runLoggedOp(
        collection: 'certificates',
        docPath: 'users/$uid/certificates',
        operation: 'read subcollection',
        action: () => _firestore.collection('users').doc(uid).collection('certificates').get(),
      ),
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

    // 3. Resolve a collision-free document ID
    final explicitDocId = (userData['publicPortfolioDocId'] as String?)?.trim();
    String docId;

    if (explicitDocId != null && explicitDocId.isNotEmpty) {
      docId = explicitDocId;
    } else {
      final rawUsername = user.username?.trim();
      final rawSlug = user.profileSlug?.trim();
      String candidateId;

      if (rawUsername != null && rawUsername.isNotEmpty) {
        candidateId = rawUsername.toLowerCase();
      } else if (rawSlug != null && rawSlug.isNotEmpty) {
        candidateId = rawSlug.toLowerCase();
      } else {
        final cleanBase = user.name.trim().toLowerCase()
            .replaceAll(RegExp(r'[^a-z0-9_-]'), '-')
            .replaceAll(RegExp(r'-+'), '-')
            .replaceAll(RegExp(r'^-|-$'), '');
        candidateId = cleanBase.isNotEmpty ? cleanBase : 'user';
      }

      // Check for collision in public_portfolios
      final checkDoc = await _runLoggedOp(
        collection: 'public_portfolios',
        docPath: 'public_portfolios/$candidateId',
        operation: 'read (collision check)',
        action: () => _firestore.collection('public_portfolios').doc(candidateId).get(),
      );

      if (checkDoc.exists && checkDoc.data()?['uid'] != user.uid) {
        // The candidate ID is owned by someone else! Append short UID to guarantee uniqueness
        final shortUid = user.uid.length >= 6
            ? user.uid.substring(0, 6).toLowerCase()
            : user.uid.toLowerCase();
        docId = '$candidateId-$shortUid';
      } else {
        docId = candidateId;
      }
    }

    // 4. Generate permanent public URL using PortfolioConfig
    final publicUrl = PortfolioConfig.buildUrl(docId);

    // 5. Inspect target document existence
    final targetDocRef = _firestore.collection('public_portfolios').doc(docId);
    final existingDoc = await _runLoggedOp(
      collection: 'public_portfolios',
      docPath: 'public_portfolios/$docId',
      operation: 'read',
      action: () => targetDocRef.get(),
    );
    final isFirstGen = !existingDoc.exists;

    // 6. Build snapshot (pure data representation)
    final snapshot = PublicPortfolioSnapshot(
      uid: user.uid,
      username: user.username,
      profileSlug: docId,
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
      generatedAt: isFirstGen ? DateTime.now() : (existingDoc.data()?['generatedAt'] as Timestamp?)?.toDate(),
      updatedAt: DateTime.now(),
    );

    // 7. Write snapshot to public_portfolios collection
    await _runLoggedOp(
      collection: 'public_portfolios',
      docPath: 'public_portfolios/$docId',
      operation: isFirstGen ? 'create (set)' : 'update (set merge)',
      action: () => targetDocRef.set(
        snapshot.toMap(isFirstGeneration: isFirstGen),
        SetOptions(merge: true),
      ),
    );

    // 8. Save generated metadata in users/{uid}
    await _runLoggedOp(
      collection: 'users',
      docPath: 'users/${user.uid}',
      operation: 'update (set merge)',
      action: () => _firestore.collection('users').doc(user.uid).set({
        'websiteGenerated': true,
        'websiteUrl': publicUrl,
        'generatedAt': FieldValue.serverTimestamp(),
        'publicPortfolioUrl': publicUrl,
        'publicPortfolioDocId': docId,
        'profileSlug': docId,
        'publicPortfolioUpdatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true)),
    );

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
      final docByLower = await _runLoggedOp(
        collection: 'public_portfolios',
        docPath: 'public_portfolios/${cleanId.toLowerCase()}',
        operation: 'read',
        action: () => _firestore.collection('public_portfolios').doc(cleanId.toLowerCase()).get(),
      );
      if (docByLower.exists) {
        return PublicPortfolioSnapshot.fromDoc(docByLower);
      }

      // 2. Direct doc lookup by exact identifier (e.g. UID)
      final docExact = await _runLoggedOp(
        collection: 'public_portfolios',
        docPath: 'public_portfolios/$cleanId',
        operation: 'read',
        action: () => _firestore.collection('public_portfolios').doc(cleanId).get(),
      );
      if (docExact.exists) {
        return PublicPortfolioSnapshot.fromDoc(docExact);
      }

      // 3. Fallback: Query where uid == cleanId
      final uidQuery = await _runLoggedOp(
        collection: 'public_portfolios',
        docPath: 'public_portfolios(where uid == $cleanId)',
        operation: 'query',
        action: () => _firestore
            .collection('public_portfolios')
            .where('uid', isEqualTo: cleanId)
            .limit(1)
            .get(),
      );
      if (uidQuery.docs.isNotEmpty) {
        return PublicPortfolioSnapshot.fromDoc(uidQuery.docs.first);
      }

      // 4. Fallback: Query where username == cleanId (lowercased)
      final usernameQuery = await _runLoggedOp(
        collection: 'public_portfolios',
        docPath: 'public_portfolios(where username == ${cleanId.toLowerCase()})',
        operation: 'query',
        action: () => _firestore
            .collection('public_portfolios')
            .where('username', isEqualTo: cleanId.toLowerCase())
            .limit(1)
            .get(),
      );
      if (usernameQuery.docs.isNotEmpty) {
        return PublicPortfolioSnapshot.fromDoc(usernameQuery.docs.first);
      }

      // 5. Fallback: Query where profileSlug == cleanId (lowercased)
      final slugQuery = await _runLoggedOp(
        collection: 'public_portfolios',
        docPath: 'public_portfolios(where profileSlug == ${cleanId.toLowerCase()})',
        operation: 'query',
        action: () => _firestore
            .collection('public_portfolios')
            .where('profileSlug', isEqualTo: cleanId.toLowerCase())
            .limit(1)
            .get(),
      );
      if (slugQuery.docs.isNotEmpty) {
        return PublicPortfolioSnapshot.fromDoc(slugQuery.docs.first);
      }

      return null;
    } catch (e) {
      debugPrint('[PublicPortfolioRemoteDataSource] getPublicPortfolio lookup error: $e');
      return null;
    }
  }
}
