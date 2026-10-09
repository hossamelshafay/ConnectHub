import 'package:flutter/material.dart';
import 'pages/portfolio_page.dart';

/// Prepares clean, SEO-ready and scalable routing for web portfolio URLs:
/// - /#/portfolio/{username} (e.g. /#/portfolio/shafay)
/// - /#/portfolio/{uid}      (e.g. /#/portfolio/a8dJ92kLmNQ...)
/// - /portfolio/{username}
/// - /portfolio/{uid}
/// - / (defaults to featured/authenticated web portfolio)
class PortfolioRouter {
  PortfolioRouter._();

  static const String rootRoute = '/';
  static const String portfolioPrefix = '/portfolio';

  /// Generates routes for the Web Portfolio experience.
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final rawName = settings.name ?? '/';

    // Normalize hash fragments (e.g. "#/portfolio/shafay" -> "/portfolio/shafay")
    String effectivePath = rawName;
    if (effectivePath.contains('#')) {
      final parts = effectivePath.split('#');
      effectivePath = parts.length > 1 ? parts[1] : parts[0];
    }
    if (!effectivePath.startsWith('/')) {
      effectivePath = '/$effectivePath';
    }

    final uri = Uri.tryParse(effectivePath);
    if (uri == null) {
      return _buildRoute(const WebPortfolioPage());
    }

    final pathSegments = uri.pathSegments;

    // Matches /portfolio/:identifier (username or uid)
    if (pathSegments.isNotEmpty && pathSegments[0] == 'portfolio') {
      final identifier = pathSegments.length > 1 && pathSegments[1].trim().isNotEmpty
          ? pathSegments[1].trim()
          : null;
      return _buildRoute(WebPortfolioPage(identifier: identifier));
    }

    // Default root route
    if (uri.path == '/' || uri.path.isEmpty) {
      return _buildRoute(const WebPortfolioPage());
    }

    // Direct slug route e.g. /:username
    if (pathSegments.length == 1 && pathSegments[0].isNotEmpty) {
      return _buildRoute(WebPortfolioPage(identifier: pathSegments[0].trim()));
    }

    return null;
  }

  static PageRoute _buildRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }
}
