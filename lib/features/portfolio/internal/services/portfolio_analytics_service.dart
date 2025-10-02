import '../domain/entities/portfolio_analytics.dart';
import '../domain/entities/portfolio_analytics_request.dart';
import '../domain/usecases/get_portfolio_analytics.dart';
import '../data/mappers/portfolio_analytics_mapper.dart';
import '../../../../core/utils/logger.dart';

/// Portfolio analytics orchestration service for comprehensive data workflows.
///
/// Combines analytics use cases and coordinates complex operations like:
/// - Portfolio analytics data retrieval
/// - Heatmap visualization data
/// - Market movers analysis
/// - Sector and market cap allocation insights
///
/// This service acts as a facade that combines analytics use cases
/// to perform comprehensive portfolio analysis operations.
class PortfolioAnalyticsService {
  final GetPortfolioAnalytics _getPortfolioAnalytics;

  const PortfolioAnalyticsService(this._getPortfolioAnalytics);

  /// Retrieves comprehensive portfolio analytics for the specified portfolio
  /// Returns complete analytics data or throws an exception if retrieval fails
  Future<PortfolioAnalytics> getPortfolioAnalytics(
    PortfolioAnalyticsRequest request,
  ) async {
    AppLogger.methodEntry(
      'getPortfolioAnalytics',
      tag: 'PortfolioAnalyticsService',
      params: {'portfolioId': request.coreIdentifiers.portfolioId},
    );

    try {
      AppLogger.info(
        'Getting comprehensive portfolio analytics',
        tag: 'PortfolioAnalyticsService',
      );
      final analytics = await _getPortfolioAnalytics(request);

      AppLogger.info(
        'Portfolio analytics retrieved successfully',
        tag: 'PortfolioAnalyticsService',
      );
      AppLogger.methodExit(
        'getPortfolioAnalytics',
        tag: 'PortfolioAnalyticsService',
        result: 'success',
      );

      return analytics;
    } catch (error) {
      AppLogger.error(
        'Failed to get portfolio analytics',
        tag: 'PortfolioAnalyticsService',
        error: error,
        stackTrace: StackTrace.current,
      );
      AppLogger.methodExit(
        'getPortfolioAnalytics',
        tag: 'PortfolioAnalyticsService',
        result: 'error',
      );
      rethrow;
    }
  }

  /// Retrieves portfolio analytics with default configuration
  /// Convenience method for getting analytics with standard settings
  Future<PortfolioAnalytics> getPortfolioAnalyticsWithDefaults(
    String portfolioId,
  ) async {
    AppLogger.methodEntry(
      'getPortfolioAnalyticsWithDefaults',
      tag: 'PortfolioAnalyticsService',
      params: {'portfolioId': portfolioId},
    );

    try {
      // Create default request with all features enabled
      final request = PortfolioAnalyticsMapper.createDefaultRequest(
        portfolioId,
      );

      AppLogger.info(
        'Getting portfolio analytics with default configuration',
        tag: 'PortfolioAnalyticsService',
      );
      final analytics = await _getPortfolioAnalytics(request);

      AppLogger.info(
        'Portfolio analytics with defaults retrieved successfully',
        tag: 'PortfolioAnalyticsService',
      );
      AppLogger.methodExit(
        'getPortfolioAnalyticsWithDefaults',
        tag: 'PortfolioAnalyticsService',
        result: 'success',
      );

      return analytics;
    } catch (error) {
      AppLogger.error(
        'Failed to get portfolio analytics with defaults',
        tag: 'PortfolioAnalyticsService',
        error: error,
        stackTrace: StackTrace.current,
      );
      AppLogger.methodExit(
        'getPortfolioAnalyticsWithDefaults',
        tag: 'PortfolioAnalyticsService',
        result: 'error',
      );
      rethrow;
    }
  }

  /// Retrieves only heatmap data for portfolio visualization
  /// Optimized method for getting visualization data only
  Future<Heatmap?> getPortfolioHeatmap(String portfolioId) async {
    AppLogger.methodEntry(
      'getPortfolioHeatmap',
      tag: 'PortfolioAnalyticsService',
      params: {'portfolioId': portfolioId},
    );

    try {
      // Create request with only heatmap enabled
      final request = _createHeatmapOnlyRequest(portfolioId);

      AppLogger.info(
        'Getting portfolio heatmap data',
        tag: 'PortfolioAnalyticsService',
      );
      final heatmap = await _getPortfolioAnalytics.getHeatmapData(request);

      AppLogger.info(
        'Portfolio heatmap retrieved successfully',
        tag: 'PortfolioAnalyticsService',
      );
      AppLogger.methodExit(
        'getPortfolioHeatmap',
        tag: 'PortfolioAnalyticsService',
        result: 'success',
      );

      return heatmap;
    } catch (error) {
      AppLogger.error(
        'Failed to get portfolio heatmap',
        tag: 'PortfolioAnalyticsService',
        error: error,
        stackTrace: StackTrace.current,
      );
      AppLogger.methodExit(
        'getPortfolioHeatmap',
        tag: 'PortfolioAnalyticsService',
        result: 'error',
      );
      rethrow;
    }
  }

  /// Retrieves only market movers data
  /// Optimized method for getting gainers and losers data only
  Future<Movers?> getPortfolioMovers(
    String portfolioId, {
    int limit = 10,
  }) async {
    AppLogger.methodEntry(
      'getPortfolioMovers',
      tag: 'PortfolioAnalyticsService',
      params: {'portfolioId': portfolioId, 'limit': limit},
    );

    try {
      // Create request with only movers enabled
      final request = _createMoversOnlyRequest(portfolioId, limit: limit);

      AppLogger.info(
        'Getting portfolio movers data',
        tag: 'PortfolioAnalyticsService',
      );
      final movers = await _getPortfolioAnalytics.getMoversData(request);

      AppLogger.info(
        'Portfolio movers retrieved successfully',
        tag: 'PortfolioAnalyticsService',
      );
      AppLogger.methodExit(
        'getPortfolioMovers',
        tag: 'PortfolioAnalyticsService',
        result: 'success',
      );

      return movers;
    } catch (error) {
      AppLogger.error(
        'Failed to get portfolio movers',
        tag: 'PortfolioAnalyticsService',
        error: error,
        stackTrace: StackTrace.current,
      );
      AppLogger.methodExit(
        'getPortfolioMovers',
        tag: 'PortfolioAnalyticsService',
        result: 'error',
      );
      rethrow;
    }
  }

  /// Retrieves comprehensive allocation data (sector + market cap)
  /// Convenient method for getting both allocation types in one call
  Future<AllocationData> getPortfolioAllocations(String portfolioId) async {
    AppLogger.methodEntry(
      'getPortfolioAllocations',
      tag: 'PortfolioAnalyticsService',
      params: {'portfolioId': portfolioId},
    );

    try {
      // Create request with allocation features enabled
      final request = _createAllocationOnlyRequest(portfolioId);

      AppLogger.info(
        'Getting portfolio allocation data',
        tag: 'PortfolioAnalyticsService',
      );

      // Get both allocation types
      final results = await Future.wait([
        _getPortfolioAnalytics.getSectorAllocation(request),
        _getPortfolioAnalytics.getMarketCapAllocation(request),
      ]);

      final allocationData = AllocationData(
        sectorAllocation: results[0] as SectorAllocation?,
        marketCapAllocation: results[1] as MarketCapAllocation?,
      );

      AppLogger.info(
        'Portfolio allocations retrieved successfully',
        tag: 'PortfolioAnalyticsService',
      );
      AppLogger.methodExit(
        'getPortfolioAllocations',
        tag: 'PortfolioAnalyticsService',
        result: 'success',
      );

      return allocationData;
    } catch (error) {
      AppLogger.error(
        'Failed to get portfolio allocations',
        tag: 'PortfolioAnalyticsService',
        error: error,
        stackTrace: StackTrace.current,
      );
      AppLogger.methodExit(
        'getPortfolioAllocations',
        tag: 'PortfolioAnalyticsService',
        result: 'error',
      );
      rethrow;
    }
  }

  /// Validates portfolio analytics data completeness
  /// Returns true if all requested analytics data is available and valid
  Future<bool> validateAnalyticsDataCompleteness(
    PortfolioAnalyticsRequest request,
  ) async {
    AppLogger.methodEntry(
      'validateAnalyticsDataCompleteness',
      tag: 'PortfolioAnalyticsService',
      params: {'portfolioId': request.coreIdentifiers.portfolioId},
    );

    try {
      final analytics = await _getPortfolioAnalytics(request);

      // Check if requested features have data
      bool isComplete = true;

      if (request.featureToggles.includeHeatmap &&
          analytics.analytics.heatmap == null) {
        AppLogger.warning(
          'Heatmap data missing despite being requested',
          tag: 'PortfolioAnalyticsService',
        );
        isComplete = false;
      }

      if (request.featureToggles.includeMovers &&
          analytics.analytics.movers == null) {
        AppLogger.warning(
          'Movers data missing despite being requested',
          tag: 'PortfolioAnalyticsService',
        );
        isComplete = false;
      }

      if (request.featureToggles.includeSectorAllocation &&
          analytics.analytics.sectorAllocation == null) {
        AppLogger.warning(
          'Sector allocation data missing despite being requested',
          tag: 'PortfolioAnalyticsService',
        );
        isComplete = false;
      }

      if (request.featureToggles.includeMarketCapAllocation &&
          analytics.analytics.marketCapAllocation == null) {
        AppLogger.warning(
          'Market cap allocation data missing despite being requested',
          tag: 'PortfolioAnalyticsService',
        );
        isComplete = false;
      }

      AppLogger.info(
        'Analytics data completeness validation completed: $isComplete',
        tag: 'PortfolioAnalyticsService',
      );
      AppLogger.methodExit(
        'validateAnalyticsDataCompleteness',
        tag: 'PortfolioAnalyticsService',
        result: isComplete ? 'complete' : 'incomplete',
      );

      return isComplete;
    } catch (error) {
      AppLogger.error(
        'Failed to validate analytics data completeness',
        tag: 'PortfolioAnalyticsService',
        error: error,
        stackTrace: StackTrace.current,
      );
      AppLogger.methodExit(
        'validateAnalyticsDataCompleteness',
        tag: 'PortfolioAnalyticsService',
        result: 'error',
      );
      return false;
    }
  }

  /// Creates a request with only heatmap feature enabled
  PortfolioAnalyticsRequest _createHeatmapOnlyRequest(String portfolioId) {
    return PortfolioAnalyticsRequest(
      coreIdentifiers: CoreIdentifiers(portfolioId: portfolioId),
      featureToggles: const FeatureToggles(
        includeHeatmap: true,
        includeMovers: false,
        includeSectorAllocation: false,
        includeMarketCapAllocation: false,
      ),
      featureConfiguration: const FeatureConfiguration(moversLimit: 10),
      pagination: const Pagination(
        page: 1,
        size: 50,
        sortBy: 'performance',
        sortDirection: 'desc',
        returnAllData: false,
      ),
    );
  }

  /// Creates a request with only movers feature enabled
  PortfolioAnalyticsRequest _createMoversOnlyRequest(
    String portfolioId, {
    int limit = 10,
  }) {
    return PortfolioAnalyticsRequest(
      coreIdentifiers: CoreIdentifiers(portfolioId: portfolioId),
      featureToggles: const FeatureToggles(
        includeHeatmap: false,
        includeMovers: true,
        includeSectorAllocation: false,
        includeMarketCapAllocation: false,
      ),
      featureConfiguration: FeatureConfiguration(moversLimit: limit),
      pagination: const Pagination(
        page: 1,
        size: 50,
        sortBy: 'changePercent',
        sortDirection: 'desc',
        returnAllData: false,
      ),
    );
  }

  /// Creates a request with only allocation features enabled
  PortfolioAnalyticsRequest _createAllocationOnlyRequest(String portfolioId) {
    return PortfolioAnalyticsRequest(
      coreIdentifiers: CoreIdentifiers(portfolioId: portfolioId),
      featureToggles: const FeatureToggles(
        includeHeatmap: false,
        includeMovers: false,
        includeSectorAllocation: true,
        includeMarketCapAllocation: true,
      ),
      featureConfiguration: const FeatureConfiguration(moversLimit: 10),
      pagination: const Pagination(
        page: 1,
        size: 100,
        sortBy: 'weightage',
        sortDirection: 'desc',
        returnAllData: false,
      ),
    );
  }
}

/// Data class for combined allocation information
class AllocationData {
  final SectorAllocation? sectorAllocation;
  final MarketCapAllocation? marketCapAllocation;

  const AllocationData({this.sectorAllocation, this.marketCapAllocation});

  /// Returns true if both allocation types have data
  bool get hasCompleteData =>
      sectorAllocation != null && marketCapAllocation != null;

  /// Returns true if at least one allocation type has data
  bool get hasAnyData =>
      sectorAllocation != null || marketCapAllocation != null;
}
