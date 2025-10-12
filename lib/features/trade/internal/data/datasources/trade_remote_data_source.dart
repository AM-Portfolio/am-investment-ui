import '../../../../../config/app_config.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/utils/logger.dart';
import '../dtos/trade_portfolio_dto.dart';
import '../dtos/trade_holding_dto.dart';
import '../dtos/trade_summary_dto.dart';
import '../dtos/trade_calendar_dto.dart';
import 'trade_mock_data_helper.dart';

/// Abstract data source for trade data
abstract class TradeRemoteDataSource {
  /// Get trade portfolios from remote API
  Future<TradePortfolioListDto> getTradePortfolios(String userId);

  /// Get trade holdings from remote API
  Future<TradeHoldingsDto> getTradeHoldings(String userId, String portfolioId);

  /// Get trade summary from remote API
  Future<TradeSummaryDto> getTradeSummary(String userId, String portfolioId);

  /// Get trade calendar from remote API
  Future<TradeCalendarDto> getTradeCalendar(String userId, String portfolioId);
}

/// Concrete implementation of trade remote data source
class TradeRemoteDataSourceImpl implements TradeRemoteDataSource {
  const TradeRemoteDataSourceImpl({
    required ApiClient apiClient,
    required ApiConfig apiConfig,
  })  : _apiClient = apiClient,
        _apiConfig = apiConfig;

  final ApiClient _apiClient;
  final ApiConfig _apiConfig;

  @override
  Future<TradePortfolioListDto> getTradePortfolios(String userId) async {
    AppLogger.methodEntry(
      'getTradePortfolios',
      tag: 'TradeRemoteDataSource',
      params: {'userId': userId},
    );

    try {
      final fullUri =
          '${_apiConfig.baseUrl}/portfolios/list?userId=$userId';

      final response = await _apiClient.get<TradePortfolioListDto>(
        fullUri,
        parser: (data) => TradePortfolioListDto.fromJson(
          data! as Map<String, dynamic>,
        ),
      );

      AppLogger.info(
        'Trade portfolios fetched successfully from API',
        tag: 'TradeRemoteDataSource',
      );
      AppLogger.methodExit(
        'getTradePortfolios',
        tag: 'TradeRemoteDataSource',
        result: 'success',
      );

      return response;
    } catch (e) {
      AppLogger.error(
        'Failed to fetch trade portfolios',
        tag: 'TradeRemoteDataSource',
        error: e,
        stackTrace: StackTrace.current,
      );

      // Fallback to mock data
      try {
        AppLogger.info(
          'Loading mock trade portfolios',
          tag: 'TradeRemoteDataSource',
        );
        return await TradeMockDataHelper.getMockTradePortfolios();
      } catch (mockError) {
        AppLogger.error(
          'Failed to load mock data',
          tag: 'TradeRemoteDataSource',
          error: mockError,
        );
        rethrow;
      }
    }
  }

  @override
  Future<TradeHoldingsDto> getTradeHoldings(
    String userId,
    String portfolioId,
  ) async {
    AppLogger.methodEntry(
      'getTradeHoldings',
      tag: 'TradeRemoteDataSource',
      params: {'userId': userId, 'portfolioId': portfolioId},
    );

    try {
      final fullUri =
          '${_apiConfig.baseUrl}/portfolios/$portfolioId/holdings?userId=$userId';

      final response = await _apiClient.get<TradeHoldingsDto>(
        fullUri,
        parser: (data) => TradeHoldingsDto.fromJson(
          data! as Map<String, dynamic>,
        ),
      );

      AppLogger.info(
        'Trade holdings fetched successfully from API',
        tag: 'TradeRemoteDataSource',
      );
      AppLogger.methodExit(
        'getTradeHoldings',
        tag: 'TradeRemoteDataSource',
        result: 'success',
      );

      return response;
    } catch (e) {
      AppLogger.error(
        'Failed to fetch trade holdings',
        tag: 'TradeRemoteDataSource',
        error: e,
        stackTrace: StackTrace.current,
      );

      // Fallback to mock data
      try {
        AppLogger.info(
          'Loading mock trade holdings',
          tag: 'TradeRemoteDataSource',
        );
        return await TradeMockDataHelper.getMockTradeHoldings();
      } catch (mockError) {
        AppLogger.error(
          'Failed to load mock data',
          tag: 'TradeRemoteDataSource',
          error: mockError,
        );
        rethrow;
      }
    }
  }

  @override
  Future<TradeSummaryDto> getTradeSummary(
    String userId,
    String portfolioId,
  ) async {
    AppLogger.methodEntry(
      'getTradeSummary',
      tag: 'TradeRemoteDataSource',
      params: {'userId': userId, 'portfolioId': portfolioId},
    );

    try {
      final fullUri =
          '${_apiConfig.baseUrl}/portfolios/$portfolioId/summary?userId=$userId';

      final response = await _apiClient.get<TradeSummaryDto>(
        fullUri,
        parser: (data) => TradeSummaryDto.fromJson(
          data! as Map<String, dynamic>,
        ),
      );

      AppLogger.info(
        'Trade summary fetched successfully from API',
        tag: 'TradeRemoteDataSource',
      );
      AppLogger.methodExit(
        'getTradeSummary',
        tag: 'TradeRemoteDataSource',
        result: 'success',
      );

      return response;
    } catch (e) {
      AppLogger.error(
        'Failed to fetch trade summary',
        tag: 'TradeRemoteDataSource',
        error: e,
        stackTrace: StackTrace.current,
      );

      // Fallback to mock data
      try {
        AppLogger.info(
          'Loading mock trade summary',
          tag: 'TradeRemoteDataSource',
        );
        return await TradeMockDataHelper.getMockTradeSummary();
      } catch (mockError) {
        AppLogger.error(
          'Failed to load mock data',
          tag: 'TradeRemoteDataSource',
          error: mockError,
        );
        rethrow;
      }
    }
  }

  @override
  Future<TradeCalendarDto> getTradeCalendar(
    String userId,
    String portfolioId,
  ) async {
    AppLogger.methodEntry(
      'getTradeCalendar',
      tag: 'TradeRemoteDataSource',
      params: {'userId': userId, 'portfolioId': portfolioId},
    );

    try {
      final fullUri =
          '${_apiConfig.baseUrl}/portfolios/$portfolioId/calendar?userId=$userId';

      final response = await _apiClient.get<TradeCalendarDto>(
        fullUri,
        parser: (data) => TradeCalendarDto.fromJson(
          data! as Map<String, dynamic>,
        ),
      );

      AppLogger.info(
        'Trade calendar fetched successfully from API',
        tag: 'TradeRemoteDataSource',
      );
      AppLogger.methodExit(
        'getTradeCalendar',
        tag: 'TradeRemoteDataSource',
        result: 'success',
      );

      return response;
    } catch (e) {
      AppLogger.error(
        'Failed to fetch trade calendar',
        tag: 'TradeRemoteDataSource',
        error: e,
        stackTrace: StackTrace.current,
      );

      // Fallback to mock data
      try {
        AppLogger.info(
          'Loading mock trade calendar',
          tag: 'TradeRemoteDataSource',
        );
        return await TradeMockDataHelper.getMockTradeCalendar();
      } catch (mockError) {
        AppLogger.error(
          'Failed to load mock data',
          tag: 'TradeRemoteDataSource',
          error: mockError,
        );
        rethrow;
      }
    }
  }
}
