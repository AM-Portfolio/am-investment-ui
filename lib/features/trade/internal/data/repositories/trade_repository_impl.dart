import 'dart:async';

import '../../../../../core/utils/logger.dart';
import '../../domain/entities/trade_calendar.dart';
import '../../domain/entities/trade_holding.dart';
import '../../domain/entities/trade_portfolio.dart';
import '../../domain/entities/trade_summary.dart';
import '../../domain/repositories/trade_repository.dart';
import '../datasources/trade_remote_data_source.dart';
import '../mappers/trade_calendar_mapper.dart';
import '../mappers/trade_holding_mapper.dart';
import '../mappers/trade_portfolio_mapper.dart';
import '../mappers/trade_summary_mapper.dart';

/// Repository implementation for trade data operations
class TradeRepositoryImpl implements TradeRepository {
  TradeRepositoryImpl({required TradeRemoteDataSource remoteDataSource}) : _remoteDataSource = remoteDataSource;

  final TradeRemoteDataSource _remoteDataSource;

  // Stream controllers for real-time updates
  final StreamController<TradePortfolioList> _portfoliosController = StreamController<TradePortfolioList>.broadcast();
  final StreamController<TradeHoldings> _holdingsController = StreamController<TradeHoldings>.broadcast();
  final StreamController<TradeSummary> _summaryController = StreamController<TradeSummary>.broadcast();
  final StreamController<TradeCalendar> _calendarController = StreamController<TradeCalendar>.broadcast();

  // Cache for the latest data
  TradePortfolioList? _cachedPortfolioList;
  TradeHoldings? _cachedHoldings;
  TradeSummary? _cachedSummary;
  TradeCalendar? _cachedCalendar;

  @override
  Future<TradePortfolioList> getTradePortfolios(String userId) async {
    AppLogger.methodEntry('getTradePortfolios', tag: 'TradeRepository', params: {'userId': userId});

    try {
      final dto = await _remoteDataSource.getTradePortfolios(userId);
      final portfolioList = TradePortfolioMapper.fromListDto(dto, userId);

      _cachedPortfolioList = portfolioList;
      _portfoliosController.add(portfolioList);

      AppLogger.info('Trade portfolios fetched successfully', tag: 'TradeRepository');
      AppLogger.methodExit('getTradePortfolios', tag: 'TradeRepository', result: 'success');

      return portfolioList;
    } catch (e) {
      AppLogger.error(
        'Failed to fetch trade portfolios',
        tag: 'TradeRepository',
        error: e,
        stackTrace: StackTrace.current,
      );
      AppLogger.methodExit('getTradePortfolios', tag: 'TradeRepository', result: 'error');

      if (_cachedPortfolioList != null) {
        AppLogger.info('Returning cached trade portfolios', tag: 'TradeRepository');
        return _cachedPortfolioList!;
      }

      rethrow;
    }
  }

  @override
  Future<TradeHoldings> getTradeHoldings(String userId, String portfolioId) async {
    AppLogger.methodEntry(
      'getTradeHoldings',
      tag: 'TradeRepository',
      params: {'userId': userId, 'portfolioId': portfolioId},
    );

    try {
      final dto = await _remoteDataSource.getTradeHoldings(userId, portfolioId);
      final holdings = TradeHoldingMapper.fromListDto(dto, userId, portfolioId);

      _cachedHoldings = holdings;
      _holdingsController.add(holdings);

      AppLogger.info('Trade holdings fetched successfully', tag: 'TradeRepository');
      AppLogger.methodExit('getTradeHoldings', tag: 'TradeRepository', result: 'success');

      return holdings;
    } catch (e) {
      AppLogger.error(
        'Failed to fetch trade holdings',
        tag: 'TradeRepository',
        error: e,
        stackTrace: StackTrace.current,
      );
      AppLogger.methodExit('getTradeHoldings', tag: 'TradeRepository', result: 'error');

      if (_cachedHoldings != null) {
        AppLogger.info('Returning cached trade holdings', tag: 'TradeRepository');
        return _cachedHoldings!;
      }

      rethrow;
    }
  }

  @override
  Future<TradeSummary> getTradeSummary(String userId, String portfolioId) async {
    AppLogger.methodEntry(
      'getTradeSummary',
      tag: 'TradeRepository',
      params: {'userId': userId, 'portfolioId': portfolioId},
    );

    try {
      final dto = await _remoteDataSource.getTradeSummary(userId, portfolioId);
      final summary = TradeSummaryMapper.fromPortfolioSummaryDto(dto);

      _cachedSummary = summary;
      _summaryController.add(summary);

      AppLogger.info('Trade summary fetched successfully', tag: 'TradeRepository');
      AppLogger.methodExit('getTradeSummary', tag: 'TradeRepository', result: 'success');

      return summary;
    } catch (e) {
      AppLogger.error(
        'Failed to fetch trade summary',
        tag: 'TradeRepository',
        error: e,
        stackTrace: StackTrace.current,
      );
      AppLogger.methodExit('getTradeSummary', tag: 'TradeRepository', result: 'error');

      if (_cachedSummary != null) {
        AppLogger.info('Returning cached trade summary', tag: 'TradeRepository');
        return _cachedSummary!;
      }

      rethrow;
    }
  }

  @override
  Future<TradeCalendar> getTradeCalendar(String userId, String portfolioId, {int? year, int? month}) async {
    AppLogger.methodEntry(
      'getTradeCalendar',
      tag: 'TradeRepository',
      params: {'userId': userId, 'portfolioId': portfolioId, 'year': year, 'month': month},
    );

    try {
      final dto = await _remoteDataSource.getTradeCalendar(userId, portfolioId, year: year, month: month);
      final calendar = TradeCalendarMapper.fromDto(dto);

      _cachedCalendar = calendar;
      _calendarController.add(calendar);

      AppLogger.info('Trade calendar fetched successfully', tag: 'TradeRepository');
      AppLogger.methodExit('getTradeCalendar', tag: 'TradeRepository', result: 'success');

      return calendar;
    } catch (e) {
      AppLogger.error(
        'Failed to fetch trade calendar',
        tag: 'TradeRepository',
        error: e,
        stackTrace: StackTrace.current,
      );
      AppLogger.methodExit('getTradeCalendar', tag: 'TradeRepository', result: 'error');

      if (_cachedCalendar != null) {
        AppLogger.info('Returning cached trade calendar', tag: 'TradeRepository');
        return _cachedCalendar!;
      }

      rethrow;
    }
  }

  @override
  Stream<TradeHoldings> watchTradeHoldings(String userId, String portfolioId) {
    AppLogger.methodEntry(
      'watchTradeHoldings',
      tag: 'TradeRepository',
      params: {'userId': userId, 'portfolioId': portfolioId},
    );

    if (_cachedHoldings != null) {
      Future.microtask(() => _holdingsController.add(_cachedHoldings!));
    } else {
      getTradeHoldings(userId, portfolioId).catchError((error) {
        AppLogger.error('Failed to fetch initial holdings for stream', tag: 'TradeRepository', error: error);
        return TradeHoldings.empty(userId, portfolioId);
      });
    }

    return _holdingsController.stream;
  }

  @override
  Stream<TradePortfolioList> watchTradePortfolios(String userId) {
    AppLogger.methodEntry('watchTradePortfolios', tag: 'TradeRepository', params: {'userId': userId});

    if (_cachedPortfolioList != null) {
      Future.microtask(() => _portfoliosController.add(_cachedPortfolioList!));
    } else {
      getTradePortfolios(userId).catchError((error) {
        AppLogger.error('Failed to fetch initial portfolios for stream', tag: 'TradeRepository', error: error);
        return TradePortfolioList.empty(userId);
      });
    }

    return _portfoliosController.stream;
  }

  @override
  Stream<TradeSummary> watchTradeSummary(String userId, String portfolioId) {
    AppLogger.methodEntry(
      'watchTradeSummary',
      tag: 'TradeRepository',
      params: {'userId': userId, 'portfolioId': portfolioId},
    );

    if (_cachedSummary != null) {
      Future.microtask(() => _summaryController.add(_cachedSummary!));
    } else {
      getTradeSummary(userId, portfolioId).catchError((error) {
        AppLogger.error('Failed to fetch initial summary for stream', tag: 'TradeRepository', error: error);
        return TradeSummary.empty(portfolioId, userId);
      });
    }

    return _summaryController.stream;
  }

  @override
  Stream<TradeCalendar> watchTradeCalendar(String userId, String portfolioId) {
    AppLogger.methodEntry(
      'watchTradeCalendar',
      tag: 'TradeRepository',
      params: {'userId': userId, 'portfolioId': portfolioId},
    );

    if (_cachedCalendar != null) {
      Future.microtask(() => _calendarController.add(_cachedCalendar!));
    } else {
      getTradeCalendar(userId, portfolioId).catchError((error) {
        AppLogger.error('Failed to fetch initial calendar for stream', tag: 'TradeRepository', error: error);
        return TradeCalendar.empty(userId, portfolioId);
      });
    }

    return _calendarController.stream;
  }

  /// Dispose method to clean up resources
  void dispose() {
    AppLogger.methodEntry('dispose', tag: 'TradeRepository');

    _portfoliosController.close();
    _holdingsController.close();
    _summaryController.close();
    _calendarController.close();
    _cachedPortfolioList = null;
    _cachedHoldings = null;
    _cachedSummary = null;
    _cachedCalendar = null;

    AppLogger.info('TradeRepository disposed', tag: 'TradeRepository');
  }
}
