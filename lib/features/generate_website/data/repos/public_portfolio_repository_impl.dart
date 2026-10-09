import 'package:connecthub/features/profile/data/models/user_model.dart';
import '../../domain/repos/public_portfolio_repository.dart';
import '../datasources/public_portfolio_remote_data_source.dart';
import '../models/public_portfolio_snapshot.dart';

class PublicPortfolioRepositoryImpl implements PublicPortfolioRepository {
  final PublicPortfolioRemoteDataSource _remoteDataSource;

  PublicPortfolioRepositoryImpl({
    PublicPortfolioRemoteDataSource? remoteDataSource,
  }) : _remoteDataSource = remoteDataSource ?? PublicPortfolioRemoteDataSourceImpl();

  @override
  Future<PublicPortfolioSnapshot> generatePortfolioWebsite({
    required String uid,
    UserModel? cachedUser,
  }) {
    return _remoteDataSource.generateAndPublishPortfolio(
      uid: uid,
      cachedUser: cachedUser,
    );
  }

  @override
  Future<PublicPortfolioSnapshot?> getPublicPortfolio(String? identifier) {
    return _remoteDataSource.getPublicPortfolio(identifier);
  }
}
