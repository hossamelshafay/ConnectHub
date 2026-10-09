import 'package:connecthub/features/profile/data/models/user_model.dart';
import '../../data/models/public_portfolio_snapshot.dart';
import '../repos/public_portfolio_repository.dart';

class GeneratePublicPortfolioUseCase {
  final PublicPortfolioRepository _repository;

  GeneratePublicPortfolioUseCase(this._repository);

  Future<PublicPortfolioSnapshot> call({
    required String uid,
    UserModel? cachedUser,
  }) {
    return _repository.generatePortfolioWebsite(
      uid: uid,
      cachedUser: cachedUser,
    );
  }
}
