import 'portfolio_config.dart';

/// Application configuration and environment constants.
class AppConfig {
  /// Default domain fallback for public portfolio websites.
  /// Driven by [PortfolioConfig.baseUrl].
  static const String defaultPortfolioDomain = PortfolioConfig.baseUrl;

  /// Resolves the effective portfolio domain from environment or default fallback.
  static String get portfolioDomain {
    const fromEnv = String.fromEnvironment('PORTFOLIO_DOMAIN');
    if (fromEnv.isNotEmpty) return fromEnv;
    return PortfolioConfig.baseUrl;
  }

  /// Builds a permanent public URL for a given username or UID.
  /// Format: https://connecthub-57eb5.web.app/#/portfolio/{username}
  static String buildPortfolioUrl(String identifier) {
    return PortfolioConfig.buildUrl(identifier);
  }
}
