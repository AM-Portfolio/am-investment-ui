import '../dtos/portfolio_holdings_dto.dart';
import '../dtos/portfolio_summary_dto.dart';
import '../dtos/portfolio_analytics_request_dto.dart';
import '../dtos/portfolio_analytics_response_dto.dart';
import '../dtos/portfolio_list_dto.dart';
import '../../../../../core/utils/logger.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../config/app_config.dart';
import '../mappers/portfolio_mapper.dart';
import '../mappers/portfolio_analytics_mapper.dart';

/// Abstract data source for portfolio data
abstract class PortfolioRemoteDataSource {
  /// Get portfolio holdings from remote API
  Future<PortfolioHoldingsDto> getPortfolioHoldings(String userId);

  /// Get portfolio summary from remote API
  Future<PortfolioSummaryDto> getPortfolioSummary(String userId);

  /// Get portfolio analytics from remote API
  Future<PortfolioAnalyticsResponseDto> getPortfolioAnalytics(
    String portfolioId,
    PortfolioAnalyticsRequestDto request,
  );

  /// Get portfolios list from remote API
  Future<PortfolioListDto> getPortfoliosList(String userId);
}

/// Concrete implementation of portfolio remote data source
///
/// Handles API calls for portfolio operations following clean architecture principles
class PortfolioRemoteDataSourceImpl implements PortfolioRemoteDataSource {
  final ApiClient _apiClient;
  final PortfolioApiConfig _portfolioConfig;

  const PortfolioRemoteDataSourceImpl({
    required ApiClient apiClient,
    required PortfolioApiConfig portfolioConfig,
  }) : _apiClient = apiClient,
       _portfolioConfig = portfolioConfig;

  @override
  Future<PortfolioHoldingsDto> getPortfolioHoldings(String userId) async {
    AppLogger.methodEntry(
      'getPortfolioHoldings',
      tag: 'PortfolioRemoteDataSource',
      params: {'userId': userId},
    );

    try {
      AppLogger.debug(
        'API request prepared for portfolio holdings with userId query param',
        tag: 'PortfolioRemoteDataSource',
      );

      // Construct full URI from portfolio config with userId query parameter
      final baseUri =
          '${_portfolioConfig.baseUrl}${_portfolioConfig.holdingsResource}';
      final fullUri = '$baseUri?userId=$userId';

      // Use ApiClient for consistent error handling and logging
      final holdingsResponse = await _apiClient.get<PortfolioHoldingsDto>(
        fullUri,
        parser: (data) => PortfolioMapper.portfolioHoldingsFromJson(
          data as Map<String, dynamic>,
        ),
      );

      AppLogger.info(
        'Portfolio holdings fetched successfully from API',
        tag: 'PortfolioRemoteDataSource',
      );
      AppLogger.methodExit(
        'getPortfolioHoldings',
        tag: 'PortfolioRemoteDataSource',
        result: 'success',
      );

      return holdingsResponse;
    } catch (e) {
      AppLogger.error(
        'Failed to fetch portfolio holdings',
        tag: 'PortfolioRemoteDataSource',
        error: e,
        stackTrace: StackTrace.current,
      );
      AppLogger.methodExit(
        'getPortfolioHoldings',
        tag: 'PortfolioRemoteDataSource',
        result: 'error',
      );
      rethrow;
    }
  }

  @override
  Future<PortfolioSummaryDto> getPortfolioSummary(String userId) async {
    AppLogger.methodEntry(
      'getPortfolioSummary',
      tag: 'PortfolioRemoteDataSource',
      params: {'userId': userId},
    );

    try {
      AppLogger.debug(
        'API request prepared for portfolio summary with userId query param',
        tag: 'PortfolioRemoteDataSource',
      );

      // Construct full URI from portfolio config with userId query parameter
      final baseUri =
          '${_portfolioConfig.baseUrl}${_portfolioConfig.summaryResource}';
      final fullUri = '$baseUri?userId=$userId';

      // Use ApiClient for consistent error handling and logging
      final summaryResponse = await _apiClient.get<PortfolioSummaryDto>(
        fullUri,
        parser: (data) => PortfolioMapper.portfolioSummaryFromJson(
          data as Map<String, dynamic>,
        ),
      );

      AppLogger.info(
        'Portfolio summary fetched successfully from API',
        tag: 'PortfolioRemoteDataSource',
      );
      AppLogger.methodExit(
        'getPortfolioSummary',
        tag: 'PortfolioRemoteDataSource',
        result: 'success',
      );

      return summaryResponse;
    } catch (e) {
      AppLogger.error(
        'Failed to fetch portfolio summary',
        tag: 'PortfolioRemoteDataSource',
        error: e,
        stackTrace: StackTrace.current,
      );
      AppLogger.methodExit(
        'getPortfolioSummary',
        tag: 'PortfolioRemoteDataSource',
        result: 'error',
      );
      rethrow;
    }
  }

  @override
  Future<PortfolioAnalyticsResponseDto> getPortfolioAnalytics(
    String portfolioId,
    PortfolioAnalyticsRequestDto request,
  ) async {
    AppLogger.methodEntry(
      'getPortfolioAnalytics',
      tag: 'PortfolioRemoteDataSource',
      params: {'portfolioId': portfolioId},
    );

    try {
      AppLogger.debug(
        'API request prepared for portfolio analytics',
        tag: 'PortfolioRemoteDataSource',
      );

      // Construct full URI for analytics endpoint
      final baseUri =
          '${_portfolioConfig.baseUrl}/api/v1/analytics/portfolio/$portfolioId/advanced';

      // Use ApiClient for consistent error handling and logging with POST request
      final analyticsResponse = await _apiClient.post<PortfolioAnalyticsResponseDto>(
        baseUri,
        body: request.toJson(),
        parser: (data) {
          final rawData = data as Map<String, dynamic>;

          // Log raw API response for debugging
          AppLogger.debug(
            '🔍 Raw API response keys: ${rawData.keys.toList()}',
            tag: 'PortfolioRemoteDataSource',
          );

          // Check if sectorAllocation exists in raw response
          if (rawData.containsKey('analytics')) {
            final analytics = rawData['analytics'] as Map<String, dynamic>?;
            if (analytics?.containsKey('sectorAllocation') == true) {
              final sectorAllocation =
                  analytics!['sectorAllocation'] as Map<String, dynamic>?;
              AppLogger.debug(
                '🔍 Raw sectorAllocation keys: ${sectorAllocation?.keys.toList()}',
                tag: 'PortfolioRemoteDataSource',
              );
              if (sectorAllocation?.containsKey('sectorWeights') == true) {
                final sectorWeights = sectorAllocation!['sectorWeights'];
                AppLogger.debug(
                  '🔍 Raw sectorWeights type: ${sectorWeights.runtimeType}, content: $sectorWeights',
                  tag: 'PortfolioRemoteDataSource',
                );
              } else {
                AppLogger.debug(
                  '🔍 sectorWeights field is missing from raw sectorAllocation',
                  tag: 'PortfolioRemoteDataSource',
                );
              }
            } else {
              AppLogger.debug(
                '🔍 sectorAllocation field is missing from raw analytics',
                tag: 'PortfolioRemoteDataSource',
              );
            }
          } else {
            AppLogger.debug(
              '🔍 analytics field is missing from raw response',
              tag: 'PortfolioRemoteDataSource',
            );
          }

          try {
            return PortfolioAnalyticsMapper.responseFromJson(rawData);
          } catch (e) {
            AppLogger.error(
              '🔍 PortfolioAnalyticsMapper.responseFromJson failed - Raw data: ${rawData.toString()}',
              tag: 'PortfolioRemoteDataSource',
              error: e,
              stackTrace: StackTrace.current,
            );
            rethrow;
          }
        },
      );

      AppLogger.info(
        'Portfolio analytics fetched successfully from API',
        tag: 'PortfolioRemoteDataSource',
      );
      AppLogger.methodExit(
        'getPortfolioAnalytics',
        tag: 'PortfolioRemoteDataSource',
        result: 'success',
      );

      return analyticsResponse;
    } catch (e) {
      AppLogger.error(
        'Failed to fetch portfolio analytics',
        tag: 'PortfolioRemoteDataSource',
        error: e,
        stackTrace: StackTrace.current,
      );
      AppLogger.methodExit(
        'getPortfolioAnalytics',
        tag: 'PortfolioRemoteDataSource',
        result: 'error',
      );
      rethrow;
    }
  }

  @override
  Future<PortfolioListDto> getPortfoliosList(String userId) async {
    AppLogger.methodEntry(
      'getPortfoliosList',
      tag: 'PortfolioRemoteDataSource',
      params: {'userId': userId},
    );

    try {
      AppLogger.debug(
        'API request prepared for portfolios list with userId query param',
        tag: 'PortfolioRemoteDataSource',
      );

      // Construct full URI from portfolio config with userId query parameter
      final baseUri = '${_portfolioConfig.baseUrl}/api/v1/portfolios/list';
      final fullUri = '$baseUri?userId=$userId';

      // Use ApiClient for consistent error handling and logging
      final listResponse = await _apiClient.get<PortfolioListDto>(
        fullUri,
        parser: (data) =>
            PortfolioMapper.portfolioListFromJson(data as List<dynamic>),
      );

      AppLogger.info(
        'Portfolios list fetched successfully from API',
        tag: 'PortfolioRemoteDataSource',
      );
      AppLogger.methodExit(
        'getPortfoliosList',
        tag: 'PortfolioRemoteDataSource',
        result: 'success',
      );

      return listResponse;
    } catch (e) {
      AppLogger.error(
        'Failed to fetch portfolios list',
        tag: 'PortfolioRemoteDataSource',
        error: e,
        stackTrace: StackTrace.current,
      );
      AppLogger.methodExit(
        'getPortfoliosList',
        tag: 'PortfolioRemoteDataSource',
        result: 'error',
      );
      rethrow;
    }
  }
}
