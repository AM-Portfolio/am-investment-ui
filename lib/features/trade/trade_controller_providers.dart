import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/app_config.dart';
import '../../config/config_service.dart';
import '../../core/network/api_client.dart';
import 'internal/data/datasources/trade_controller_remote_data_source.dart';
import 'internal/data/dtos/metrics_filter_config_dto.dart';
import 'internal/data/repositories/trade_controller_repository_impl.dart';
import 'internal/domain/entities/trade_controller_entities.dart';
import 'internal/domain/repositories/trade_controller_repository.dart';

// ============================================================================
// Infrastructure Providers (Private - for dependency injection)
// ============================================================================

/// Provider for ApiClient instance
final _apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

/// Provider for ApiConfig
final _apiConfigProvider = Provider<ApiConfig>((ref) => ConfigService.config.api);

/// Provider for TradeControllerRemoteDataSource
final _tradeControllerRemoteDataSourceProvider = Provider<TradeControllerRemoteDataSource>((ref) {
  final apiClient = ref.watch(_apiClientProvider);
  final apiConfig = ref.watch(_apiConfigProvider);

  return TradeControllerRemoteDataSourceImpl(apiClient: apiClient, tradeConfig: apiConfig.trade);
});

/// Provider for TradeControllerRepository
final _tradeControllerRepositoryProvider = Provider<TradeControllerRepository>((ref) {
  final remoteDataSource = ref.watch(_tradeControllerRemoteDataSourceProvider);

  return TradeControllerRepositoryImpl(remoteDataSource: remoteDataSource);
});

// ============================================================================
// Public Providers (For UI consumption)
// ============================================================================

/// Provider to get trade details by portfolio ID and optional symbols
/// Returns a FutureProvider with the list of trade details
final tradeDetailsByPortfolioProvider =
    FutureProvider.family<List<TradeDetails>, ({String portfolioId, List<String>? symbols})>((ref, params) async {
      final repository = ref.watch(_tradeControllerRepositoryProvider);
      return repository.getTradeDetailsByPortfolioAndSymbols(portfolioId: params.portfolioId, symbols: params.symbols);
    });

/// Provider to watch trade details for a portfolio with real-time updates
/// Returns a StreamProvider with trade details that update automatically
final watchTradesByPortfolioProvider = StreamProvider.family<List<TradeDetails>, String>((ref, portfolioId) {
  final repository = ref.watch(_tradeControllerRepositoryProvider);
  return repository.watchTradeDetailsByPortfolio(portfolioId);
});

/// Provider to get trades by various filter criteria with pagination
/// Returns a FutureProvider with paginated trade response
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
      final repository = ref.watch(_tradeControllerRepositoryProvider);
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
/// Returns a FutureProvider with the list of trade details
final tradeDetailsByIdsProvider = FutureProvider.family<List<TradeDetails>, List<String>>((ref, tradeIds) async {
  final repository = ref.watch(_tradeControllerRepositoryProvider);
  return repository.getTradeDetailsByTradeIds(tradeIds);
});

/// Provider to filter trade details using favorite filter or metrics config
/// Returns a FutureProvider with filtered trade details response
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
      final repository = ref.watch(_tradeControllerRepositoryProvider);
      return repository.filterTradeDetails(
        userId: params.userId,
        favoriteFilterId: params.favoriteFilterId,
        metricsConfig: params.metricsConfig,
        page: params.page,
        size: params.size,
        sort: params.sort,
      );
    });

// ============================================================================
// Action Providers (For mutation operations)
// ============================================================================

/// Provider to add a new trade
/// Usage: ref.read(addTradeProvider)(tradeDetails)
final addTradeProvider = Provider<Future<TradeDetails> Function(TradeDetails)>((ref) {
  final repository = ref.watch(_tradeControllerRepositoryProvider);
  return (tradeDetails) async {
    final result = await repository.addTrade(tradeDetails);
    // Invalidate related providers to trigger refresh
    ref.invalidate(tradeDetailsByPortfolioProvider);
    ref.invalidate(watchTradesByPortfolioProvider);
    return result;
  };
});

/// Provider to update an existing trade
/// Usage: ref.read(updateTradeProvider)((tradeId: '...', tradeDetails: ...))
final updateTradeProvider = Provider<Future<TradeDetails> Function(({String tradeId, TradeDetails tradeDetails}))>((
  ref,
) {
  final repository = ref.watch(_tradeControllerRepositoryProvider);
  return (params) async {
    final result = await repository.updateTrade(tradeId: params.tradeId, tradeDetails: params.tradeDetails);
    // Invalidate related providers to trigger refresh
    ref.invalidate(tradeDetailsByPortfolioProvider);
    ref.invalidate(watchTradesByPortfolioProvider);
    return result;
  };
});

/// Provider to add or update multiple trades in batch
/// Usage: ref.read(batchUpdateTradesProvider)(tradesList)
final batchUpdateTradesProvider = Provider<Future<List<TradeDetails>> Function(List<TradeDetails>)>((ref) {
  final repository = ref.watch(_tradeControllerRepositoryProvider);
  return (trades) async {
    final result = await repository.addOrUpdateTrades(trades);
    // Invalidate related providers to trigger refresh
    ref.invalidate(tradeDetailsByPortfolioProvider);
    ref.invalidate(watchTradesByPortfolioProvider);
    return result;
  };
});

/// Provider to clear repository cache
/// Usage: await ref.read(clearTradeCacheProvider)()
final clearTradeCacheProvider = Provider<Future<void> Function()>((ref) {
  final repository = ref.watch(_tradeControllerRepositoryProvider);
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
/// Usage: await ref.read(refreshPortfolioTradesProvider)(portfolioId)
final refreshPortfolioTradesProvider = Provider<Future<void> Function(String)>((ref) {
  final repository = ref.watch(_tradeControllerRepositoryProvider);
  return (portfolioId) async {
    await repository.refreshPortfolioTrades(portfolioId);
    // Invalidate related providers for this portfolio
    ref.invalidate(tradeDetailsByPortfolioProvider);
    ref.invalidate(watchTradesByPortfolioProvider);
  };
});
