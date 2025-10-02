import '../entities/portfolio_summary.dart';
import '../repositories/portfolio_repository.dart';
import '../../../../../core/utils/logger.dart';

/// Use case for getting portfolio summary
class GetPortfolioSummary {
  final PortfolioRepository _repository;

  const GetPortfolioSummary(this._repository);

  /// Execute the use case
  Future<PortfolioSummary> call(String userId, [String? portfolioId]) async {
    AppLogger.methodEntry(
      'GetPortfolioSummary.call',
      tag: 'GetPortfolioSummary',
      params: {'userId': userId, 'portfolioId': portfolioId},
    );

    if (userId.isEmpty) {
      AppLogger.error(
        'User ID validation failed - empty userId',
        tag: 'GetPortfolioSummary',
      );
      throw ArgumentError('User ID cannot be empty');
    }

    try {
      AppLogger.info(
        'Executing get portfolio summary use case',
        tag: 'GetPortfolioSummary',
      );

      // Call the appropriate repository method based on whether portfolioId is provided
      final result = portfolioId != null && portfolioId.isNotEmpty
          ? await _repository.getPortfolioSummaryById(userId, portfolioId)
          : await _repository.getPortfolioSummary(userId);

      AppLogger.info(
        'Portfolio summary use case completed successfully',
        tag: 'GetPortfolioSummary',
      );
      AppLogger.methodExit(
        'GetPortfolioSummary.call',
        tag: 'GetPortfolioSummary',
        result: 'success',
      );

      return result;
    } catch (e) {
      AppLogger.error(
        'Portfolio summary use case failed',
        tag: 'GetPortfolioSummary',
        error: e,
        stackTrace: StackTrace.current,
      );
      AppLogger.methodExit(
        'GetPortfolioSummary.call',
        tag: 'GetPortfolioSummary',
        result: 'error',
      );
      rethrow;
    }
  }

  /// Get portfolio summary for user only (legacy method)
  Future<PortfolioSummary> callForUser(String userId) async {
    return call(userId);
  }

  /// Get portfolio summary for specific portfolio
  Future<PortfolioSummary> callForPortfolio(
    String userId,
    String portfolioId,
  ) async {
    return call(userId, portfolioId);
  }

  /// Execute with stream for real-time updates
  Stream<PortfolioSummary> watchSummary(String userId) {
    if (userId.isEmpty) {
      throw ArgumentError('User ID cannot be empty');
    }

    return _repository.watchPortfolioSummary(userId);
  }
}
