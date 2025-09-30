import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../internal/domain/entities/portfolio_holding.dart';
import '../internal/domain/entities/portfolio_summary.dart';
import '../internal/domain/repositories/portfolio_repository.dart';
import '../internal/domain/usecases/get_portfolio_holdings.dart';
import '../internal/domain/usecases/get_portfolio_summary.dart';


import '../internal/data/repositories/portfolio_repository_impl.dart';
import '../internal/data/datasources/portfolio_remote_data_source.dart';
import '../internal/services/portfolio_service.dart';
import '../../../di/app_providers.dart';
import '../../../core/utils/logger.dart';

part 'portfolio_providers.g.dart';

/// Portfolio feature providers
/// These providers are specific to the portfolio feature and follow clean architecture.
/// They manage the portfolio feature's internal dependencies and use cases.

/// Data layer providers
@riverpod
Future<PortfolioRemoteDataSource> portfolioRemoteDataSource(PortfolioRemoteDataSourceRef ref) async {
  final apiClient = await ref.watch(apiClientProvider.future);
  final portfolioConfig = await ref.watch(portfolioApiConfigProvider.future);
  return PortfolioRemoteDataSourceImpl(
    apiClient: apiClient,
    portfolioConfig: portfolioConfig,
  );
}

@riverpod
Future<PortfolioRepository> portfolioRepository(PortfolioRepositoryRef ref) async {
  AppLogger.debug('Creating PortfolioRepository instance', tag: 'PortfolioProviders');
  final remoteDataSource = await ref.watch(portfolioRemoteDataSourceProvider.future);
  return PortfolioRepositoryImpl(remoteDataSource: remoteDataSource);
}

/// Use case providers
@riverpod
Future<GetPortfolioHoldings> getPortfolioHoldings(GetPortfolioHoldingsRef ref) async {
  AppLogger.debug('Creating GetPortfolioHoldings use case', tag: 'PortfolioProviders');
  final repository = await ref.watch(portfolioRepositoryProvider.future);
  return GetPortfolioHoldings(repository);
}

@riverpod
Future<GetPortfolioSummary> getPortfolioSummary(GetPortfolioSummaryRef ref) async {
  AppLogger.debug('Creating GetPortfolioSummary use case', tag: 'PortfolioProviders');
  final repository = await ref.watch(portfolioRepositoryProvider.future);
  return GetPortfolioSummary(repository);
}







/// Service layer providers
@riverpod
Future<PortfolioService> portfolioService(PortfolioServiceRef ref) async {
  AppLogger.debug('Creating PortfolioService instance', tag: 'PortfolioProviders');
  final getHoldings = await ref.watch(getPortfolioHoldingsProvider.future);
  final getSummary = await ref.watch(getPortfolioSummaryProvider.future);
  
  return PortfolioService(
    getHoldings,
    getSummary,
  );
}

/// Data providers - Auto-dispose (can be recreated when needed)
@riverpod
Future<PortfolioHoldings> portfolioHoldings(PortfolioHoldingsRef ref, String userId) async {
  final useCase = await ref.watch(getPortfolioHoldingsProvider.future);
  return await useCase.call(userId);
}

@riverpod
Future<PortfolioSummary> portfolioSummary(PortfolioSummaryRef ref, String userId) async {
  final useCase = await ref.watch(getPortfolioSummaryProvider.future);
  return await useCase.call(userId);
}

@riverpod
Stream<PortfolioHoldings> portfolioHoldingsStream(PortfolioHoldingsStreamRef ref, String userId) async* {
  final useCase = await ref.watch(getPortfolioHoldingsProvider.future);
  yield* useCase.watchHoldings(userId);
}

@riverpod
Stream<PortfolioSummary> portfolioSummaryStream(PortfolioSummaryStreamRef ref, String userId) async* {
  final useCase = await ref.watch(getPortfolioSummaryProvider.future);
  yield* useCase.watchSummary(userId);
}





