import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/config_service.dart';
import '../../../core/network/api_client.dart';
import '../internal/data/datasources/trade_remote_data_source.dart';
import '../internal/data/repositories/trade_repository_impl.dart';
import '../internal/domain/entities/trade_calendar.dart';
import '../internal/domain/entities/trade_holding.dart';
import '../internal/domain/entities/trade_portfolio.dart';
import '../internal/domain/entities/trade_summary.dart';
import '../internal/domain/repositories/trade_repository.dart';
import '../internal/domain/usecases/get_trade_calendar.dart';
import '../internal/domain/usecases/get_trade_holdings.dart';
import '../internal/domain/usecases/get_trade_portfolios.dart';
import '../internal/domain/usecases/get_trade_summary.dart';
import '../presentation/models/trade_calendar_view_model.dart';
import '../presentation/models/trade_holding_view_model.dart';
import '../presentation/models/trade_portfolio_view_model.dart';

/// Provider for API client
final _apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

/// Provider for trade remote data source
final _tradeRemoteDataSourceProvider = Provider<TradeRemoteDataSource>((ref) {
  final apiClient = ref.watch(_apiClientProvider);
  final apiConfig = ConfigService.config.api;

  return TradeRemoteDataSourceImpl(apiClient: apiClient, apiConfig: apiConfig);
});

/// Provider for trade repository
final _tradeRepositoryProvider = Provider<TradeRepository>((ref) {
  final remoteDataSource = ref.watch(_tradeRemoteDataSourceProvider);

  return TradeRepositoryImpl(remoteDataSource: remoteDataSource);
});

/// Provider for GetTradePortfolios use case
final _getTradePortfoliosProvider = Provider<GetTradePortfolios>((ref) {
  final repository = ref.watch(_tradeRepositoryProvider);
  return GetTradePortfolios(repository);
});

/// Provider for GetTradeHoldings use case
final _getTradeHoldingsProvider = Provider<GetTradeHoldings>((ref) {
  final repository = ref.watch(_tradeRepositoryProvider);
  return GetTradeHoldings(repository);
});

/// Provider for GetTradeSummary use case
final _getTradeSummaryProvider = Provider<GetTradeSummary>((ref) {
  final repository = ref.watch(_tradeRepositoryProvider);
  return GetTradeSummary(repository);
});

/// Provider for GetTradeCalendar use case (private)
final _getTradeCalendarProvider = Provider<GetTradeCalendar>((ref) {
  final repository = ref.watch(_tradeRepositoryProvider);
  return GetTradeCalendar(repository);
});

/// Provider for GetTradeCalendar use case (public)
final getTradeCalendarProvider = Provider<GetTradeCalendar>((ref) {
  final repository = ref.watch(_tradeRepositoryProvider);
  return GetTradeCalendar(repository);
});

/// Provider for trade portfolios list
final tradePortfoliosProvider =
    FutureProvider.family<TradePortfolioList, String>((ref, userId) async {
      final useCase = ref.watch(_getTradePortfoliosProvider);
      return useCase(userId);
    });

/// Provider for trade holdings
final tradeHoldingsProvider =
    FutureProvider.family<TradeHoldings, ({String userId, String portfolioId})>(
      (ref, params) async {
        final useCase = ref.watch(_getTradeHoldingsProvider);
        return useCase(params.userId, params.portfolioId);
      },
    );

/// Provider for trade summary
final tradeSummaryProvider =
    FutureProvider.family<TradeSummary, ({String userId, String portfolioId})>((
      ref,
      params,
    ) async {
      final useCase = ref.watch(_getTradeSummaryProvider);
      return useCase(params.userId, params.portfolioId);
    });

/// Provider for trade calendar
final tradeCalendarProvider =
    FutureProvider.family<TradeCalendar, ({String userId, String portfolioId})>(
      (ref, params) async {
        final useCase = ref.watch(_getTradeCalendarProvider);
        return useCase(params.userId, params.portfolioId);
      },
    );

/// Provider for watching trade holdings (stream) - returns view models
final tradeHoldingsStreamProvider =
    StreamProvider.family<
      TradeHoldingsViewModel,
      ({String userId, String portfolioId})
    >((ref, params) {
      final useCase = ref.watch(_getTradeHoldingsProvider);
      return useCase
          .watch(params.userId, params.portfolioId)
          .map(TradeHoldingsViewModel.fromEntity);
    });

/// Provider for watching trade summary (stream)
final tradeSummaryStreamProvider =
    StreamProvider.family<TradeSummary, ({String userId, String portfolioId})>((
      ref,
      params,
    ) {
      final useCase = ref.watch(_getTradeSummaryProvider);
      return useCase.watch(params.userId, params.portfolioId);
    });

/// Provider for watching trade portfolios (stream) - returns view models
final tradePortfoliosStreamProvider =
    StreamProvider.family<List<TradePortfolioViewModel>, String>((ref, userId) {
      final useCase = ref.watch(_getTradePortfoliosProvider);
      return useCase
          .watch(userId)
          .map(
            (list) => TradePortfolioViewModel.fromEntityList(list.portfolios),
          );
    });

/// Provider for watching trade calendar (stream) - returns view models
final tradeCalendarStreamProvider =
    StreamProvider.family<
      TradeCalendarViewModel,
      ({String userId, String portfolioId})
    >((ref, params) {
      final useCase = ref.watch(_getTradeCalendarProvider);
      return useCase
          .watch(params.userId, params.portfolioId)
          .map(TradeCalendarViewModel.fromEntity);
    });
