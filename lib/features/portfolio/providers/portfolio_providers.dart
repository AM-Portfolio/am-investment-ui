import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../internal/domain/entities/portfolio_holding.dart';
import '../internal/domain/entities/portfolio_summary.dart';
import '../internal/domain/repositories/portfolio_repository.dart';
import '../internal/domain/usecases/get_portfolio_holdings.dart';
import '../internal/domain/usecases/get_portfolio_summary.dart';
import '../internal/domain/usecases/analyze_portfolio_performance.dart';
import '../internal/domain/usecases/refresh_portfolio_data.dart';
import '../internal/domain/usecases/search_portfolio_holdings.dart';
import '../internal/data/repositories/portfolio_repository_impl.dart';
import '../internal/data/datasources/portfolio_remote_data_source.dart';
import '../internal/services/portfolio_service.dart';
import '../../../di/app_providers.dart';

part 'portfolio_providers.g.dart';

/// Portfolio feature providers
/// These providers are specific to the portfolio feature and follow clean architecture.
/// They manage the portfolio feature's internal dependencies and use cases.

/// Data layer providers
@riverpod
PortfolioRemoteDataSource portfolioRemoteDataSource(PortfolioRemoteDataSourceRef ref) {
  return PortfolioRemoteDataSource();
}

@riverpod
PortfolioRepository portfolioRepository(PortfolioRepositoryRef ref) {
  final remoteDataSource = ref.watch(portfolioRemoteDataSourceProvider);
  return PortfolioRepositoryImpl(remoteDataSource: remoteDataSource);
}

/// Use case providers
@riverpod
GetPortfolioHoldings getPortfolioHoldings(GetPortfolioHoldingsRef ref) {
  final repository = ref.watch(portfolioRepositoryProvider);
  return GetPortfolioHoldings(repository);
}

@riverpod
GetPortfolioSummary getPortfolioSummary(GetPortfolioSummaryRef ref) {
  final repository = ref.watch(portfolioRepositoryProvider);
  return GetPortfolioSummary(repository);
}

@riverpod
AnalyzePortfolioPerformance analyzePortfolioPerformance(AnalyzePortfolioPerformanceRef ref) {
  final repository = ref.watch(portfolioRepositoryProvider);
  return AnalyzePortfolioPerformance(repository);
}

@riverpod
RefreshPortfolioData refreshPortfolioData(RefreshPortfolioDataRef ref) {
  final repository = ref.watch(portfolioRepositoryProvider);
  return RefreshPortfolioData(repository);
}

@riverpod
SearchPortfolioHoldings searchPortfolioHoldings(SearchPortfolioHoldingsRef ref) {
  final repository = ref.watch(portfolioRepositoryProvider);
  return SearchPortfolioHoldings(repository);
}

/// Service layer providers
@riverpod
PortfolioService portfolioService(PortfolioServiceRef ref) {
  final getHoldings = ref.watch(getPortfolioHoldingsProvider);
  final getSummary = ref.watch(getPortfolioSummaryProvider);
  final refreshData = ref.watch(refreshPortfolioDataProvider);
  final analyzePerformance = ref.watch(analyzePortfolioPerformanceProvider);
  final searchHoldings = ref.watch(searchPortfolioHoldingsProvider);
  
  return PortfolioService(
    getHoldings,
    getSummary,
    refreshData,
    analyzePerformance,
    searchHoldings,
  );
}

/// Data providers - Auto-dispose (can be recreated when needed)
@riverpod
Future<PortfolioHoldings> portfolioHoldings(PortfolioHoldingsRef ref, String userId) async {
  final useCase = ref.watch(getPortfolioHoldingsProvider);
  return await useCase(userId);
}

@riverpod
Future<PortfolioSummary> portfolioSummary(PortfolioSummaryRef ref, String userId) async {
  final useCase = ref.watch(getPortfolioSummaryProvider);
  return await useCase(userId);
}

@riverpod
Stream<PortfolioHoldings> portfolioHoldingsStream(PortfolioHoldingsStreamRef ref, String userId) async* {
  final useCase = ref.watch(getPortfolioHoldingsProvider);
  yield* useCase.watchHoldings(userId);
}

@riverpod
Stream<PortfolioSummary> portfolioSummaryStream(PortfolioSummaryStreamRef ref, String userId) async* {
  final useCase = ref.watch(getPortfolioSummaryProvider);
  yield* useCase.watchSummary(userId);
}

@riverpod
Future<List<PortfolioHolding>> searchResults(SearchResultsRef ref, String userId, String query) async {
  final useCase = ref.watch(searchPortfolioHoldingsProvider);
  return await useCase(userId, query);
}

@riverpod
Future<List<TopPerformer>> topPerformers(TopPerformersRef ref, String userId, {int limit = 5}) async {
  final useCase = ref.watch(analyzePortfolioPerformanceProvider);
  return await useCase.getTopPerformers(userId, limit: limit);
}

@riverpod
Future<List<SectorAllocation>> sectorAllocation(SectorAllocationRef ref, String userId) async {
  final useCase = ref.watch(analyzePortfolioPerformanceProvider);
  return await useCase.getSectorAllocation(userId);
}