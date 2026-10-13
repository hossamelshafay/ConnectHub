import 'dart:io' show SocketException;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/exceptions.dart';
import '../../../features/profile/data/models/user_model.dart';
import '../../../features/portfolio/data/models/project_model.dart';
import '../../../features/portfolio/data/models/experience_model.dart';
import '../../../features/portfolio/data/models/education_model.dart';
import '../../../features/portfolio/data/models/certificate_model.dart';

import '../../../features/generate_website/data/models/public_portfolio_snapshot.dart';

/// Contract for fetching raw portfolio data directly from Cloud Firestore.
abstract class WebPortfolioRemoteDataSource {
  /// Fetches a denormalized snapshot from `public_portfolios` by username or UID.
  Future<PublicPortfolioSnapshot?> getPublicPortfolioSnapshot(String? identifier);

  /// Resolves the user document by either direct UID, username, or profileSlug.
  Future<UserModel?> getUserByIdOrUsername(String? identifier);

  /// Fetches all public/visible projects under `users/{uid}/projects`.
  Future<List<ProjectModel>> getProjects(String uid);

  /// Fetches all experience records under `users/{uid}/experience`.
  Future<List<ExperienceModel>> getExperiences(String uid);

  /// Fetches all education records under `users/{uid}/education`.
  Future<List<EducationModel>> getEducations(String uid);

  /// Fetches all certificates under `users/{uid}/certificates`.
  Future<List<CertificateModel>> getCertificates(String uid);
}

/// Firebase implementation of [WebPortfolioRemoteDataSource].
class WebPortfolioRemoteDataSourceImpl implements WebPortfolioRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  WebPortfolioRemoteDataSourceImpl({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  @override
  Future<PublicPortfolioSnapshot?> getPublicPortfolioSnapshot(String? identifier) async {
    try {
      final cleanId = identifier?.trim();
      if (cleanId == null || cleanId.isEmpty) {
        final currentUid = _auth.currentUser?.uid;
        if (currentUid != null) {
          final doc = await _firestore.collection('public_portfolios').doc(currentUid).get();
          if (doc.exists) return PublicPortfolioSnapshot.fromDoc(doc);
          final uidQuery = await _firestore
              .collection('public_portfolios')
              .where('uid', isEqualTo: currentUid)
              .limit(1)
              .get();
          if (uidQuery.docs.isNotEmpty) {
            return PublicPortfolioSnapshot.fromDoc(uidQuery.docs.first);
          }
        }
        return null;
      }

      // 1. Direct doc lookup by lowercased username / identifier
      final docByLower = await _firestore
          .collection('public_portfolios')
          .doc(cleanId.toLowerCase())
          .get();
      if (docByLower.exists) {
        return PublicPortfolioSnapshot.fromDoc(docByLower);
      }

      // 2. Direct doc lookup by exact identifier (UID or exact case)
      final docExact = await _firestore
          .collection('public_portfolios')
          .doc(cleanId)
          .get();
      if (docExact.exists) {
        return PublicPortfolioSnapshot.fromDoc(docExact);
      }

      // 3. Query where uid == cleanId
      final uidQuery = await _firestore
          .collection('public_portfolios')
          .where('uid', isEqualTo: cleanId)
          .limit(1)
          .get();
      if (uidQuery.docs.isNotEmpty) {
        return PublicPortfolioSnapshot.fromDoc(uidQuery.docs.first);
      }

      // 4. Query where username == cleanId (lowercased)
      final usernameQuery = await _firestore
          .collection('public_portfolios')
          .where('username', isEqualTo: cleanId.toLowerCase())
          .limit(1)
          .get();
      if (usernameQuery.docs.isNotEmpty) {
        return PublicPortfolioSnapshot.fromDoc(usernameQuery.docs.first);
      }

      // 5. Query where profileSlug == cleanId (lowercased)
      final slugQuery = await _firestore
          .collection('public_portfolios')
          .where('profileSlug', isEqualTo: cleanId.toLowerCase())
          .limit(1)
          .get();
      if (slugQuery.docs.isNotEmpty) {
        return PublicPortfolioSnapshot.fromDoc(slugQuery.docs.first);
      }

      return null;
    } on SocketException catch (_) {
      throw const PortfolioOfflineException();
    } on FirebaseException catch (e) {
      if (e.code == 'unavailable' || e.code == 'network-request-failed') {
        throw const PortfolioOfflineException();
      }
      throw PortfolioServerException(e.message ?? 'Firestore error occurred', e);
    } catch (e) {
      if (e is WebPortfolioException) rethrow;
      throw PortfolioServerException('Failed to retrieve public portfolio snapshot', e);
    }
  }

  @override
  Future<UserModel?> getUserByIdOrUsername(String? identifier) async {
    try {
      final cleanId = identifier?.trim();

      // Case 1: An explicit identifier was provided
      if (cleanId != null && cleanId.isNotEmpty) {
        // 1a. Try direct UID match
        try {
          final directDoc = await _firestore.collection('users').doc(cleanId).get();
          if (directDoc.exists) {
            return UserModel.fromDoc(directDoc);
          }
        } catch (_) {
          // If direct get fails due to ID formatting, continue to query
        }

        // 1b. Query by username (case-insensitive search)
        final usernameQuery = await _firestore
            .collection('users')
            .where('username', isEqualTo: cleanId.toLowerCase())
            .limit(1)
            .get();

        if (usernameQuery.docs.isNotEmpty) {
          return UserModel.fromDoc(usernameQuery.docs.first);
        }

        // 1c. Query by profileSlug
        final slugQuery = await _firestore
            .collection('users')
            .where('profileSlug', isEqualTo: cleanId.toLowerCase())
            .limit(1)
            .get();

        if (slugQuery.docs.isNotEmpty) {
          return UserModel.fromDoc(slugQuery.docs.first);
        }

        // 1d. Case-sensitive username fallback
        final rawUsernameQuery = await _firestore
            .collection('users')
            .where('username', isEqualTo: cleanId)
            .limit(1)
            .get();

        if (rawUsernameQuery.docs.isNotEmpty) {
          return UserModel.fromDoc(rawUsernameQuery.docs.first);
        }

        return null;
      }

      // Case 2: No identifier supplied -> Check current authenticated user
      final currentUid = _auth.currentUser?.uid;
      if (currentUid != null) {
        final currentDoc = await _firestore.collection('users').doc(currentUid).get();
        if (currentDoc.exists) {
          return UserModel.fromDoc(currentDoc);
        }
      }

      return null;
    } on SocketException catch (_) {
      throw const PortfolioOfflineException();
    } on FirebaseException catch (e) {
      if (e.code == 'unavailable' || e.code == 'network-request-failed') {
        throw const PortfolioOfflineException();
      }
      throw PortfolioServerException(e.message ?? 'Firestore error occurred', e);
    } catch (e) {
      if (e is WebPortfolioException) rethrow;
      throw PortfolioServerException('Failed to retrieve user portfolio profile', e);
    }
  }

  @override
  Future<List<ProjectModel>> getProjects(String uid) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('projects')
          .get();

      return snapshot.docs
          .map(ProjectModel.fromDoc)
          .where((p) => p.isVisible)
          .toList()
        ..sort((a, b) {
          if (a.isFeatured && !b.isFeatured) return -1;
          if (!a.isFeatured && b.isFeatured) return 1;
          final dateA = a.startDate ?? DateTime(2000);
          final dateB = b.startDate ?? DateTime(2000);
          return dateB.compareTo(dateA);
        });
    } catch (e) {
      // Return empty list gracefully if subcollection doesn't exist yet
      return [];
    }
  }

  @override
  Future<List<ExperienceModel>> getExperiences(String uid) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('experience')
          .get();

      return snapshot.docs
          .map(ExperienceModel.fromDoc)
          .toList()
        ..sort((a, b) {
          if (a.isCurrent && !b.isCurrent) return -1;
          if (!a.isCurrent && b.isCurrent) return 1;
          final dateA = a.startDate ?? DateTime(2000);
          final dateB = b.startDate ?? DateTime(2000);
          return dateB.compareTo(dateA);
        });
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<EducationModel>> getEducations(String uid) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('education')
          .get();

      return snapshot.docs
          .map(EducationModel.fromDoc)
          .toList()
        ..sort((a, b) {
          final dateA = a.startDate ?? DateTime(2000);
          final dateB = b.startDate ?? DateTime(2000);
          return dateB.compareTo(dateA);
        });
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<CertificateModel>> getCertificates(String uid) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('certificates')
          .get();

      return snapshot.docs
          .map(CertificateModel.fromDoc)
          .where((c) => c.isVisible)
          .toList()
        ..sort((a, b) {
          final dateA = a.issueDate ?? DateTime(2000);
          final dateB = b.issueDate ?? DateTime(2000);
          return dateB.compareTo(dateA);
        });
    } catch (e) {
      return [];
    }
  }
}
