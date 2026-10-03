import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:connecthub/features/portfolio/data/models/project_model.dart';
import 'package:connecthub/features/portfolio/data/models/experience_model.dart';
import 'package:connecthub/features/portfolio/data/models/education_model.dart';
import 'package:connecthub/features/portfolio/data/models/certificate_model.dart';
import 'package:connecthub/features/portfolio/data/models/social_links_model.dart';
import 'package:connecthub/features/portfolio_import/presentation/cubit/portfolio_import_state.dart';

/// Handles all live CRUD operations for every portfolio section.
/// Each method writes to Firestore immediately after the user confirms.
class PortfolioEditorCubit extends Cubit<PortfolioEditorState> {
  final FirebaseFirestore _db;
  static const _uuid = Uuid();

  PortfolioEditorCubit({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance,
        super(const PortfolioEditorIdle());

  // ── Firestore References ──────────────────────────────────────────────────

  DocumentReference _userDoc(String uid) => _db.collection('users').doc(uid);

  CollectionReference _sub(String uid, String col) =>
      _userDoc(uid).collection(col);

  // ── Hero / About / Contact ────────────────────────────────────────────────

  Future<void> updateProfile({
    required String uid,
    String? headline,
    String? about,
    String? location,
    String? phone,
    SocialLinksModel? socialLinks,
  }) async {
    await _run(() async {
      final data = <String, dynamic>{};
      if (headline != null) data['headline'] = headline.trim();
      if (about != null) data['about'] = about.trim();
      if (location != null) data['location'] = location.trim();
      if (phone != null) data['phone'] = phone.trim();
      if (socialLinks != null) data['socialLinks'] = socialLinks.toMap();
      if (data.isNotEmpty) {
        await _userDoc(uid).set(data, SetOptions(merge: true));
      }
    }, successMessage: 'Profile updated.');
  }

  // ── Skills ────────────────────────────────────────────────────────────────

  Future<void> updateSkills({
    required String uid,
    required List<String> skills,
  }) async {
    await _run(() async {
      await _userDoc(uid).set({'skills': skills}, SetOptions(merge: true));
    }, successMessage: 'Skills saved.');
  }

  // ── Projects ──────────────────────────────────────────────────────────────

  Future<void> addProject({
    required String uid,
    required ProjectModel project,
  }) async {
    await _run(() async {
      final id = _uuid.v4();
      await _sub(uid, 'projects').doc(id).set(project.toMap());
    }, successMessage: 'Project added.');
  }

  Future<void> updateProject({
    required String uid,
    required ProjectModel project,
  }) async {
    await _run(() async {
      await _sub(uid, 'projects').doc(project.id).set(project.toMap());
    }, successMessage: 'Project updated.');
  }

  Future<void> deleteProject({required String uid, required String projectId}) async {
    await _run(() async {
      await _sub(uid, 'projects').doc(projectId).delete();
    }, successMessage: 'Project deleted.');
  }

  // ── Experience ────────────────────────────────────────────────────────────

  Future<void> addExperience({
    required String uid,
    required ExperienceModel experience,
  }) async {
    await _run(() async {
      final id = _uuid.v4();
      await _sub(uid, 'experience').doc(id).set(experience.toMap());
    }, successMessage: 'Experience added.');
  }

  Future<void> updateExperience({
    required String uid,
    required ExperienceModel experience,
  }) async {
    await _run(() async {
      await _sub(uid, 'experience').doc(experience.id).set(experience.toMap());
    }, successMessage: 'Experience updated.');
  }

  Future<void> deleteExperience({
    required String uid,
    required String experienceId,
  }) async {
    await _run(() async {
      await _sub(uid, 'experience').doc(experienceId).delete();
    }, successMessage: 'Experience deleted.');
  }

  // ── Education ─────────────────────────────────────────────────────────────

  Future<void> addEducation({
    required String uid,
    required EducationModel education,
  }) async {
    await _run(() async {
      final id = _uuid.v4();
      await _sub(uid, 'education').doc(id).set(education.toMap());
    }, successMessage: 'Education added.');
  }

  Future<void> updateEducation({
    required String uid,
    required EducationModel education,
  }) async {
    await _run(() async {
      await _sub(uid, 'education').doc(education.id).set(education.toMap());
    }, successMessage: 'Education updated.');
  }

  Future<void> deleteEducation({
    required String uid,
    required String educationId,
  }) async {
    await _run(() async {
      await _sub(uid, 'education').doc(educationId).delete();
    }, successMessage: 'Education deleted.');
  }

  // ── Certificates ──────────────────────────────────────────────────────────

  Future<void> addCertificate({
    required String uid,
    required CertificateModel certificate,
  }) async {
    await _run(() async {
      final id = _uuid.v4();
      await _sub(uid, 'certificates').doc(id).set(certificate.toMap());
    }, successMessage: 'Certificate added.');
  }

  Future<void> updateCertificate({
    required String uid,
    required CertificateModel certificate,
  }) async {
    await _run(() async {
      await _sub(uid, 'certificates')
          .doc(certificate.id)
          .set(certificate.toMap());
    }, successMessage: 'Certificate updated.');
  }

  Future<void> deleteCertificate({
    required String uid,
    required String certificateId,
  }) async {
    await _run(() async {
      await _sub(uid, 'certificates').doc(certificateId).delete();
    }, successMessage: 'Certificate deleted.');
  }

  // ── Helper ────────────────────────────────────────────────────────────────

  Future<void> _run(
    Future<void> Function() operation, {
    required String successMessage,
  }) async {
    emit(const PortfolioEditorSaving());
    try {
      await operation();
      emit(PortfolioEditorSaved(successMessage));
    } catch (e) {
      emit(PortfolioEditorError(e.toString().replaceAll('Exception: ', '')));
    } finally {
      // Return to idle after a short delay so listeners can react
      await Future<void>.delayed(const Duration(milliseconds: 300));
      if (!isClosed) emit(const PortfolioEditorIdle());
    }
  }
}
