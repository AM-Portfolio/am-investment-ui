import '../../../../../config/app_config.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/utils/logger.dart';
import '../dtos/trade_calendar_dto.dart';
import '../dtos/trade_holding_dto.dart';
import '../dtos/trade_portfolio_dto.dart';
import '../dtos/trade_portfolio_summary_dto.dart';
import 'trade_mock_data_helper.dart';

/// Abstract data source for trade data
abstract class TradeRemoteDataSource {
  /// Get trade portfolios from remote API
  Future<TradePortfolioListDto> getTradePortfolios(String userId);

  /// Get trade holdings from remote API
  Future<TradeHoldingsDto> getTradeHoldings(String userId, String portfolioId);

  /// Get trade summary from remote API
  Future<TradePortfolioSummaryDto> getTradeSummary(String userId, String portfolioId);

  /// Get trade calendar by month from remote API
  Future<TradeCalendarDto> getTradeCalendarByMonth(
    String userId,
    String portfolioId, {
    required int year,
    required int month,
  });

  /// Get trade calendar by day from remote API
  Future<TradeCalendarDto> getTradeCalendarByDay(String userId, String portfolioId, {required DateTime date});

  /// Get trade calendar by date range from remote API
  Future<TradeCalendarDto> getTradeCalendarByDateRange(
    String userId,
    String portfolioId, {
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Get trade calendar by quarter from remote API
  Future<TradeCalendarDto> getTradeCalendarByQuarter(
    String userId,
    String portfolioId, {
    required int year,
    required int quarter,
  });

  /// Get trade calendar by financial year from remote API
  Future<TradeCalendarDto> getTradeCalendarByFinancialYear(
    String userId,
    String portfolioId, {
    required int financialYear,
  });

  /// Get trade calendar from remote API (legacy - delegates to getTradeCalendarByMonth)
  @Deprecated('Use getTradeCalendarByMonth instead')
  Future<TradeCalendarDto> getTradeCalendar(String userId, String portfolioId, {int? year, int? month});
}

/// Concrete implementation of trade remote data source
class TradeRemoteDataSourceImpl implements TradeRemoteDataSource {
  const TradeRemoteDataSourceImpl({required ApiClient apiClient, required ApiConfig apiConfig})
    : _apiClient = apiClient,
      _apiConfig = apiConfig;

  final ApiClient _apiClient;
  final ApiConfig _apiConfig;

  @override
  Future<TradePortfolioListDto> getTradePortfolios(String userId) async {
    AppLogger.methodEntry('getTradePortfolios', tag: 'TradeRemoteDataSource', params: {'userId': userId});

    try {
      // Trade API Spec: GET /api/v1/portfolio-summary/by-owner/{ownerId}
      // Returns a plain array of portfolios
      final fullUri = '${_apiConfig.baseUrl}/api/v1/portfolio-summary/by-owner/$userId';

      final response = await _apiClient.get<TradePortfolioListDto>(
        fullUri,
        parser: (data) {
          // API returns array, wrap it in expected structure
          if (data is List) {
            return TradePortfolioListDto(
              portfolios: data.map((item) => TradePortfolioDto.fromJson(item as Map<String, dynamic>)).toList(),
              totalCount: data.length,
            );
          }
          // Fallback if already wrapped
          return TradePortfolioListDto.fromJson(data! as Map<String, dynamic>);
        },
      );

      AppLogger.info('Trade portfolios fetched successfully from API', tag: 'TradeRemoteDataSource');
      AppLogger.methodExit('getTradePortfolios', tag: 'TradeRemoteDataSource', result: 'success');

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
        AppLogger.info('Loading mock trade portfolios', tag: 'TradeRemoteDataSource');
        return await TradeMockDataHelper.getMockTradePortfolios();
      } catch (mockError) {
        AppLogger.error('Failed to load mock data', tag: 'TradeRemoteDataSource', error: mockError);
        rethrow;
      }
    }
  }

  @override
  Future<TradeHoldingsDto> getTradeHoldings(String userId, String portfolioId) async {
    AppLogger.methodEntry(
      'getTradeHoldings',
      tag: 'TradeRemoteDataSource',
      params: {'userId': userId, 'portfolioId': portfolioId},
    );

    try {
      // Trade API Spec: GET /api/v1/trades/portfolio-details/{portfolioId}?page=0&size=50&sort=tradeDate,desc
      final fullUri =
          '${_apiConfig.baseUrl}/api/v1/trades/portfolio-details/$portfolioId?page=0&size=50&sort=tradeDate%2Cdesc';

      final response = await _apiClient.get<TradeHoldingsDto>(
        fullUri,
        parser: (data) => TradeHoldingsDto.fromJson(data! as Map<String, dynamic>),
      );

      AppLogger.info('Trade holdings fetched successfully from API', tag: 'TradeRemoteDataSource');
      AppLogger.methodExit('getTradeHoldings', tag: 'TradeRemoteDataSource', result: 'success');

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
        AppLogger.info('Loading mock trade holdings', tag: 'TradeRemoteDataSource');
        return await TradeMockDataHelper.getMockTradeHoldings();
      } catch (mockError) {
        AppLogger.error('Failed to load mock data', tag: 'TradeRemoteDataSource', error: mockError);
        rethrow;
      }
    }
  }

  @override
  Future<TradePortfolioSummaryDto> getTradeSummary(String userId, String portfolioId) async {
    AppLogger.methodEntry(
      'getTradeSummary',
      tag: 'TradeRemoteDataSource',
      params: {'userId': userId, 'portfolioId': portfolioId},
    );

    try {
      // Trade API Spec: GET /api/v1/portfolio-summary/{portfolioId}
      final fullUri = '${_apiConfig.baseUrl}/api/v1/portfolio-summary/$portfolioId';

      final response = await _apiClient.get<TradePortfolioSummaryDto>(
        fullUri,
        parser: (data) => TradePortfolioSummaryDto.fromJson(data! as Map<String, dynamic>),
      );

      AppLogger.info('Trade summary fetched successfully from API', tag: 'TradeRemoteDataSource');
      AppLogger.methodExit('getTradeSummary', tag: 'TradeRemoteDataSource', result: 'success');

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
        AppLogger.info('Loading mock trade summary', tag: 'TradeRemoteDataSource');
        return await TradeMockDataHelper.getMockTradeSummary();
      } catch (mockError) {
        AppLogger.error('Failed to load mock data', tag: 'TradeRemoteDataSource', error: mockError);
        rethrow;
      }
    }
  }

  @override
  Future<TradeCalendarDto> getTradeCalendarByMonth(
    String userId,
    String portfolioId, {
    required int year,
    required int month,
  }) async {
    AppLogger.methodEntry(
      'getTradeCalendarByMonth',
      tag: 'TradeRemoteDataSource',
      params: {'userId': userId, 'portfolioId': portfolioId, 'year': year, 'month': month},
    );

    try {
      // Trade API Spec: GET /api/v1/trades/calendar/month?portfolioId={id}&year={year}&month={month}
      final fullUri =
          '${_apiConfig.baseUrl}/api/v1/trades/calendar/month?portfolioId=$portfolioId&year=$year&month=$month';

      AppLogger.info('Fetching calendar for year=$year, month=$month', tag: 'TradeRemoteDataSource');

      final response = await _apiClient.get<TradeCalendarDto>(
        fullUri,
        parser: (data) {
          final json = data! as Map<String, dynamic>;
          if (json.isEmpty) {
            return const TradeCalendarDto(portfolioTrades: {});
          }
          return TradeCalendarDto.fromJson(json);
        },
      );

      AppLogger.info('Trade calendar by month fetched successfully from API', tag: 'TradeRemoteDataSource');
      AppLogger.methodExit('getTradeCalendarByMonth', tag: 'TradeRemoteDataSource', result: 'success');

      return response;
    } catch (e) {
      AppLogger.error(
        'Failed to fetch trade calendar by month',
        tag: 'TradeRemoteDataSource',
        error: e,
        stackTrace: StackTrace.current,
      );

      // Fallback to mock data
      try {
        AppLogger.info('Loading mock trade calendar', tag: 'TradeRemoteDataSource');
        return await TradeMockDataHelper.getMockTradeCalendar();
      } catch (mockError) {
        AppLogger.error('Failed to load mock data', tag: 'TradeRemoteDataSource', error: mockError);
        rethrow;
      }
    }
  }

  @override
  Future<TradeCalendarDto> getTradeCalendarByDay(String userId, String portfolioId, {required DateTime date}) async {
    AppLogger.methodEntry(
      'getTradeCalendarByDay',
      tag: 'TradeRemoteDataSource',
      params: {'userId': userId, 'portfolioId': portfolioId, 'date': date.toIso8601String()},
    );

    try {
      // Trade API Spec: GET /api/v1/trades/calendar/day?date={date}&portfolioId={id}
      final formattedDate =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final fullUri = '${_apiConfig.baseUrl}/api/v1/trades/calendar/day?date=$formattedDate&portfolioId=$portfolioId';

      AppLogger.info('Fetching calendar for date=$formattedDate', tag: 'TradeRemoteDataSource');

      final response = await _apiClient.get<TradeCalendarDto>(
        fullUri,
        parser: (data) {
          final json = data! as Map<String, dynamic>;
          if (json.isEmpty) {
            return const TradeCalendarDto(portfolioTrades: {});
          }
          return TradeCalendarDto.fromJson(json);
        },
      );

      AppLogger.info('Trade calendar by day fetched successfully from API', tag: 'TradeRemoteDataSource');
      AppLogger.methodExit('getTradeCalendarByDay', tag: 'TradeRemoteDataSource', result: 'success');

      return response;
    } catch (e) {
      AppLogger.error(
        'Failed to fetch trade calendar by day',
        tag: 'TradeRemoteDataSource',
        error: e,
        stackTrace: StackTrace.current,
      );

      // Fallback to mock data
      try {
        AppLogger.info('Loading mock trade calendar by day', tag: 'TradeRemoteDataSource');
        return await TradeMockDataHelper.getMockTradeCalendarByDay();
      } catch (mockError) {
        AppLogger.error('Failed to load mock data', tag: 'TradeRemoteDataSource', error: mockError);
        rethrow;
      }
    }
  }

  @override
  Future<TradeCalendarDto> getTradeCalendarByDateRange(
    String userId,
    String portfolioId, {
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    AppLogger.methodEntry(
      'getTradeCalendarByDateRange',
      tag: 'TradeRemoteDataSource',
      params: {
        'userId': userId,
        'portfolioId': portfolioId,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
      },
    );

    try {
      // Trade API Spec: GET /api/v1/trades/calendar/custom?portfolioId={id}&startDate={start}&endDate={end}&page=0&size=50
      final formattedStartDate =
          '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}';
      final formattedEndDate =
          '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}';
      final fullUri =
          '${_apiConfig.baseUrl}/api/v1/trades/calendar/custom?portfolioId=$portfolioId&startDate=$formattedStartDate&endDate=$formattedEndDate&page=0&size=50';

      AppLogger.info(
        'Fetching calendar for date range=$formattedStartDate to $formattedEndDate',
        tag: 'TradeRemoteDataSource',
      );

      final response = await _apiClient.get<TradeCalendarDto>(
        fullUri,
        parser: (data) {
          final json = data! as Map<String, dynamic>;
          if (json.isEmpty) {
            return const TradeCalendarDto(portfolioTrades: {});
          }
          return TradeCalendarDto.fromJson(json);
        },
      );

      AppLogger.info('Trade calendar by date range fetched successfully from API', tag: 'TradeRemoteDataSource');
      AppLogger.methodExit('getTradeCalendarByDateRange', tag: 'TradeRemoteDataSource', result: 'success');

      return response;
    } catch (e) {
      AppLogger.error(
        'Failed to fetch trade calendar by date range',
        tag: 'TradeRemoteDataSource',
        error: e,
        stackTrace: StackTrace.current,
      );

      // Fallback to mock data
      try {
        AppLogger.info('Loading mock trade calendar by date range', tag: 'TradeRemoteDataSource');
        return await TradeMockDataHelper.getMockTradeCalendarByDateRange();
      } catch (mockError) {
        AppLogger.error('Failed to load mock data', tag: 'TradeRemoteDataSource', error: mockError);
        rethrow;
      }
    }
  }

  @override
  Future<TradeCalendarDto> getTradeCalendarByQuarter(
    String userId,
    String portfolioId, {
    required int year,
    required int quarter,
  }) async {
    AppLogger.methodEntry(
      'getTradeCalendarByQuarter',
      tag: 'TradeRemoteDataSource',
      params: {'userId': userId, 'portfolioId': portfolioId, 'year': year, 'quarter': quarter},
    );

    try {
      // Trade API Spec: GET /api/v1/trades/calendar/quarter?portfolioId={id}&year={year}&quarter={quarter}
      final fullUri =
          '${_apiConfig.baseUrl}/api/v1/trades/calendar/quarter?portfolioId=$portfolioId&year=$year&quarter=$quarter';

      AppLogger.info('Fetching calendar for year=$year, quarter=$quarter', tag: 'TradeRemoteDataSource');

      final response = await _apiClient.get<TradeCalendarDto>(
        fullUri,
        parser: (data) {
          final json = data! as Map<String, dynamic>;
          if (json.isEmpty) {
            return const TradeCalendarDto(portfolioTrades: {});
          }
          return TradeCalendarDto.fromJson(json);
        },
      );

      AppLogger.info('Trade calendar by quarter fetched successfully from API', tag: 'TradeRemoteDataSource');
      AppLogger.methodExit('getTradeCalendarByQuarter', tag: 'TradeRemoteDataSource', result: 'success');

      return response;
    } catch (e) {
      AppLogger.error(
        'Failed to fetch trade calendar by quarter',
        tag: 'TradeRemoteDataSource',
        error: e,
        stackTrace: StackTrace.current,
      );

      // Fallback to mock data
      try {
        AppLogger.info('Loading mock trade calendar', tag: 'TradeRemoteDataSource');
        return await TradeMockDataHelper.getMockTradeCalendar();
      } catch (mockError) {
        AppLogger.error('Failed to load mock data', tag: 'TradeRemoteDataSource', error: mockError);
        rethrow;
      }
    }
  }

  @override
  Future<TradeCalendarDto> getTradeCalendarByFinancialYear(
    String userId,
    String portfolioId, {
    required int financialYear,
  }) async {
    AppLogger.methodEntry(
      'getTradeCalendarByFinancialYear',
      tag: 'TradeRemoteDataSource',
      params: {'userId': userId, 'portfolioId': portfolioId, 'financialYear': financialYear},
    );

    try {
      // Trade API Spec: GET /api/v1/trades/calendar/financial-year?portfolioId={id}&financialYear={year}
      final fullUri =
          '${_apiConfig.baseUrl}/api/v1/trades/calendar/financial-year?portfolioId=$portfolioId&financialYear=$financialYear';

      AppLogger.info('Fetching calendar for financial year=$financialYear', tag: 'TradeRemoteDataSource');

      final response = await _apiClient.get<TradeCalendarDto>(
        fullUri,
        parser: (data) {
          final json = data! as Map<String, dynamic>;
          if (json.isEmpty) {
            return const TradeCalendarDto(portfolioTrades: {});
          }
          return TradeCalendarDto.fromJson(json);
        },
      );

      AppLogger.info('Trade calendar by financial year fetched successfully from API', tag: 'TradeRemoteDataSource');
      AppLogger.methodExit('getTradeCalendarByFinancialYear', tag: 'TradeRemoteDataSource', result: 'success');

      return response;
    } catch (e) {
      AppLogger.error(
        'Failed to fetch trade calendar by financial year',
        tag: 'TradeRemoteDataSource',
        error: e,
        stackTrace: StackTrace.current,
      );

      // Fallback to mock data
      try {
        AppLogger.info('Loading mock trade calendar', tag: 'TradeRemoteDataSource');
        return await TradeMockDataHelper.getMockTradeCalendar();
      } catch (mockError) {
        AppLogger.error('Failed to load mock data', tag: 'TradeRemoteDataSource', error: mockError);
        rethrow;
      }
    }
  }

  @override
  Future<TradeCalendarDto> getTradeCalendar(String userId, String portfolioId, {int? year, int? month}) async {
    // Legacy method - delegates to getTradeCalendarByMonth
    final now = DateTime.now();
    final targetYear = year ?? now.year;
    final targetMonth = month ?? now.month;

    return getTradeCalendarByMonth(userId, portfolioId, year: targetYear, month: targetMonth);
  }
}
