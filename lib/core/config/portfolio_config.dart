import 'package:flutter/foundation.dart';

/// Central configuration for public portfolio websites.
/// All portfolio URLs must be generated from this single constant.
class PortfolioConfig {
  static const String _defaultHostedUrl = 'https://connecthub-57eb5.web.app';

  /// Base URL where portfolios are hosted.
  /// On local web in debug mode, automatically uses the current local origin.
  static String get baseUrl {
    if (kIsWeb && kDebugMode) {
      try {
        final origin = Uri.base.origin;
        if (origin.isNotEmpty && !origin.startsWith('null')) {
          return origin;
        }
      } catch (_) {}
    }
    return _defaultHostedUrl;
  }

  /// Generates the public portfolio URL for a given username or identifier.
  /// Format: {baseUrl}/#/portfolio/{username}
  static String buildUrl(String username) {
    final cleanBase = baseUrl.replaceAll(RegExp(r'/+$'), '');
    final cleanUsername = Uri.encodeComponent(username.trim());
    return '$cleanBase/#/portfolio/$cleanUsername';
  }
}
