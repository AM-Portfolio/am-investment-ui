import 'dart:async';
import 'dart:convert';

import '../../domain/entities/portfolio_analytics.dart';
import '../../domain/entities/portfolio_analytics_request.dart';
import '../../domain/repositories/portfolio_analytics_repository.dart';
import '../datasources/portfolio_remote_data_source.dart';
import '../mappers/portfolio_analytics_mapper.dart';
import '../../../../../core/utils/logger.dart';

/// Repository implementation for portfolio analytics data operations
///
/// Handles portfolio analytics data operations following clean architecture principles
/// - Coordinates between data sources (remote, local cache)
/// - Maps DTOs to domain entities
/// - Provides caching and error handling
/// - Implements comprehensive logging
class PortfolioAnalyticsRepositoryImpl implements PortfolioAnalyticsRepository {
  final PortfolioRemoteDataSource _remoteDataSource;

  // Cache for the latest analytics data
  PortfolioAnalytics? _cachedAnalytics;
  PortfolioAnalyticsRequest? _lastRequest;
  DateTime? _lastFetchTime;

  // Cache expiry duration (5 minutes)
  static const Duration _cacheExpiryDuration = Duration(minutes: 5);

  PortfolioAnalyticsRepositoryImpl({
    required PortfolioRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<PortfolioAnalytics> getPortfolioAnalytics(
    PortfolioAnalyticsRequest request,
  ) async {
    AppLogger.methodEntry(
      'getPortfolioAnalytics',
      tag: 'PortfolioAnalyticsRepository',
      params: {'portfolioId': request.coreIdentifiers.portfolioId},
    );

    try {
      // Check cache validity
      if (_isCacheValid(request)) {
        AppLogger.info(
          'Returning cached portfolio analytics',
          tag: 'PortfolioAnalyticsRepository',
        );
        AppLogger.methodExit(
          'getPortfolioAnalytics',
          tag: 'PortfolioAnalyticsRepository',
          result: 'cache_hit',
        );
        return _cachedAnalytics!;
      }

      // Convert request entity to DTO
      final requestDto = PortfolioAnalyticsMapper.requestToDto(request);

      // Log the complete request DTO
      try {
        final requestJson = jsonEncode(requestDto.toJson());
        AppLogger.debug(
          'Request DTO:\n${const JsonEncoder.withIndent('  ').convert(jsonDecode(requestJson))}',
          tag: 'PortfolioAnalyticsRepository',
        );
      } catch (e) {
        AppLogger.warning(
          'Failed to serialize request DTO: $e',
          tag: 'PortfolioAnalyticsRepository',
        );
      }

      // Fetch data from remote source
      final analyticsDto = await _remoteDataSource.getPortfolioAnalytics(
        request.coreIdentifiers.portfolioId,
        requestDto,
      );

      // Log the complete analytics DTO response
      try {
        final responseJson = jsonEncode(analyticsDto.toJson());
        AppLogger.debug(
          'Analytics DTO Response:\n${const JsonEncoder.withIndent('  ').convert(jsonDecode(responseJson))}',
          tag: 'PortfolioAnalyticsRepository',
        );
      } catch (e) {
        AppLogger.warning(
          'Failed to serialize analytics DTO response: $e',
          tag: 'PortfolioAnalyticsRepository',
        );
      }

      // Map DTO to domain entity using analytics mapper
      final analytics = PortfolioAnalyticsMapper.responseFromDto(analyticsDto);

      // Log the final mapped analytics entity
      _logAnalyticsEntity(analytics);

      // Cache the result
      _cachedAnalytics = analytics;
      _lastRequest = request;
      _lastFetchTime = DateTime.now();

      AppLogger.info(
        'Portfolio analytics fetched successfully',
        tag: 'PortfolioAnalyticsRepository',
      );
      AppLogger.methodExit(
        'getPortfolioAnalytics',
        tag: 'PortfolioAnalyticsRepository',
        result: 'success',
      );

      return analytics;
    } catch (e) {
      AppLogger.error(
        'Failed to fetch portfolio analytics',
        tag: 'PortfolioAnalyticsRepository',
        error: e,
        stackTrace: StackTrace.current,
      );
      AppLogger.methodExit(
        'getPortfolioAnalytics',
        tag: 'PortfolioAnalyticsRepository',
        result: 'error',
      );

      // Return cached data if available, otherwise rethrow
      if (_cachedAnalytics != null && _isRequestSimilar(request)) {
        AppLogger.info(
          'Returning cached portfolio analytics due to error',
          tag: 'PortfolioAnalyticsRepository',
        );
        return _cachedAnalytics!;
      }

      rethrow;
    }
  }

  @override
  Future<Heatmap?> getHeatmapData(PortfolioAnalyticsRequest request) async {
    AppLogger.methodEntry(
      'getHeatmapData',
      tag: 'PortfolioAnalyticsRepository',
      params: {'portfolioId': request.coreIdentifiers.portfolioId},
    );

    try {
      // Get full analytics data
      final analytics = await getPortfolioAnalytics(request);

      AppLogger.info(
        'Heatmap data extracted successfully',
        tag: 'PortfolioAnalyticsRepository',
      );
      AppLogger.methodExit(
        'getHeatmapData',
        tag: 'PortfolioAnalyticsRepository',
        result: 'success',
      );

      return analytics.analytics.heatmap;
    } catch (e) {
      AppLogger.error(
        'Failed to get heatmap data',
        tag: 'PortfolioAnalyticsRepository',
        error: e,
        stackTrace: StackTrace.current,
      );
      AppLogger.methodExit(
        'getHeatmapData',
        tag: 'PortfolioAnalyticsRepository',
        result: 'error',
      );
      rethrow;
    }
  }

  @override
  Future<Movers?> getMoversData(PortfolioAnalyticsRequest request) async {
    AppLogger.methodEntry(
      'getMoversData',
      tag: 'PortfolioAnalyticsRepository',
      params: {'portfolioId': request.coreIdentifiers.portfolioId},
    );

    try {
      // Get full analytics data
      final analytics = await getPortfolioAnalytics(request);

      AppLogger.info(
        'Movers data extracted successfully',
        tag: 'PortfolioAnalyticsRepository',
      );
      AppLogger.methodExit(
        'getMoversData',
        tag: 'PortfolioAnalyticsRepository',
        result: 'success',
      );

      return analytics.analytics.movers;
    } catch (e) {
      AppLogger.error(
        'Failed to get movers data',
        tag: 'PortfolioAnalyticsRepository',
        error: e,
        stackTrace: StackTrace.current,
      );
      AppLogger.methodExit(
        'getMoversData',
        tag: 'PortfolioAnalyticsRepository',
        result: 'error',
      );
      rethrow;
    }
  }

  @override
  Future<SectorAllocation?> getSectorAllocation(
    PortfolioAnalyticsRequest request,
  ) async {
    AppLogger.methodEntry(
      'getSectorAllocation',
      tag: 'PortfolioAnalyticsRepository',
      params: {'portfolioId': request.coreIdentifiers.portfolioId},
    );

    try {
      // Get full analytics data
      final analytics = await getPortfolioAnalytics(request);

      AppLogger.info(
        'Sector allocation data extracted successfully',
        tag: 'PortfolioAnalyticsRepository',
      );
      AppLogger.methodExit(
        'getSectorAllocation',
        tag: 'PortfolioAnalyticsRepository',
        result: 'success',
      );

      return analytics.analytics.sectorAllocation;
    } catch (e) {
      AppLogger.error(
        'Failed to get sector allocation data',
        tag: 'PortfolioAnalyticsRepository',
        error: e,
        stackTrace: StackTrace.current,
      );
      AppLogger.methodExit(
        'getSectorAllocation',
        tag: 'PortfolioAnalyticsRepository',
        result: 'error',
      );
      rethrow;
    }
  }

  @override
  Future<MarketCapAllocation?> getMarketCapAllocation(
    PortfolioAnalyticsRequest request,
  ) async {
    AppLogger.methodEntry(
      'getMarketCapAllocation',
      tag: 'PortfolioAnalyticsRepository',
      params: {'portfolioId': request.coreIdentifiers.portfolioId},
    );

    try {
      // Get full analytics data
      final analytics = await getPortfolioAnalytics(request);

      AppLogger.info(
        'Market cap allocation data extracted successfully',
        tag: 'PortfolioAnalyticsRepository',
      );
      AppLogger.methodExit(
        'getMarketCapAllocation',
        tag: 'PortfolioAnalyticsRepository',
        result: 'success',
      );

      return analytics.analytics.marketCapAllocation;
    } catch (e) {
      AppLogger.error(
        'Failed to get market cap allocation data',
        tag: 'PortfolioAnalyticsRepository',
        error: e,
        stackTrace: StackTrace.current,
      );
      AppLogger.methodExit(
        'getMarketCapAllocation',
        tag: 'PortfolioAnalyticsRepository',
        result: 'error',
      );
      rethrow;
    }
  }

  /// Checks if cached data is still valid
  bool _isCacheValid(PortfolioAnalyticsRequest request) {
    if (_cachedAnalytics == null ||
        _lastFetchTime == null ||
        _lastRequest == null) {
      return false;
    }

    // Check if cache has expired
    final now = DateTime.now();
    if (now.difference(_lastFetchTime!) > _cacheExpiryDuration) {
      return false;
    }

    // Check if request is similar enough to use cached data
    return _isRequestSimilar(request);
  }

  /// Checks if the request is similar enough to the last request to use cached data
  bool _isRequestSimilar(PortfolioAnalyticsRequest request) {
    if (_lastRequest == null) return false;

    // Compare core identifiers (primary key for portfolio data)
    if (request.coreIdentifiers.portfolioId !=
        _lastRequest!.coreIdentifiers.portfolioId) {
      return false;
    }

    // Compare feature toggles (what data is being requested)
    final currentToggles = request.featureToggles;
    final lastToggles = _lastRequest!.featureToggles;

    if (currentToggles.includeHeatmap != lastToggles.includeHeatmap ||
        currentToggles.includeMovers != lastToggles.includeMovers ||
        currentToggles.includeSectorAllocation !=
            lastToggles.includeSectorAllocation ||
        currentToggles.includeMarketCapAllocation !=
            lastToggles.includeMarketCapAllocation) {
      return false;
    }

    return true;
  }

  /// Clears the cache
  void clearCache() {
    AppLogger.methodEntry('clearCache', tag: 'PortfolioAnalyticsRepository');

    _cachedAnalytics = null;
    _lastRequest = null;
    _lastFetchTime = null;

    AppLogger.info(
      'Portfolio analytics cache cleared',
      tag: 'PortfolioAnalyticsRepository',
    );
  }

  /// Logs the complete analytics entity for debugging
  void _logAnalyticsEntity(PortfolioAnalytics analytics) {
    try {
      // Create a comprehensive map of the analytics data
      final analyticsMap = {
        'portfolioId': analytics.portfolioId,
        'timestamp': analytics.timestamp.toIso8601String(),
        'analytics': {
          'heatmap': analytics.analytics.heatmap != null
              ? {
                  'sectors': analytics.analytics.heatmap!.sectors
                      .map(
                        (sector) => {
                          'sectorName': sector.sectorName,
                          'totalValue': sector.totalValue,
                          'weightage': sector.weightage,
                          'stocks': sector.stocks
                              .map(
                                (stock) => {
                                  'symbol': stock.symbol,
                                  'companyName': stock.companyName,
                                  'lastPrice': stock.lastPrice,
                                  'changeAmount': stock.changeAmount,
                                  'changePercent': stock.changePercent,
                                  'sector': stock.sector,
                                  'quantity': stock.quantity,
                                  'avgPrice': stock.avgPrice,
                                  'marketValue': stock.marketValue,
                                  'totalReturn': stock.totalReturn,
                                },
                              )
                              .toList(),
                        },
                      )
                      .toList(),
                }
              : null,
          'movers': analytics.analytics.movers != null
              ? {
                  'topGainers': analytics.analytics.movers!.topGainers
                      .map(
                        (stock) => {
                          'symbol': stock.symbol,
                          'companyName': stock.companyName,
                          'changePercent': stock.changePercent,
                          'changeAmount': stock.changeAmount,
                          'lastPrice': stock.lastPrice,
                        },
                      )
                      .toList(),
                  'topLosers': analytics.analytics.movers!.topLosers
                      .map(
                        (stock) => {
                          'symbol': stock.symbol,
                          'companyName': stock.companyName,
                          'changePercent': stock.changePercent,
                          'changeAmount': stock.changeAmount,
                          'lastPrice': stock.lastPrice,
                        },
                      )
                      .toList(),
                }
              : null,
          'sectorAllocation': analytics.analytics.sectorAllocation?.toString(),
          'marketCapAllocation': analytics.analytics.marketCapAllocation
              ?.toString(),
        },
      };

      final jsonString = const JsonEncoder.withIndent(
        '  ',
      ).convert(analyticsMap);
      AppLogger.debug(
        'Final Analytics Entity:\\n$jsonString',
        tag: 'PortfolioAnalyticsRepository',
      );

      // Log summary statistics
      if (analytics.analytics.heatmap != null) {
        final heatmap = analytics.analytics.heatmap!;
        final totalSectors = heatmap.sectors.length;
        final totalStocks = heatmap.sectors.fold(
          0,
          (sum, sector) => sum + sector.stocks.length,
        );

        AppLogger.info(
          'Analytics Summary - PortfolioId: ${analytics.portfolioId}, '
          'Timestamp: ${analytics.timestamp}, '
          'Sectors: $totalSectors, Total Stocks: $totalStocks',
          tag: 'PortfolioAnalyticsRepository',
        );

        // Log sector-wise summaries with stock details
        for (final sector in heatmap.sectors) {
          AppLogger.debug(
            'Sector: ${sector.sectorName} - '
            'Stocks: ${sector.stocks.length}, '
            'TotalValue: ${sector.totalValue}, '
            'Weightage: ${sector.weightage}',
            tag: 'PortfolioAnalyticsRepository',
          );

          // Log first few stocks with detailed info to debug missing values
          final stocksToLog = sector.stocks.take(3).toList();
          for (int i = 0; i < stocksToLog.length; i++) {
            final stock = stocksToLog[i];
            AppLogger.debug(
              'Stock ${i + 1} in ${sector.sectorName}: ${stock.symbol} - '
              'LastPrice: ${stock.lastPrice}, '
              'MarketValue: ${stock.marketValue}, '
              'Quantity: ${stock.quantity}, '
              'AvgPrice: ${stock.avgPrice}, '
              'ChangeAmount: ${stock.changeAmount}, '
              'ChangePercent: ${stock.changePercent}, '
              'CompanyName: "${stock.companyName}"',
              tag: 'PortfolioAnalyticsRepository',
            );
          }
        }
      }
    } catch (e) {
      AppLogger.error(
        'Failed to log analytics entity: $e',
        tag: 'PortfolioAnalyticsRepository',
        error: e,
      );
    }
  }

  /// Dispose method to clean up resources
  void dispose() {
    AppLogger.methodEntry('dispose', tag: 'PortfolioAnalyticsRepository');

    clearCache();

    AppLogger.info(
      'PortfolioAnalyticsRepository disposed',
      tag: 'PortfolioAnalyticsRepository',
    );
  }
}
