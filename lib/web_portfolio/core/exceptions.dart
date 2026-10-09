/// Base exception for web portfolio errors.
abstract class WebPortfolioException implements Exception {
  final String message;
  const WebPortfolioException(this.message);

  @override
  String toString() => message;
}

/// Thrown when no user document or username slug matches the requested portfolio.
class PortfolioNotFoundException extends WebPortfolioException {
  final String identifier;
  const PortfolioNotFoundException(this.identifier)
      : super('Portfolio for "$identifier" could not be found.');
}

/// Thrown when network connection is offline or unreachable.
class PortfolioOfflineException extends WebPortfolioException {
  const PortfolioOfflineException([super.message = 'Network connection unavailable. Please check your internet connection.']);
}

/// Thrown when Firestore or server encounters an unexpected error.
class PortfolioServerException extends WebPortfolioException {
  final dynamic originalError;
  const PortfolioServerException(super.message, [this.originalError]);
}
