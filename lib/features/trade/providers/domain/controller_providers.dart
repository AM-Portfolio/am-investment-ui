/// Trade controller domain providers
/// 
/// This file contains public API providers for trade CRUD operations,
/// filtering, and batch updates.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../internal/data/dtos/metrics_filter_config_dto.dart';
import '../../internal/domain/entities/trade_controller_entities.dart';
import '../../internal/domain/entities/trade_holding.dart';
import '../../internal/domain/entities/trade_portfolio.dart';
import '../../internal/domain/entities/trade_summary.dart';
import '../../internal/domain/usecases/get_trade_holdings.dart';
import '../../internal/domain/usecases/get_trade_portfolios.dart';
import '../../internal/domain/usecases/get_trade_summary.dart';
import '../../presentation/models/trade_holding_view_model.dart';
import '../../presentation/models/trade_portfolio_view_model.dart';
import '../infrastructure/repository_providers.dart';

// ============================================================================
// Use Case Providers (Private)
// ============================================================================

/// Provider for GetTradePortfolios use case
final _getTradePortfoliosProvider = Provider<GetTradePortfolios>((ref) {
  final repository = ref.watch(tradeRepositoryProvider);
  return GetTradePortfolios(repository);
});

/// Provider for GetTradeHoldings use case
final _getTradeHoldingsProvider = Provider<GetTradeHoldings>((ref) {
  final repository = ref.watch(tradeRepositoryProvider);
  return GetTradeHoldings(repository);
});

/// Provider for GetTradeSummary use case
final _getTradeSummaryProvider = Provider<GetTradeSummary>((ref) {
  final repository = ref.watch(tradeRepositoryProvider);
  return GetTradeSummary(repository);
});

// ============================================================================
// Public Query Providers
// ============================================================================

/// Provider to get trade details by portfolio ID and optional symbols
final tradeDetailsByPortfolioProvider =
    FutureProvider.family<List<TradeDetails>, ({String portfolioId, List<String>? symbols})>((ref, params) async {
      final repository = ref.watch(tradeControllerRepositoryProvider);
      return repository.getTradeDetailsByPortfolioAndSymbols(portfolioId: params.portfolioId, symbols: params.symbols);
    });

/// Provider to watch trade details for a portfolio with real-time updates
final watchTradesByPortfolioProvider = StreamProvider.family<List<TradeDetails>, String>((ref, portfolioId) {
  final repository = ref.watch(tradeControllerRepositoryProvider);
  return repository.watchTradeDetailsByPortfolio(portfolioId);
});

/// Provider to get trades by various filter criteria with pagination
final tradesByFiltersProvider =
    FutureProvider.family<
      PaginatedTradeResponse,
      ({
        List<String>? portfolioIds,
        List<String>? symbols,
        List<String>? statuses,
        DateTime? startDate,
        DateTime? endDate,
        List<String>? strategies,
        int page,
        int size,
        String? sort,
      })
    >((ref, params) async {
      final repository = ref.watch(tradeControllerRepositoryProvider);
      return repository.getTradesByFilters(
        portfolioIds: params.portfolioIds,
        symbols: params.symbols,
        statuses: params.statuses,
        startDate: params.startDate,
        endDate: params.endDate,
        strategies: params.strategies,
        page: params.page,
        size: params.size,
        sort: params.sort,
      );
    });

/// Provider to get trade details by trade IDs
final tradeDetailsByIdsProvider = FutureProvider.family<List<TradeDetails>, List<String>>((ref, tradeIds) async {
  final repository = ref.watch(tradeControllerRepositoryProvider);
  return repository.getTradeDetailsByTradeIds(tradeIds);
});

/// Provider to filter trade details using favorite filter or metrics config
final filterTradeDetailsProvider =
    FutureProvider.family<
      FilterTradeDetailsResponse,
      ({
        String userId,
        String? favoriteFilterId,
        MetricsFilterConfigDto? metricsConfig,
        int page,
        int size,
        String? sort,
      })
    >((ref, params) async {
      final repository = ref.watch(tradeControllerRepositoryProvider);
      return repository.filterTradeDetails(
        userId: params.userId,
        favoriteFilterId: params.favoriteFilterId,
        metricsConfig: params.metricsConfig,
        page: params.page,
        size: params.size,
        sort: params.sort,
      );
    });

/// Provider for trade portfolios list
final tradePortfoliosProvider = FutureProvider.family<TradePortfolioList, String>((ref, userId) async {
  final useCase = ref.watch(_getTradePortfoliosProvider);
  return useCase(userId);
});

/// Provider for trade holdings
final tradeHoldingsProvider = FutureProvider.family<TradeHoldings, ({String userId, String portfolioId})>((
  ref,
  params,
) async {
  final useCase = ref.watch(_getTradeHoldingsProvider);
  return useCase(params.userId, params.portfolioId);
});

/// Provider for trade summary
final tradeSummaryProvider = FutureProvider.family<TradeSummary, ({String userId, String portfolioId})>((
  ref,
  params,
) async {
  final useCase = ref.watch(_getTradeSummaryProvider);
  return useCase(params.userId, params.portfolioId);
});

/// Provider for watching trade holdings (stream) - returns view models
final tradeHoldingsStreamProvider =
    StreamProvider.family<TradeHoldingsViewModel, ({String userId, String portfolioId})>((ref, params) {
      final useCase = ref.watch(_getTradeHoldingsProvider);
      return useCase.watch(params.userId, params.portfolioId).map(TradeHoldingsViewModel.fromEntity);
    });

/// Provider for watching trade summary (stream)
final tradeSummaryStreamProvider = StreamProvider.family<TradeSummary, ({String userId, String portfolioId})>((
  ref,
  params,
) {
  final useCase = ref.watch(_getTradeSummaryProvider);
  return useCase.watch(params.userId, params.portfolioId);
});

/// Provider for watching trade portfolios (stream) - returns view models
final tradePortfoliosStreamProvider = StreamProvider.family<List<TradePortfolioViewModel>, String>((ref, userId) {
  final useCase = ref.watch(_getTradePortfoliosProvider);
  return useCase.watch(userId).map((list) => TradePortfolioViewModel.fromEntityList(list.portfolios));
});

// ============================================================================
// Action Providers (For mutation operations)
// ============================================================================

/// Provider to add a new trade
final addTradeProvider = Provider<Future<TradeDetails> Function(TradeDetails)>((ref) {
  final repository = ref.watch(tradeControllerRepositoryProvider);
  return (tradeDetails) async {
    final result = await repository.addTrade(tradeDetails);
    // Invalidate related providers to trigger refresh
    ref.invalidate(tradeDetailsByPortfolioProvider);
    ref.invalidate(watchTradesByPortfolioProvider);
    return result;
  };
});

/// Provider to update an existing trade
final updateTradeProvider = Provider<Future<TradeDetails> Function(({String tradeId, TradeDetails tradeDetails}))>((
  ref,
) {
  final repository = ref.watch(tradeControllerRepositoryProvider);
  return (params) async {
    final result = await repository.updateTrade(tradeId: params.tradeId, tradeDetails: params.tradeDetails);
    // Invalidate related providers to trigger refresh
    ref.invalidate(tradeDetailsByPortfolioProvider);
    ref.invalidate(watchTradesByPortfolioProvider);
    return result;
  };
});

/// Provider to add or update multiple trades in batch
final batchUpdateTradesProvider = Provider<Future<List<TradeDetails>> Function(List<TradeDetails>)>((ref) {
  final repository = ref.watch(tradeControllerRepositoryProvider);
  return (trades) async {
    final result = await repository.addOrUpdateTrades(trades);
    // Invalidate related providers to trigger refresh
    ref.invalidate(tradeDetailsByPortfolioProvider);
    ref.invalidate(watchTradesByPortfolioProvider);
    return result;
  };
});

/// Provider to clear repository cache
final clearTradeCacheProvider = Provider<Future<void> Function()>((ref) {
  final repository = ref.watch(tradeControllerRepositoryProvider);
  return () async {
    await repository.clearCache();
    // Invalidate all providers to trigger refresh
    ref.invalidate(tradeDetailsByPortfolioProvider);
    ref.invalidate(watchTradesByPortfolioProvider);
    ref.invalidate(tradesByFiltersProvider);
    ref.invalidate(tradeDetailsByIdsProvider);
    ref.invalidate(filterTradeDetailsProvider);
  };
});

/// Provider to refresh trades for a specific portfolio
final refreshPortfolioTradesProvider = Provider<Future<void> Function(String)>((ref) {
  final repository = ref.watch(tradeControllerRepositoryProvider);
  return (portfolioId) async {
    await repository.refreshPortfolioTrades(portfolioId);
    // Invalidate related providers for this portfolio
    ref.invalidate(tradeDetailsByPortfolioProvider);
    ref.invalidate(watchTradesByPortfolioProvider);
  };
});
