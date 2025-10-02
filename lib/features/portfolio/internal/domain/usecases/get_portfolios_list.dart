import '../entities/portfolio_list.dart';
import '../repositories/portfolio_repository.dart';
import '../../../../../core/utils/logger.dart';

/// Use case for getting portfolios list
class GetPortfoliosList {
  final PortfolioRepository _repository;

  const GetPortfoliosList(this._repository);

  /// Execute the use case
  Future<PortfolioList> call(String userId) async {
    AppLogger.methodEntry(
      'GetPortfoliosList.call',
      tag: 'GetPortfoliosList',
      params: {'userId': userId},
    );

    if (userId.isEmpty) {
      AppLogger.error(
        'User ID validation failed - empty userId',
        tag: 'GetPortfoliosList',
      );
      throw ArgumentError('User ID cannot be empty');
    }

    try {
      AppLogger.info(
        'Executing get portfolios list use case',
        tag: 'GetPortfoliosList',
      );

      final portfolioList = await _repository.getPortfoliosList(userId);

      AppLogger.info(
        'Portfolio list retrieved successfully - ${portfolioList.count} portfolios found',
        tag: 'GetPortfoliosList',
      );

      AppLogger.methodExit(
        'GetPortfoliosList.call',
        tag: 'GetPortfoliosList',
        result: 'success',
      );

      return portfolioList;
    } catch (error) {
      AppLogger.error(
        'Failed to execute GetPortfoliosList use case',
        tag: 'GetPortfoliosList',
        error: error,
        stackTrace: StackTrace.current,
      );

      AppLogger.methodExit(
        'GetPortfoliosList.call',
        tag: 'GetPortfoliosList',
        result: 'error',
      );

      rethrow;
    }
  }

  /// Get portfolios list with validation
  Future<PortfolioList> execute(String userId) async {
    return call(userId);
  }

  /// Check if user has any portfolios
  Future<bool> hasPortfolios(String userId) async {
    try {
      final portfolioList = await call(userId);
      return portfolioList.isNotEmpty;
    } catch (error) {
      AppLogger.error(
        'Failed to check if user has portfolios',
        tag: 'GetPortfoliosList',
        error: error,
      );
      return false;
    }
  }

  /// Get portfolio count for user
  Future<int> getPortfolioCount(String userId) async {
    try {
      final portfolioList = await call(userId);
      return portfolioList.count;
    } catch (error) {
      AppLogger.error(
        'Failed to get portfolio count',
        tag: 'GetPortfoliosList',
        error: error,
      );
      return 0;
    }
  }
}
