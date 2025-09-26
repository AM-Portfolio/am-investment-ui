import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/repositories/portfolio_repository_impl.dart';
import '../data/repositories/document_repository_impl.dart';
import '../domain/repositories/portfolio_repository.dart';
import '../domain/repositories/document_repository.dart';
import '../domain/entities/portfolio/portfolio_holdings.dart';
import '../domain/entities/portfolio/portfolio_summary.dart';
import '../domain/entities/document/document_upload.dart';
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
@riverpod
Future<DocumentUpload> documentStatus(DocumentStatusRef ref, String processId) async {
  final repository = ref.watch(documentRepositoryProvider);
  return repository.getDocumentStatus(processId);
}

@riverpod
Future<DocumentUploadCollection> documentHistory(DocumentHistoryRef ref, String userId) async {
  final repository = ref.watch(documentRepositoryProvider);
  return repository.getDocumentHistory(userId: userId);
}

@riverpod
Future<DocumentUploadCollection> documentHistoryFiltered(
  DocumentHistoryFilteredRef ref, 
  String userId, {
  DocumentCategory? category,
  DocumentProcessingStatus? status,
  int? limit,
  int? offset,
}) async {
  final repository = ref.watch(documentRepositoryProvider);
  return repository.getDocumentHistory(
    userId: userId,
    category: category,
    status: status,
    limit: limit,
    offset: offset,
  );
}

@riverpod
Stream<DocumentUpload> documentStatusStream(DocumentStatusStreamRef ref, String processId) {
  final repository = ref.watch(documentRepositoryProvider);
  return repository.documentStatusStream(processId);
}

@riverpod
Stream<DocumentUploadCollection> documentHistoryStream(DocumentHistoryStreamRef ref, String userId) {
  final repository = ref.watch(documentRepositoryProvider);
  return repository.documentHistoryStream(userId);
}

@riverpod
Future<Map<String, int>> documentStatistics(DocumentStatisticsRef ref, String userId) async {
  final repository = ref.watch(documentRepositoryProvider);
  return repository.getProcessingStatistics(userId);
}

// Cache Management Provider
@riverpod
Future<CacheManager> cacheManager(CacheManagerRef ref) async {
  final portfolioRepository = await ref.watch(portfolioRepositoryProvider.future);
  final documentRepository = ref.watch(documentRepositoryProvider);
  return CacheManager(portfolioRepository, documentRepository);
}

/// Helper class for cache management operations
class CacheManager {
  final PortfolioRepository _portfolioRepository;
  final DocumentRepository _documentRepository;
  
  CacheManager(this._portfolioRepository, this._documentRepository);
  
  Future<void> clearUserCache(String userId) async {
    await Future.wait([
      _portfolioRepository.clearAllCache(userId),
      _documentRepository.clearAllCache(userId),
    ]);
  }
  
  Future<void> refreshUserData(String userId) async {
    await Future.wait([
      _portfolioRepository.refreshPortfolioHoldings(userId),
      _portfolioRepository.refreshPortfolioSummary(userId),
      _documentRepository.refreshDocumentHistory(userId),
    ]);
  }
  
  bool isPortfolioHoldingsDataFresh(String userId) {
    return _portfolioRepository.isHoldingsCachedDataFresh(userId);
  }
  
  bool isPortfolioSummaryDataFresh(String userId) {
    return _portfolioRepository.isSummaryCachedDataFresh(userId);
  }
  
  bool isDocumentHistoryDataFresh(String userId) {
    return _documentRepository.isHistoryCachedDataFresh(userId);
  }
  
  bool isDocumentStatusDataFresh(String processId) {
    return _documentRepository.isDocumentCachedDataFresh(processId);
  }
  
  Future<void> clearDocumentCache(String processId) async {
    await _documentRepository.clearDocumentCache(processId);
  }
  
  Future<void> clearDocumentHistoryCache(String userId) async {
    await _documentRepository.clearHistoryCache(userId);
  }
}
