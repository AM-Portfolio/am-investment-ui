import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/repositories/portfolio_repository_impl.dart';
import '../domain/repositories/portfolio_repository.dart';
import '../domain/entities/portfolio/portfolio_holdings.dart';
import '../domain/entities/portfolio/portfolio_summary.dart';
import '../services/api/portfolio_client.dart';
import '../services/api/document_client.dart';
import '../services/document_upload_service.dart';
import '../config/app_config.dart';
import '../config/config_service.dart';
import '../config/environment_config.dart' as env_config;

part 'app_providers.g.dart';

// Configuration Providers - Keep alive (singleton instances)
@riverpod
Future<AppConfig> appConfig(AppConfigRef ref) async {
  // Initialize ConfigService if not already done
  await ConfigService.initialize();
  
  // Get configuration from ConfigService
  return ConfigService.config;
}

@riverpod
Future<String> apiBaseUrl(ApiBaseUrlRef ref) async {
  final config = await ref.watch(appConfigProvider.future);
  return config.api.baseUrl;
}

@Riverpod(keepAlive: true)
env_config.Environment environmentConfig(EnvironmentConfigRef ref) {
  return env_config.EnvironmentConfig.current; // Get current environment
}

@riverpod
Future<PortfolioClient> portfolioClient(PortfolioClientRef ref) async {
  // Keep HTTP client alive to maintain connections
  final config = await ref.watch(appConfigProvider.future);
  return PortfolioClient(
    baseUrl: config.api.baseUrl,
    useMockData: config.api.useMockData,
  );
}

// Repository Providers
@riverpod
Future<PortfolioRepository> portfolioRepository(PortfolioRepositoryRef ref) async {
  final apiClient = await ref.watch(portfolioClientProvider.future);
  return PortfolioRepositoryImpl(apiClient: apiClient);
}

// Data Providers - Auto-dispose (can be recreated when needed)
@riverpod
Future<PortfolioHoldings> portfolioHoldings(PortfolioHoldingsRef ref, String userId) async {
  // Can be disposed when not watched, refetched when needed
  final repository = await ref.watch(portfolioRepositoryProvider.future);
  return repository.getPortfolioHoldings(userId);
}

@riverpod
Future<PortfolioSummary> portfolioSummary(PortfolioSummaryRef ref, String userId) async {
  final repository = await ref.watch(portfolioRepositoryProvider.future);
  return repository.getPortfolioSummary(userId);
}

@riverpod
Stream<PortfolioHoldings> portfolioHoldingsStream(PortfolioHoldingsStreamRef ref, String userId) async* {
  final repository = await ref.watch(portfolioRepositoryProvider.future);
  yield* repository.portfolioHoldingsUpdatesStream(userId);
}

@riverpod
Stream<PortfolioSummary> portfolioSummaryStream(PortfolioSummaryStreamRef ref, String userId) async* {
  final repository = await ref.watch(portfolioRepositoryProvider.future);
  yield* repository.portfolioSummaryUpdatesStream(userId);
}

// Cache Management Provider
@riverpod
Future<CacheManager> cacheManager(CacheManagerRef ref) async {
  final repository = await ref.watch(portfolioRepositoryProvider.future);
  return CacheManager(repository);
}

/// Helper class for cache management operations
class CacheManager {
  final PortfolioRepository _repository;
  
  CacheManager(this._repository);
  
  Future<void> clearUserCache(String userId) async {
    await _repository.clearAllCache(userId);
  }
  
  Future<void> refreshUserData(String userId) async {
    await Future.wait([
      _repository.refreshPortfolioHoldings(userId),
      _repository.refreshPortfolioSummary(userId),
    ]);
  }
  
  bool isHoldingsDataFresh(String userId) {
    return _repository.isHoldingsCachedDataFresh(userId);
  }
  
  bool isSummaryDataFresh(String userId) {
    return _repository.isSummaryCachedDataFresh(userId);
  }
}
