import '../entities/portfolio_holding.dart';
import '../repositories/portfolio_repository.dart';
import '../../../../../core/utils/logger.dart';

/// Use case for getting portfolio holdings
class GetPortfolioHoldings {
  final PortfolioRepository _repository;

  const GetPortfolioHoldings(this._repository);

  /// Execute the use case
  Future<PortfolioHoldings> call(String userId, [String? portfolioId]) async {
    AppLogger.methodEntry(
      'GetPortfolioHoldings.call',
      tag: 'GetPortfolioHoldings',
      params: {'userId': userId, 'portfolioId': portfolioId},
    );

    if (userId.isEmpty) {
      AppLogger.error(
        'User ID validation failed - empty userId',
        tag: 'GetPortfolioHoldings',
      );
      throw ArgumentError('User ID cannot be empty');
    }

    try {
      AppLogger.info(
        'Executing get portfolio holdings use case',
        tag: 'GetPortfolioHoldings',
      );

      // Call the appropriate repository method based on whether portfolioId is provided
      final result = portfolioId != null && portfolioId.isNotEmpty
          ? await _repository.getPortfolioHoldingsById(userId, portfolioId)
          : await _repository.getPortfolioHoldings(userId);

      AppLogger.info(
        'Portfolio holdings use case completed successfully',
        tag: 'GetPortfolioHoldings',
      );
      AppLogger.methodExit(
        'GetPortfolioHoldings.call',
        tag: 'GetPortfolioHoldings',
        result: 'success',
      );

      return result;
    } catch (e) {
      AppLogger.error(
        'Portfolio holdings use case failed',
        tag: 'GetPortfolioHoldings',
        error: e,
        stackTrace: StackTrace.current,
      );
      AppLogger.methodExit(
        'GetPortfolioHoldings.call',
        tag: 'GetPortfolioHoldings',
        result: 'error',
      );
      rethrow;
    }
  }

  /// Get portfolio holdings for user only (legacy method)
  Future<PortfolioHoldings> callForUser(String userId) async {
    return call(userId);
  }

  /// Get portfolio holdings for specific portfolio
  Future<PortfolioHoldings> callForPortfolio(
    String userId,
    String portfolioId,
  ) async {
    return call(userId, portfolioId);
  }

  /// Execute with stream for real-time updates
  Stream<PortfolioHoldings> watchHoldings(String userId) {
    AppLogger.methodEntry(
      'GetPortfolioHoldings.watchHoldings',
      tag: 'GetPortfolioHoldings',
      params: {'userId': userId},
    );

    if (userId.isEmpty) {
      AppLogger.error(
        'User ID validation failed - empty userId for stream',
        tag: 'GetPortfolioHoldings',
      );
      throw ArgumentError('User ID cannot be empty');
    }

    AppLogger.info(
      'Starting portfolio holdings stream',
      tag: 'GetPortfolioHoldings',
    );
    return _repository.watchPortfolioHoldings(userId);
  }
}
