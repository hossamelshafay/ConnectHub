import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connecthub/features/profile/data/models/user_model.dart';
import 'package:connecthub/features/portfolio/data/models/project_model.dart';
import 'package:connecthub/features/portfolio/data/models/experience_model.dart';
import 'package:connecthub/features/portfolio/data/models/education_model.dart';
import 'package:connecthub/features/portfolio/data/models/certificate_model.dart';
import 'package:connecthub/features/portfolio/data/repos/portfolio_repo.dart';
import 'package:connecthub/features/portfolio/data/repos/portfolio_repo_imp.dart';
import 'package:connecthub/core/services/portfolio_sync_service.dart';
import 'package:connecthub/features/portfolio/presentation/cubit/portfolio_state.dart';

class PortfolioCubit extends Cubit<PortfolioState> {
  final PortfolioRepo _repo;
  StreamSubscription<UserModel?>? _userSub;
  StreamSubscription<List<ProjectModel>>? _projectsSub;
  StreamSubscription<List<ExperienceModel>>? _experienceSub;
  StreamSubscription<List<EducationModel>>? _educationSub;
  StreamSubscription<List<CertificateModel>>? _certificatesSub;

  PortfolioCubit({PortfolioRepo? repo})
      : _repo = repo ?? PortfolioRepoImp(),
        super(PortfolioInitial());

  void loadPortfolio(String uid) {
    emit(PortfolioLoading());
    _cancelSubs();

    _userSub = _repo.getPortfolioStream(uid).listen(
      (user) {
        if (user == null) {
          emit(PortfolioError('Portfolio not found.'));
          return;
        }

        final current = state;
        if (current is PortfolioLoaded) {
          emit(current.copyWith(user: user));
        } else {
          emit(PortfolioLoaded(user: user));
        }
      },
      onError: (e) {
        emit(PortfolioError('Failed to load portfolio.'));
      },
    );

    // Prepare subcollections listeners
    _projectsSub = _repo.getProjectsStream(uid).listen((projects) {
      final current = state;
      if (current is PortfolioLoaded) {
        emit(current.copyWith(projects: projects));
      }
    }, onError: (_) {});

    _experienceSub = _repo.getExperienceStream(uid).listen((experience) {
      final current = state;
      if (current is PortfolioLoaded) {
        emit(current.copyWith(experience: experience));
      }
    }, onError: (_) {});

    _educationSub = _repo.getEducationStream(uid).listen((education) {
      final current = state;
      if (current is PortfolioLoaded) {
        emit(current.copyWith(education: education));
      }
    }, onError: (_) {});

    _certificatesSub = _repo.getCertificatesStream(uid).listen((certs) {
      final current = state;
      if (current is PortfolioLoaded) {
        emit(current.copyWith(certificates: certs));
      }
    }, onError: (_) {});
  }

  void loadProfile(String uid) => loadPortfolio(uid);

  Future<void> updatePortfolio({
    required String uid,
    String? headline,
    String? about,
    String? location,
    String? phone,
    SocialLinksModel? socialLinks,
    String? githubUsername,
    String? profileSlug,
    PortfolioSource? portfolioSource,
    bool? portfolioCompleted,
    int? portfolioVersion,
    SectionVisibilityModel? sectionVisibility,
  }) async {
    emit(PortfolioUpdating());
    try {
      await _repo.updatePortfolio(
        uid: uid,
        headline: headline,
        about: about,
        location: location,
        phone: phone,
        socialLinks: socialLinks,
        githubUsername: githubUsername,
        profileSlug: profileSlug,
        portfolioSource: portfolioSource,
        portfolioCompleted: portfolioCompleted,
        portfolioVersion: portfolioVersion,
        sectionVisibility: sectionVisibility,
      );
      emit(PortfolioUpdateSuccess());
      PortfolioSyncService().syncUserPortfolio(uid).ignore();
    } catch (e) {
      emit(PortfolioError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> updateProfile({
    required String uid,
    String? headline,
    String? about,
    String? location,
    String? phone,
    SocialLinksModel? socialLinks,
    String? githubUsername,
    String? profileSlug,
    PortfolioSource? portfolioSource,
    bool? portfolioCompleted,
    int? portfolioVersion,
    SectionVisibilityModel? sectionVisibility,
  }) =>
      updatePortfolio(
        uid: uid,
        headline: headline,
        about: about,
        location: location,
        phone: phone,
        socialLinks: socialLinks,
        githubUsername: githubUsername,
        profileSlug: profileSlug,
        portfolioSource: portfolioSource,
        portfolioCompleted: portfolioCompleted,
        portfolioVersion: portfolioVersion,
        sectionVisibility: sectionVisibility,
      );

  void _cancelSubs() {
    _userSub?.cancel();
    _projectsSub?.cancel();
    _experienceSub?.cancel();
    _educationSub?.cancel();
    _certificatesSub?.cancel();
  }

  @override
  Future<void> close() {
    _cancelSubs();
    return super.close();
  }
}
