import '../../models/portfolio_view_data.dart';

/// Domain contract for managing Web Portfolio data retrieval and caching.
abstract class WebPortfolioRepository {
  /// Loads a full [PortfolioViewData] for the given [identifier] (username or uid).
  ///
  /// Leverages in-memory caching to prevent duplicate Firestore requests on widget rebuilds.
  /// When [forceRefresh] is true, the cache is bypassed to retrieve the latest public document.
  Future<PortfolioViewData> getPortfolio(String? identifier, {bool forceRefresh = false});

  /// Clears the in-memory cache to force a fresh remote fetch.
  void clearCache();
}
