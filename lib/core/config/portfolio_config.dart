/// Central configuration for public portfolio websites.
/// All portfolio URLs must be generated from this single constant.
class PortfolioConfig {
  /// Base URL where portfolios are hosted.
  static const String baseUrl = 'https://connecthub-57eb5.web.app';

  /// Generates the public portfolio URL for a given username or identifier.
  /// Format: https://connecthub-57eb5.web.app/#/portfolio/{username}
  static String buildUrl(String username) {
    final cleanBase = baseUrl.replaceAll(RegExp(r'/+$'), '');
    final cleanUsername = Uri.encodeComponent(username.trim());
    return '$cleanBase/#/portfolio/$cleanUsername';
  }
}
