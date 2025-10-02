import '../entities/portfolio_analytics.dart';
import '../entities/portfolio_analytics_request.dart';
import '../repositories/portfolio_analytics_repository.dart';
import '../../../../../core/utils/logger.dart';

/// Use case for getting portfolio analytics
class GetPortfolioAnalytics {
  final PortfolioAnalyticsRepository _repository;

  const GetPortfolioAnalytics(this._repository);

  /// Execute the use case
  Future<PortfolioAnalytics> call(PortfolioAnalyticsRequest request) async {
    AppLogger.methodEntry(
      'GetPortfolioAnalytics.call',
      tag: 'GetPortfolioAnalytics',
      params: {'portfolioId': request.coreIdentifiers.portfolioId},
    );

    // Validate request
    _validateRequest(request);

    try {
      AppLogger.info(
        'Executing get portfolio analytics use case',
        tag: 'GetPortfolioAnalytics',
      );
      final result = await _repository.getPortfolioAnalytics(request);

      AppLogger.info(
        'Portfolio analytics use case completed successfully',
        tag: 'GetPortfolioAnalytics',
      );
      AppLogger.methodExit(
        'GetPortfolioAnalytics.call',
        tag: 'GetPortfolioAnalytics',
        result: 'success',
      );

      return result;
    } catch (e) {
      AppLogger.error(
        'Portfolio analytics use case failed',
        tag: 'GetPortfolioAnalytics',
        error: e,
        stackTrace: StackTrace.current,
      );
      AppLogger.methodExit(
        'GetPortfolioAnalytics.call',
        tag: 'GetPortfolioAnalytics',
        result: 'error',
      );
      rethrow;
    }
  }

  /// Get heatmap data only
  Future<Heatmap?> getHeatmapData(PortfolioAnalyticsRequest request) async {
    AppLogger.methodEntry(
      'GetPortfolioAnalytics.getHeatmapData',
      tag: 'GetPortfolioAnalytics',
      params: {'portfolioId': request.coreIdentifiers.portfolioId},
    );

    // Validate request and ensure heatmap is enabled
    _validateRequest(request);
    if (!request.featureToggles.includeHeatmap) {
      AppLogger.warning(
        'Heatmap feature is not enabled in request',
        tag: 'GetPortfolioAnalytics',
      );
      throw ArgumentError(
        'Heatmap feature must be enabled to fetch heatmap data',
      );
    }

    try {
      final result = await _repository.getHeatmapData(request);
      AppLogger.methodExit(
        'GetPortfolioAnalytics.getHeatmapData',
        tag: 'GetPortfolioAnalytics',
        result: 'success',
      );
      return result;
    } catch (e) {
      AppLogger.error(
        'Get heatmap data failed',
        tag: 'GetPortfolioAnalytics',
        error: e,
        stackTrace: StackTrace.current,
      );
      AppLogger.methodExit(
        'GetPortfolioAnalytics.getHeatmapData',
        tag: 'GetPortfolioAnalytics',
        result: 'error',
      );
      rethrow;
    }
  }

  /// Get movers data only
  Future<Movers?> getMoversData(PortfolioAnalyticsRequest request) async {
    AppLogger.methodEntry(
      'GetPortfolioAnalytics.getMoversData',
      tag: 'GetPortfolioAnalytics',
      params: {'portfolioId': request.coreIdentifiers.portfolioId},
    );

    // Validate request and ensure movers is enabled
    _validateRequest(request);
    if (!request.featureToggles.includeMovers) {
      AppLogger.warning(
        'Movers feature is not enabled in request',
        tag: 'GetPortfolioAnalytics',
      );
      throw ArgumentError(
        'Movers feature must be enabled to fetch movers data',
      );
    }

    try {
      final result = await _repository.getMoversData(request);
      AppLogger.methodExit(
        'GetPortfolioAnalytics.getMoversData',
        tag: 'GetPortfolioAnalytics',
        result: 'success',
      );
      return result;
    } catch (e) {
      AppLogger.error(
        'Get movers data failed',
        tag: 'GetPortfolioAnalytics',
        error: e,
        stackTrace: StackTrace.current,
      );
      AppLogger.methodExit(
        'GetPortfolioAnalytics.getMoversData',
        tag: 'GetPortfolioAnalytics',
        result: 'error',
      );
      rethrow;
    }
  }

  /// Get sector allocation data only
  Future<SectorAllocation?> getSectorAllocation(
    PortfolioAnalyticsRequest request,
  ) async {
    AppLogger.methodEntry(
      'GetPortfolioAnalytics.getSectorAllocation',
      tag: 'GetPortfolioAnalytics',
      params: {'portfolioId': request.coreIdentifiers.portfolioId},
    );

    // Validate request and ensure sector allocation is enabled
    _validateRequest(request);
    if (!request.featureToggles.includeSectorAllocation) {
      AppLogger.warning(
        'Sector allocation feature is not enabled in request',
        tag: 'GetPortfolioAnalytics',
      );
      throw ArgumentError(
        'Sector allocation feature must be enabled to fetch sector allocation data',
      );
    }

    try {
      final result = await _repository.getSectorAllocation(request);
      AppLogger.methodExit(
        'GetPortfolioAnalytics.getSectorAllocation',
        tag: 'GetPortfolioAnalytics',
        result: 'success',
      );
      return result;
    } catch (e) {
      AppLogger.error(
        'Get sector allocation data failed',
        tag: 'GetPortfolioAnalytics',
        error: e,
        stackTrace: StackTrace.current,
      );
      AppLogger.methodExit(
        'GetPortfolioAnalytics.getSectorAllocation',
        tag: 'GetPortfolioAnalytics',
        result: 'error',
      );
      rethrow;
    }
  }

  /// Get market cap allocation data only
  Future<MarketCapAllocation?> getMarketCapAllocation(
    PortfolioAnalyticsRequest request,
  ) async {
    AppLogger.methodEntry(
      'GetPortfolioAnalytics.getMarketCapAllocation',
      tag: 'GetPortfolioAnalytics',
      params: {'portfolioId': request.coreIdentifiers.portfolioId},
    );

    // Validate request and ensure market cap allocation is enabled
    _validateRequest(request);
    if (!request.featureToggles.includeMarketCapAllocation) {
      AppLogger.warning(
        'Market cap allocation feature is not enabled in request',
        tag: 'GetPortfolioAnalytics',
      );
      throw ArgumentError(
        'Market cap allocation feature must be enabled to fetch market cap allocation data',
      );
    }

    try {
      final result = await _repository.getMarketCapAllocation(request);
      AppLogger.methodExit(
        'GetPortfolioAnalytics.getMarketCapAllocation',
        tag: 'GetPortfolioAnalytics',
        result: 'success',
      );
      return result;
    } catch (e) {
      AppLogger.error(
        'Get market cap allocation data failed',
        tag: 'GetPortfolioAnalytics',
        error: e,
        stackTrace: StackTrace.current,
      );
      AppLogger.methodExit(
        'GetPortfolioAnalytics.getMarketCapAllocation',
        tag: 'GetPortfolioAnalytics',
        result: 'error',
      );
      rethrow;
    }
  }

  /// Validate the analytics request
  void _validateRequest(PortfolioAnalyticsRequest request) {
    if (request.coreIdentifiers.portfolioId.isEmpty) {
      AppLogger.error(
        'Portfolio ID validation failed - empty portfolioId',
        tag: 'GetPortfolioAnalytics',
      );
      throw ArgumentError('Portfolio ID cannot be empty');
    }

    // Validate pagination parameters
    if (request.pagination.page < 1) {
      AppLogger.error(
        'Pagination validation failed - invalid page number',
        tag: 'GetPortfolioAnalytics',
      );
      throw ArgumentError('Page number must be greater than 0');
    }

    if (request.pagination.size < 1 || request.pagination.size > 1000) {
      AppLogger.error(
        'Pagination validation failed - invalid page size',
        tag: 'GetPortfolioAnalytics',
      );
      throw ArgumentError('Page size must be between 1 and 1000');
    }

    // Validate feature configuration
    if (request.featureConfiguration.moversLimit < 1 ||
        request.featureConfiguration.moversLimit > 100) {
      AppLogger.error(
        'Feature configuration validation failed - invalid movers limit',
        tag: 'GetPortfolioAnalytics',
      );
      throw ArgumentError('Movers limit must be between 1 and 100');
    }

    AppLogger.info('Request validation passed', tag: 'GetPortfolioAnalytics');
  }
}
