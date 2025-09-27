import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/repositories/portfolio_repository_impl.dart';
import '../data/repositories/document_repository_impl.dart';
import '../domain/repositories/portfolio_repository.dart';
import '../domain/repositories/document_repository.dart';
import '../domain/entities/portfolio/portfolio_holdings.dart';
import '../domain/entities/portfolio/portfolio_summary.dart';
import '../services/api/portfolio_client.dart';
import '../services/api/document_client.dart';
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

@riverpod
DocumentClient documentClient(DocumentClientRef ref) {
  return ref.watch(documentClientProvider);
}

@riverpod
DocumentRepository documentRepository(DocumentRepositoryRef ref) {
  final apiClient = ref.watch(documentClientProvider);
  return DocumentRepositoryImpl(apiClient: apiClient);
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

// Document Providers - Auto-dispose (can be recreated when needed)
// Note: Current document API only supports upload, not status/history queries











// Cache Management Provider
@riverpod
Future<CacheManager> cacheManager(CacheManagerRef ref) async {
  final portfolioRepository = await ref.watch(portfolioRepositoryProvider.future);
  return CacheManager(portfolioRepository);
}

/// Helper class for cache management operations
/// Note: Document repository currently only supports upload, no caching functionality
class CacheManager {
  final PortfolioRepository _portfolioRepository;
  
  CacheManager(this._portfolioRepository);
  
  Future<void> clearUserCache(String userId) async {
    await Future.wait([
      _portfolioRepository.clearAllCache(userId),
      // Document repository doesn't have cache methods yet
    ]);
  }
  
  Future<void> refreshUserData(String userId) async {
    await Future.wait([
      _portfolioRepository.refreshPortfolioHoldings(userId),
      _portfolioRepository.refreshPortfolioSummary(userId),
      // Document repository doesn't have refresh methods yet
    ]);
  }
  
  bool isPortfolioHoldingsDataFresh(String userId) {
    return _portfolioRepository.isHoldingsCachedDataFresh(userId);
  }
  
  bool isPortfolioSummaryDataFresh(String userId) {
    return _portfolioRepository.isSummaryCachedDataFresh(userId);
  }
  
  // Document repository doesn't have cache checking methods yet
  bool isDocumentHistoryDataFresh(String userId) {
    return false; // Always return false as no caching implemented
  }
  
  bool isDocumentStatusDataFresh(String processId) {
    return false; // Always return false as no caching implemented
  }
  
  Future<void> clearDocumentCache(String processId) async {
    // No-op as document repository doesn't have cache methods yet
  }
  
  Future<void> clearDocumentHistoryCache(String userId) async {
    // No-op as document repository doesn't have cache methods yet
  }
}
