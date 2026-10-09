import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connecthub/features/profile/data/models/user_model.dart';
import '../../data/repos/public_portfolio_repository_impl.dart';
import '../../domain/usecases/generate_public_portfolio_use_case.dart';
import 'generate_website_state.dart';

class GenerateWebsiteCubit extends Cubit<GenerateWebsiteState> {
  final GeneratePublicPortfolioUseCase _generateUseCase;

  GenerateWebsiteCubit({
    GeneratePublicPortfolioUseCase? generateUseCase,
  })  : _generateUseCase = generateUseCase ??
            GeneratePublicPortfolioUseCase(PublicPortfolioRepositoryImpl()),
        super(const GenerateWebsiteInitial());

  Future<void> generateWebsite({
    required String uid,
    UserModel? cachedUser,
  }) async {
    emit(const GenerateWebsiteLoading());
    try {
      final snapshot = await _generateUseCase(
        uid: uid,
        cachedUser: cachedUser,
      );
      emit(GenerateWebsiteSuccess(
        snapshot: snapshot,
        publicUrl: snapshot.publicPortfolioUrl,
      ));
    } catch (e) {
      emit(GenerateWebsiteError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  void reset() {
    emit(const GenerateWebsiteInitial());
  }
}
