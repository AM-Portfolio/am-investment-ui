import '../domain/entities/portfolio_holding.dart';
import '../domain/entities/portfolio_summary.dart';
import '../domain/entities/portfolio_list.dart';
import '../domain/usecases/get_portfolio_holdings.dart';
import '../domain/usecases/get_portfolio_summary.dart';
import '../domain/usecases/get_portfolios_list.dart';
import '../../../../core/utils/logger.dart';

/// Portfolio orchestration service for core workflows.
///
/// Combines core use cases and coordinates essential operations like:
/// - Portfolio data retrieval
/// - Summary information access
/// - Holdings management
///
/// This service acts as a facade that combines core use cases
/// to perform essential portfolio operations.
class PortfolioService {
  final GetPortfolioHoldings _getPortfolioHoldings;
  final GetPortfolioSummary _getPortfolioSummary;
  final GetPortfoliosList _getPortfoliosList;

  const PortfolioService(
    this._getPortfolioHoldings,
    this._getPortfolioSummary,
    this._getPortfoliosList,
  );

  /// Retrieves portfolio holdings for the specified user
  /// Returns holdings data or throws an exception if retrieval fails
  Future<PortfolioHoldings> getPortfolioHoldings(String userId) async {
    AppLogger.methodEntry(
      'getPortfolioHoldings',
      tag: 'PortfolioService',
      params: {'userId': userId},
    );

    try {
      AppLogger.info('Getting portfolio holdings', tag: 'PortfolioService');
      final holdings = await _getPortfolioHoldings(userId);

      AppLogger.info(
        'Portfolio holdings retrieved successfully',
        tag: 'PortfolioService',
      );
      AppLogger.methodExit(
        'getPortfolioHoldings',
        tag: 'PortfolioService',
        result: 'success',
      );

      return holdings;
    } catch (error) {
      AppLogger.error(
        'Failed to get portfolio holdings',
        tag: 'PortfolioService',
        error: error,
        stackTrace: StackTrace.current,
      );
      AppLogger.methodExit(
        'getPortfolioHoldings',
        tag: 'PortfolioService',
        result: 'error',
      );
      rethrow;
    }
  }

  /// Retrieves portfolio holdings for the specified user and portfolio
  /// Returns holdings data or throws an exception if retrieval fails
  Future<PortfolioHoldings> getPortfolioHoldingsById(
    String userId,
    String portfolioId,
  ) async {
    AppLogger.methodEntry(
      'getPortfolioHoldingsById',
      tag: 'PortfolioService',
      params: {'userId': userId, 'portfolioId': portfolioId},
    );

    try {
      AppLogger.info(
        'Getting portfolio holdings by ID',
        tag: 'PortfolioService',
      );
      final holdings = await _getPortfolioHoldings(userId, portfolioId);

      AppLogger.info(
        'Portfolio holdings retrieved successfully by ID',
        tag: 'PortfolioService',
      );
      AppLogger.methodExit(
        'getPortfolioHoldingsById',
        tag: 'PortfolioService',
        result: 'success',
      );

      return holdings;
    } catch (error) {
      AppLogger.error(
        'Failed to get portfolio holdings by ID',
        tag: 'PortfolioService',
        error: error,
        stackTrace: StackTrace.current,
      );
      AppLogger.methodExit(
        'getPortfolioHoldingsById',
        tag: 'PortfolioService',
        result: 'error',
      );
      rethrow;
    }
  }

  /// Retrieves portfolio summary for the specified user
  /// Returns summary data or throws an exception if retrieval fails
  Future<PortfolioSummary> getPortfolioSummary(String userId) async {
    AppLogger.methodEntry(
      'getPortfolioSummary',
      tag: 'PortfolioService',
      params: {'userId': userId},
    );

    try {
      AppLogger.info('Getting portfolio summary', tag: 'PortfolioService');
      final summary = await _getPortfolioSummary(userId);

      AppLogger.info(
        'Portfolio summary retrieved successfully',
        tag: 'PortfolioService',
      );
      AppLogger.methodExit(
        'getPortfolioSummary',
        tag: 'PortfolioService',
        result: 'success',
      );

      return summary;
    } catch (error) {
      AppLogger.error(
        'Failed to get portfolio summary',
        tag: 'PortfolioService',
        error: error,
        stackTrace: StackTrace.current,
      );
      AppLogger.methodExit(
        'getPortfolioSummary',
        tag: 'PortfolioService',
        result: 'error',
      );
      rethrow;
    }
  }

  /// Retrieves portfolio summary for the specified user and portfolio
  /// Returns summary data or throws an exception if retrieval fails
  Future<PortfolioSummary> getPortfolioSummaryById(
    String userId,
    String portfolioId,
  ) async {
    AppLogger.methodEntry(
      'getPortfolioSummaryById',
      tag: 'PortfolioService',
      params: {'userId': userId, 'portfolioId': portfolioId},
    );

    try {
      AppLogger.info(
        'Getting portfolio summary by ID',
        tag: 'PortfolioService',
      );
      final summary = await _getPortfolioSummary(userId, portfolioId);

      AppLogger.info(
        'Portfolio summary retrieved successfully by ID',
        tag: 'PortfolioService',
      );
      AppLogger.methodExit(
        'getPortfolioSummaryById',
        tag: 'PortfolioService',
        result: 'success',
      );

      return summary;
    } catch (error) {
      AppLogger.error(
        'Failed to get portfolio summary by ID',
        tag: 'PortfolioService',
        error: error,
        stackTrace: StackTrace.current,
      );
      AppLogger.methodExit(
        'getPortfolioSummaryById',
        tag: 'PortfolioService',
        result: 'error',
      );
      rethrow;
    }
  }

  /// Retrieves portfolios list for the specified user
  /// Returns portfolio list data or throws an exception if retrieval fails
  Future<PortfolioList> getPortfoliosList(String userId) async {
    AppLogger.methodEntry(
      'getPortfoliosList',
      tag: 'PortfolioService',
      params: {'userId': userId},
    );

    try {
      AppLogger.info('Getting portfolios list', tag: 'PortfolioService');
      final portfolioList = await _getPortfoliosList(userId);

      AppLogger.info(
        'Portfolios list retrieved successfully',
        tag: 'PortfolioService',
      );
      AppLogger.methodExit(
        'getPortfoliosList',
        tag: 'PortfolioService',
        result: 'success',
      );

      return portfolioList;
    } catch (error) {
      AppLogger.error(
        'Failed to get portfolios list',
        tag: 'PortfolioService',
        error: error,
        stackTrace: StackTrace.current,
      );
      AppLogger.methodExit(
        'getPortfoliosList',
        tag: 'PortfolioService',
        result: 'error',
      );
      rethrow;
    }
  }

  /// Validates basic portfolio data consistency
  /// Returns true if portfolio data appears consistent
  Future<bool> validatePortfolioConsistency(String userId) async {
    try {
      final results = await Future.wait([
        _getPortfolioHoldings(userId),
        _getPortfolioSummary(userId),
      ]);

      // Basic validation - can be expanded when freezed code is generated
      // For now, just ensure we can retrieve both holdings and summary
      return results.isNotEmpty;
    } catch (error) {
      return false;
    }
  }
}
