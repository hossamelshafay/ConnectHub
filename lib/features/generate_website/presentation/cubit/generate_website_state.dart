import '../../data/models/public_portfolio_snapshot.dart';

abstract class GenerateWebsiteState {
  const GenerateWebsiteState();
}

class GenerateWebsiteInitial extends GenerateWebsiteState {
  const GenerateWebsiteInitial();
}

class GenerateWebsiteLoading extends GenerateWebsiteState {
  const GenerateWebsiteLoading();
}

class GenerateWebsiteSuccess extends GenerateWebsiteState {
  final PublicPortfolioSnapshot snapshot;
  final String publicUrl;

  const GenerateWebsiteSuccess({
    required this.snapshot,
    required this.publicUrl,
  });
}

class GenerateWebsiteError extends GenerateWebsiteState {
  final String message;

  const GenerateWebsiteError(this.message);
}
