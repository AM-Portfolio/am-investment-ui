import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network/api_client.dart';
import '../internal/data/datasources/trade_datasource.dart';
import '../internal/data/mappers/trade_mappers.dart';
import '../internal/data/repositories/trade_repository_impl.dart';
import '../internal/domain/repositories/trade_repository.dart';
import '../internal/domain/usecases/trade_usecases.dart';
import '../internal/services/trade_service.dart';
import '../presentation/cubit/trade_cubit.dart';

part 'trade_providers.g.dart';

// Data layer providers (same pattern as portfolio)
@riverpod
TradeDataSource tradeDataSource(TradeDataSourceRef ref) {
  final apiClient = ref.watch(apiClientProvider);
  return TradeDataSourceImpl(apiClient: apiClient);
}

@riverpod
TradeMappers tradeMappers(TradeMappersRef ref) {
  return TradeMappers();
}

@riverpod
TradeRepository tradeRepository(TradeRepositoryRef ref) {
  final dataSource = ref.watch(tradeDataSourceProvider);
  final mappers = ref.watch(tradeMappersProvider);
  return TradeRepositoryImpl(dataSource: dataSource, mappers: mappers);
}

// Use case providers (complete set following portfolio pattern)
@riverpod
GetPortfoliosByOwnerUseCase getPortfoliosByOwnerUseCase(GetPortfoliosByOwnerUseCaseRef ref) {
  final repository = ref.watch(tradeRepositoryProvider);
  return GetPortfoliosByOwnerUseCase(repository);
}

@riverpod
GetPortfolioSummaryUseCase getPortfolioSummaryUseCase(GetPortfolioSummaryUseCaseRef ref) {
  final repository = ref.watch(tradeRepositoryProvider);
  return GetPortfolioSummaryUseCase(repository);
}

@riverpod
GetTradeHoldingsUseCase getTradeHoldingsUseCase(GetTradeHoldingsUseCaseRef ref) {
  final repository = ref.watch(tradeRepositoryProvider);
  return GetTradeHoldingsUseCase(repository);
}

@riverpod
GetTradeDetailsByIdsUseCase getTradeDetailsByIdsUseCase(GetTradeDetailsByIdsUseCaseRef ref) {
  final repository = ref.watch(tradeRepositoryProvider);
  return GetTradeDetailsByIdsUseCase(repository);
}

@riverpod
SearchTradesUseCase searchTradesUseCase(SearchTradesUseCaseRef ref) {
  final repository = ref.watch(tradeRepositoryProvider);
  return SearchTradesUseCase(repository);
}

@riverpod
RefreshPortfolioDataUseCase refreshPortfolioDataUseCase(RefreshPortfolioDataUseCaseRef ref) {
  final repository = ref.watch(tradeRepositoryProvider);
  return RefreshPortfolioDataUseCase(repository);
}

@riverpod
ClearCacheUseCase clearCacheUseCase(ClearCacheUseCaseRef ref) {
  final repository = ref.watch(tradeRepositoryProvider);
  return ClearCacheUseCase(repository);
}

@riverpod
GetTotalTradeCountUseCase getTotalTradeCountUseCase(GetTotalTradeCountUseCaseRef ref) {
  final repository = ref.watch(tradeRepositoryProvider);
  return GetTotalTradeCountUseCase(repository);
}

// Cubit provider with all use cases (same pattern as portfolio)
@riverpod
TradeCubit tradeCubit(TradeCubitRef ref) {
  return TradeCubit(
    getPortfoliosByOwner: ref.watch(getPortfoliosByOwnerUseCaseProvider),
    getPortfolioSummary: ref.watch(getPortfolioSummaryUseCaseProvider),
    getTradeHoldings: ref.watch(getTradeHoldingsUseCaseProvider),
    getTradeDetails: ref.watch(getTradeDetailsByIdsUseCaseProvider),
    searchTrades: ref.watch(searchTradesUseCaseProvider),
    refreshPortfolioData: ref.watch(refreshPortfolioDataUseCaseProvider),
    clearCache: ref.watch(clearCacheUseCaseProvider),
    getTotalTradeCount: ref.watch(getTotalTradeCountUseCaseProvider),
  );
}

// Service provider (same pattern as portfolio)
@riverpod
TradeService tradeService(TradeServiceRef ref) {
  return TradeService(
    getPortfoliosByOwner: ref.watch(getPortfoliosByOwnerUseCaseProvider),
    getPortfolioSummary: ref.watch(getPortfolioSummaryUseCaseProvider),
    getTradeHoldings: ref.watch(getTradeHoldingsUseCaseProvider),
    getTradeDetailsByIds: ref.watch(getTradeDetailsByIdsUseCaseProvider),
    getCalendarData: ref.watch(getCalendarDataUseCaseProvider),
    searchTrades: ref.watch(searchTradesUseCaseProvider),
    calculatePerformance: ref.watch(calculatePortfolioPerformanceUseCaseProvider),
  );
}

// State Management Providers (Cubits)
@riverpod
TradeSummaryCubit tradeSummaryCubit(
  TradeSummaryCubitRef ref,
  String portfolioId,
) {
  final getPortfolioSummary = ref.watch(getPortfolioSummaryUseCaseProvider);
  final calculatePerformance = ref.watch(
    calculatePortfolioPerformanceUseCaseProvider,
  );

  return TradeSummaryCubit(
    portfolioId: portfolioId,
    getPortfolioSummary: getPortfolioSummary,
    calculatePerformance: calculatePerformance,
  );
}

@riverpod
TradeHoldingsCubit tradeHoldingsCubit(
  TradeHoldingsCubitRef ref,
  String portfolioId,
) {
  final getTradeHoldings = ref.watch(getTradeHoldingsUseCaseProvider);
  final getTradeDetails = ref.watch(getTradeDetailsByIdsUseCaseProvider);
  final searchTrades = ref.watch(searchTradesUseCaseProvider);

  return TradeHoldingsCubit(
    portfolioId: portfolioId,
    getTradeHoldings: getTradeHoldings,
    getTradeDetails: getTradeDetails,
    searchTrades: searchTrades,
  );
}

@riverpod
TradeCalendarCubit tradeCalendarCubit(
  TradeCalendarCubitRef ref,
  String portfolioId,
) {
  final getCalendarData = ref.watch(getCalendarDataUseCaseProvider);
  final getTradeDetails = ref.watch(getTradeDetailsByIdsUseCaseProvider);

  return TradeCalendarCubit(
    portfolioId: portfolioId,
    getCalendarData: getCalendarData,
    getTradeDetails: getTradeDetails,
  );
}

// Convenience Provider for Complete Portfolio Analysis
@riverpod
Future<CompletePortfolioAnalysis> completePortfolioAnalysis(
  CompletePortfolioAnalysisRef ref,
  String portfolioId,
) async {
  final tradeService = ref.watch(tradeServiceProvider);
  return tradeService.getCompletePortfolioAnalysis(portfolioId);
}

// Provider for Trade Discovery
@riverpod
Future<TradeDiscoveryResult> tradeDiscovery(
  TradeDiscoveryRef ref,
  String ownerId,
) async {
  final tradeService = ref.watch(tradeServiceProvider);
  return tradeService.discoverTradeOpportunities(ownerId);
}

// Provider for Calendar Analysis
@riverpod
Future<CalendarAnalysisResult> calendarAnalysis(
  CalendarAnalysisRef ref, {
  required String portfolioId,
  required CalendarViewType viewType,
  required DateTime startDate,
  required DateTime endDate,
}) async {
  final tradeService = ref.watch(tradeServiceProvider);
  return tradeService.getCalendarAnalysisWithDetails(
    portfolioId: portfolioId,
    viewType: viewType,
    startDate: startDate,
    endDate: endDate,
  );
}
