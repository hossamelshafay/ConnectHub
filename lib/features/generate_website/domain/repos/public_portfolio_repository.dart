import 'package:connecthub/features/profile/data/models/user_model.dart';
import '../../data/models/public_portfolio_snapshot.dart';

abstract class PublicPortfolioRepository {
  /// Generates or updates the public portfolio website snapshot in Firestore.
  Future<PublicPortfolioSnapshot> generatePortfolioWebsite({
    required String uid,
    UserModel? cachedUser,
  });

  /// Fetches the published public portfolio website snapshot.
  Future<PublicPortfolioSnapshot?> getPublicPortfolio(String? identifier);
}
