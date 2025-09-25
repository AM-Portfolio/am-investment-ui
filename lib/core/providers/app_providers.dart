import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/repositories/portfolio_repository_impl.dart';
import '../domain/repositories/portfolio_repository.dart';
import '../domain/entities/portfolio/portfolio_holdings.dart';
import '../domain/entities/portfolio/portfolio_summary.dart';
import '../services/api/portfolio_client.dart';
import '../config/app_config.dart';
import '../config/api_config.dart';

part 'app_providers.g.dart';

// Configuration Providers - Keep alive (singleton instances)
@Riverpod(keepAlive: true)
AppConfig appConfig(AppConfigRef ref) {
  return AppConfig.load(); // Load once, keep forever
}

@Riverpod(keepAlive: true)
ApiConfig apiConfig(ApiConfigRef ref) {
  final appConfig = ref.watch(appConfigProvider);
  return ApiConfig.fromAppConfig(appConfig);
}

@Riverpod(keepAlive: true)
PortfolioClient portfolioClient(PortfolioClientRef ref) {
  // Keep HTTP client alive to maintain connections
  final apiConfig = ref.watch(apiConfigProvider);
  return PortfolioClient(config: apiConfig);
}

// Repository Providers

@Riverpod(keepAlive: true)
PortfolioRepository portfolioRepository(PortfolioRepositoryRef ref) {
  final apiClient = ref.watch(portfolioClientProvider);
  return PortfolioRepositoryImpl(apiClient: apiClient);
}

// Data Providers - Auto-dispose (can be recreated when needed)
@riverpod
Future<PortfolioHoldings> portfolioHoldings(PortfolioHoldingsRef ref, String userId) async {
  // Can be disposed when not watched, refetched when needed
  final repository = ref.watch(portfolioRepositoryProvider);
  return repository.getPortfolioHoldings(userId);
}

@riverpod
Future<PortfolioSummary> portfolioSummary(PortfolioSummaryRef ref, String userId) async {
  final repository = ref.watch(portfolioRepositoryProvider);
  return repository.getPortfolioSummary(userId);
}

@riverpod
Stream<PortfolioHoldings> portfolioHoldingsStream(PortfolioHoldingsStreamRef ref, String userId) {
  final repository = ref.watch(portfolioRepositoryProvider);
  return repository.portfolioHoldingsUpdatesStream(userId);
}

@riverpod
Stream<PortfolioSummary> portfolioSummaryStream(PortfolioSummaryStreamRef ref, String userId) {
  final repository = ref.watch(portfolioRepositoryProvider);
  return repository.portfolioSummaryUpdatesStream(userId);
}

// Cache Management Provider

@riverpod
CacheManager cacheManager(CacheManagerRef ref) {
  final repository = ref.watch(portfolioRepositoryProvider);
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
