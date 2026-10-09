/// Application configuration and environment constants.
class AppConfig {
  /// Default domain fallback for public portfolio websites.
  /// Can be overridden at build time via `--dart-define=PORTFOLIO_DOMAIN=https://yourdomain.com`
  static const String defaultPortfolioDomain = 'https://connecthub-57eb5.web.app';

  /// Resolves the effective portfolio domain from environment or default fallback.
  static String get portfolioDomain {
    const fromEnv = String.fromEnvironment('PORTFOLIO_DOMAIN');
    if (fromEnv.isNotEmpty) return fromEnv;
    return defaultPortfolioDomain;
  }

  /// Builds a permanent public URL for a given username or UID.
  /// Format: https://DOMAIN/#/portfolio/{username}
  static String buildPortfolioUrl(String identifier) {
    final cleanDomain = portfolioDomain.replaceAll(RegExp(r'/+$'), '');
    final cleanIdentifier = Uri.encodeComponent(identifier.trim());
    return '$cleanDomain/#/portfolio/$cleanIdentifier';
  }
}
