import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connecthub/features/portfolio_import/data/models/cv_portfolio_model.dart';

/// Converts a [CvPortfolioModel] (AI output) into Firestore-ready models
/// and performs a verified batch write to users/{uid} and all subcollections.
///
/// Schema compatibility:
///   - users/{uid}               → headline, about, location, phone, socialLinks, portfolioSource, portfolioCompleted
///   - users/{uid}/projects      → Project documents
///   - users/{uid}/experience    → Experience documents
///   - users/{uid}/education     → Education documents
///   - users/{uid}/certificates  → Certificate documents
///   - skills are stored on users/{uid}/skills array field
class PortfolioImportFirestoreService {
  final FirebaseFirestore _firestore;

  PortfolioImportFirestoreService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Batch write the full parsed portfolio for [uid].
  /// Existing subcollection data is cleared before writing, preventing duplication.
  Future<void> importPortfolio({
    required String uid,
    required CvPortfolioModel portfolio,
  }) async {
    // ── Task 2 & 5: Verify Auth & User State ─────────────────────────────────
    final currentUser = FirebaseAuth.instance.currentUser;
    final isAuth = currentUser != null;
    final currentUid = currentUser?.uid;
    final currentEmail = currentUser?.email;

    // ignore: avoid_print
    print('================================================================');
    // ignore: avoid_print
    print('[PortfolioImportFirestore] --- User & Authentication Check ---');
    // ignore: avoid_print
    print('[PortfolioImportFirestore] Current Firebase User UID: $currentUid');
    // ignore: avoid_print
    print('[PortfolioImportFirestore] Current User Email: $currentEmail');
    // ignore: avoid_print
    print('[PortfolioImportFirestore] Is User Authenticated?: $isAuth');
    // ignore: avoid_print
    print('[PortfolioImportFirestore] Requested Target UID: $uid');
    // ignore: avoid_print
    print('[PortfolioImportFirestore] --- Portfolio Model Statistics ---');
    // ignore: avoid_print
    print('[PortfolioImportFirestore] Headline: "${portfolio.headline}"');
    // ignore: avoid_print
    print('[PortfolioImportFirestore] Number of skills: ${portfolio.skills.length}');
    // ignore: avoid_print
    print('[PortfolioImportFirestore] Number of projects: ${portfolio.projects.length}');
    // ignore: avoid_print
    print('[PortfolioImportFirestore] Number of experiences: ${portfolio.experience.length}');
    // ignore: avoid_print
    print('[PortfolioImportFirestore] Number of education items: ${portfolio.education.length}');
    // ignore: avoid_print
    print('[PortfolioImportFirestore] Number of certificates: ${portfolio.certificates.length}');
    // ignore: avoid_print
    print('================================================================');

    if (!isAuth) {
      throw const FormatException(
        'Authentication required: FirebaseAuth.currentUser is null. Please sign in before importing.',
      );
    }

    // Always use authenticated user's UID to strictly satisfy Firestore Security Rules (isOwner)
    final effectiveUid = currentUid!;
    if (uid.isNotEmpty && uid != effectiveUid) {
      // ignore: avoid_print
      print(
        '[PortfolioImportFirestore] WARNING: Requested UID "$uid" does not match '
        'currentUser.uid "$effectiveUid". Using "$effectiveUid" to satisfy Firestore isOwner rule.',
      );
    }

    // ── Task 1 & 7: Step 1 - Clear existing subcollections ───────────────────
    final subcollectionsToClear = ['projects', 'experience', 'education', 'certificates'];
    for (final subName in subcollectionsToClear) {
      await _clearSubcollection(effectiveUid, subName);
    }

    // ── Task 3, 6, 8, 9: Step 2 - Validate and Batch Write ───────────────────
    final batch = _firestore.batch();
    int batchCount = 0;
    final userRef = _firestore.collection('users').doc(effectiveUid);

    // Validate and build user document payload
    final userPayload = _buildUserDocPayload(portfolio);
    batchCount++;
    _logOperation(
      operationType: 'set (merge)',
      collectionPath: 'users',
      documentPath: userRef.path,
      documentId: userRef.id,
      batchCount: batchCount,
      data: userPayload,
    );
    batch.set(userRef, userPayload, SetOptions(merge: true));

    // Projects subcollection
    for (int i = 0; i < portfolio.projects.length; i++) {
      final proj = portfolio.projects[i];
      final docRef = userRef.collection('projects').doc();
      final map = _cvProjectToMap(proj, index: i);
      batchCount++;
      _logOperation(
        operationType: 'set',
        collectionPath: 'users/$effectiveUid/projects',
        documentPath: docRef.path,
        documentId: docRef.id,
        batchCount: batchCount,
        data: map,
      );
      batch.set(docRef, map);
    }

    // Experience subcollection
    for (int i = 0; i < portfolio.experience.length; i++) {
      final exp = portfolio.experience[i];
      final docRef = userRef.collection('experience').doc();
      final map = _cvExperienceToMap(exp, index: i);
      batchCount++;
      _logOperation(
        operationType: 'set',
        collectionPath: 'users/$effectiveUid/experience',
        documentPath: docRef.path,
        documentId: docRef.id,
        batchCount: batchCount,
        data: map,
      );
      batch.set(docRef, map);
    }

    // Education subcollection
    for (int i = 0; i < portfolio.education.length; i++) {
      final edu = portfolio.education[i];
      final docRef = userRef.collection('education').doc();
      final map = _cvEducationToMap(edu, index: i);
      batchCount++;
      _logOperation(
        operationType: 'set',
        collectionPath: 'users/$effectiveUid/education',
        documentPath: docRef.path,
        documentId: docRef.id,
        batchCount: batchCount,
        data: map,
      );
      batch.set(docRef, map);
    }

    // Certificates subcollection
    for (int i = 0; i < portfolio.certificates.length; i++) {
      final cert = portfolio.certificates[i];
      final docRef = userRef.collection('certificates').doc();
      final map = _cvCertificateToMap(cert, index: i);
      batchCount++;
      _logOperation(
        operationType: 'set',
        collectionPath: 'users/$effectiveUid/certificates',
        documentPath: docRef.path,
        documentId: docRef.id,
        batchCount: batchCount,
        data: map,
      );
      batch.set(docRef, map);
    }

    // ── Task 4, 8 & 9: Commit Batch with verified exception handling ─────────
    try {
      // ignore: avoid_print
      print('[PortfolioImportFirestore] Committing batch write with $batchCount operations...');
      final startTime = DateTime.now();
      await batch.commit();
      final duration = DateTime.now().difference(startTime);
      // ignore: avoid_print
      print(
        '[PortfolioImportFirestore] ✅ Batch write committed successfully! '
        '($batchCount operations in ${duration.inMilliseconds} ms)',
      );
    } on FirebaseException catch (e, st) {
      // ignore: avoid_print
      print('================================================================');
      // ignore: avoid_print
      print('[PortfolioImportFirestore BATCH COMMIT REJECTED]');
      // ignore: avoid_print
      print('[PortfolioImportFirestore] FirebaseException.code: ${e.code}');
      // ignore: avoid_print
      print('[PortfolioImportFirestore] FirebaseException.message: ${e.message}');
      // ignore: avoid_print
      print('[PortfolioImportFirestore] FirebaseException.plugin: ${e.plugin}');
      // ignore: avoid_print
      print('[PortfolioImportFirestore] Total operations in failed batch: $batchCount');
      // ignore: avoid_print
      print('[PortfolioImportFirestore] Target user document: ${userRef.path}');
      // ignore: avoid_print
      print('[PortfolioImportFirestore] Stack Trace:\n$st');
      // ignore: avoid_print
      print('================================================================');
      rethrow;
    } catch (e, st) {
      // ignore: avoid_print
      print('================================================================');
      // ignore: avoid_print
      print('[PortfolioImportFirestore UNEXPECTED BATCH ERROR]: $e');
      // ignore: avoid_print
      print('[PortfolioImportFirestore] Stack Trace:\n$st');
      // ignore: avoid_print
      print('================================================================');
      rethrow;
    }
  }

  // ── Validation and Payload Builders ───────────────────────────────────────

  Map<String, dynamic> _buildUserDocPayload(CvPortfolioModel portfolio) {
    final payload = <String, dynamic>{};

    if (portfolio.headline.trim().isNotEmpty) {
      payload['headline'] = portfolio.headline.trim();
    }
    if (portfolio.summary.trim().isNotEmpty) {
      payload['about'] = portfolio.summary.trim();
    }
    if (portfolio.location.trim().isNotEmpty) {
      payload['location'] = portfolio.location.trim();
    }
    if (portfolio.phone.trim().isNotEmpty) {
      payload['phone'] = portfolio.phone.trim();
    }

    final socialLinks = <String, dynamic>{};
    if (portfolio.github.trim().isNotEmpty) {
      socialLinks['github'] = portfolio.github.trim();
    }
    if (portfolio.linkedin.trim().isNotEmpty) {
      socialLinks['linkedin'] = portfolio.linkedin.trim();
    }
    if (portfolio.website.trim().isNotEmpty) {
      socialLinks['website'] = portfolio.website.trim();
    }
    if (socialLinks.isNotEmpty) {
      payload['socialLinks'] = socialLinks;
    }

    final cleanSkills = portfolio.skills
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toSet()
        .toList();
    if (cleanSkills.isNotEmpty) {
      payload['skills'] = cleanSkills;
    }

    payload['portfolioSource'] = 'cv_ai';
    payload['portfolioCompleted'] = true;
    payload['portfolioVersion'] = 1;

    _validateMap('users/{uid}', payload);
    return payload;
  }

  Map<String, dynamic> _cvProjectToMap(CvProjectModel p, {required int index}) {
    final tech = p.techStack
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    final map = <String, dynamic>{
      'title': p.title.trim().isNotEmpty ? p.title.trim() : 'Project ${index + 1}',
      'description': p.description.trim(),
      'technologies': tech,
      if (p.github.trim().isNotEmpty) 'githubUrl': p.github.trim(),
      if (p.liveDemo.trim().isNotEmpty) 'projectUrl': p.liveDemo.trim(),
      'isFeatured': false,
      'isVisible': true,
    };
    _validateMap('projects[$index]', map);
    return map;
  }

  Map<String, dynamic> _cvExperienceToMap(CvExperienceModel e, {required int index}) {
    final map = <String, dynamic>{
      'company': e.company.trim().isNotEmpty ? e.company.trim() : 'Company',
      'role': e.position.trim().isNotEmpty ? e.position.trim() : 'Role',
      'description': e.description.trim(),
      'skills': <String>[],
      'isCurrent': e.endDate.toLowerCase().contains('present') || e.endDate.isEmpty,
      'isVisible': true,
    };
    _validateMap('experience[$index]', map);
    return map;
  }

  Map<String, dynamic> _cvEducationToMap(CvEducationModel e, {required int index}) {
    final map = <String, dynamic>{
      'institution': e.institution.trim().isNotEmpty ? e.institution.trim() : 'Institution',
      'degree': e.degree.trim().isNotEmpty ? e.degree.trim() : 'Degree',
      if (e.field.trim().isNotEmpty) 'fieldOfStudy': e.field.trim(),
      'isVisible': true,
    };
    _validateMap('education[$index]', map);
    return map;
  }

  Map<String, dynamic> _cvCertificateToMap(CvCertificateModel c, {required int index}) {
    final map = <String, dynamic>{
      'title': c.title.trim().isNotEmpty ? c.title.trim() : 'Certificate',
      'issuingOrganization': c.issuer.trim().isNotEmpty ? c.issuer.trim() : 'Organization',
      if (c.url.trim().isNotEmpty) 'credentialUrl': c.url.trim(),
      'isVisible': true,
    };
    _validateMap('certificates[$index]', map);
    return map;
  }

  void _validateMap(String context, Map<String, dynamic> map) {
    for (final entry in map.entries) {
      if (entry.value == null) {
        throw FormatException(
          '[Validation Error in $context] Key "${entry.key}" has a null value which is invalid for Firestore.',
        );
      }
    }
  }

  void _logOperation({
    required String operationType,
    required String collectionPath,
    required String documentPath,
    required String documentId,
    required int batchCount,
    required Map<String, dynamic> data,
  }) {
    // ignore: avoid_print
    print(
      '[PortfolioImportFirestore] [Batch Op #$batchCount: $operationType] '
      'Collection: "$collectionPath" | DocID: "$documentId" | Path: "$documentPath" '
      '| Fields: ${data.keys.toList()}',
    );
  }

  // ── Subcollection clearing ────────────────────────────────────────────────

  Future<void> _clearSubcollection(String uid, String collection) async {
    final collectionPath = 'users/$uid/$collection';
    try {
      final snap = await _firestore
          .collection('users')
          .doc(uid)
          .collection(collection)
          .limit(100)
          .get();

      if (snap.docs.isEmpty) {
        // ignore: avoid_print
        print('[PortfolioImportFirestore] Subcollection "$collectionPath" is currently empty (0 docs to clear).');
        return;
      }

      // ignore: avoid_print
      print('[PortfolioImportFirestore] Found ${snap.docs.length} existing documents in "$collectionPath". Clearing...');
      final clearBatch = _firestore.batch();
      int deleteCount = 0;
      for (final doc in snap.docs) {
        deleteCount++;
        // ignore: avoid_print
        print(
          '[PortfolioImportFirestore] [Batch Op #$deleteCount: delete] '
          'Collection: "$collectionPath" | DocID: "${doc.id}" | Path: "${doc.reference.path}"',
        );
        clearBatch.delete(doc.reference);
      }
      await clearBatch.commit();
      // ignore: avoid_print
      print('[PortfolioImportFirestore] ✅ Successfully cleared $deleteCount documents from "$collectionPath".');
    } on FirebaseException catch (e, st) {
      // ignore: avoid_print
      print('================================================================');
      // ignore: avoid_print
      print('[PortfolioImportFirestore ERROR] Failed clearing subcollection "$collectionPath":');
      // ignore: avoid_print
      print('FirebaseException.code: ${e.code}');
      // ignore: avoid_print
      print('FirebaseException.message: ${e.message}');
      // ignore: avoid_print
      print('Stack trace:\n$st');
      // ignore: avoid_print
      print('================================================================');
      rethrow;
    } catch (e, st) {
      // ignore: avoid_print
      print('[PortfolioImportFirestore ERROR] Unexpected error clearing "$collectionPath": $e\n$st');
      rethrow;
    }
  }
}
