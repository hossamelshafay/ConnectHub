import '../repositories/web_portfolio_repository.dart';
import '../../models/portfolio_view_data.dart';

/// Clean Architecture Use Case: Loads dynamic portfolio data from Firebase/Firestore
/// through the WebPortfolioRepository with memory caching and error handling.
class LoadPortfolioUseCase {
  final WebPortfolioRepository repository;

  LoadPortfolioUseCase(this.repository);

  /// Executes the usecase for a given [identifier] (username or uid).
  Future<PortfolioViewData> call([String? identifier, bool forceRefresh = false]) {
    return repository.getPortfolio(identifier, forceRefresh: forceRefresh);
  }
}
