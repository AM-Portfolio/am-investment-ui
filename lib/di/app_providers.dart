import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:dio/dio.dart';
import '../core/app_logic/data/repositories/portfolio_repository_impl.dart';
import '../core/app_logic/data/repositories/document_repository_impl.dart';
import '../core/app_logic/domain/repositories/portfolio_repository.dart';
import '../core/app_logic/domain/repositories/document_repository.dart';
import '../core/app_logic/domain/entities/portfolio/portfolio_holdings.dart';
import '../core/app_logic/domain/entities/portfolio/portfolio_summary.dart';
import '../core/network/portfolio_client.dart';
import '../core/network/document_client.dart';
import '../core/errors/exception.dart';
import '../config/app_config.dart';
import '../config/config_service.dart';
import '../config/environment_config.dart' as env_config;
import '../features/portfolio/presentation/cubit/portfolio_cubit.dart';
import '../features/portfolio/internal/domain/usecases/get_portfolio_summary.dart';
import '../features/portfolio/internal/domain/usecases/get_portfolio_holdings.dart';
import '../features/portfolio/internal/domain/usecases/search_portfolio_holdings.dart';

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
/// Provider for DocumentClient
/// Configures Dio client with proper error handling, timeouts, and logging
/// Note: Only baseUrl and client configuration can be dynamic with Retrofit
@Riverpod()
DocumentClient documentClient(DocumentClientRef ref) {
  final dio = Dio();
  
  // Get configuration from ConfigService
  final config = ConfigService.config;
  final documentApiConfig = config.api.document;
  
  // Configure Dio with base options
  dio.options = BaseOptions(
    baseUrl: documentApiConfig?.baseUrl ?? 'http://localhost:8070',
    connectTimeout: Duration(seconds: documentApiConfig?.connectTimeout ?? 30),
    receiveTimeout: Duration(seconds: documentApiConfig?.receiveTimeout ?? 60),
    sendTimeout: Duration(seconds: documentApiConfig?.sendTimeout ?? 60),
    headers: {
      'Content-Type': 'multipart/form-data',
      'Accept': 'application/json',
    },
  );

  // Add interceptors
  _addInterceptors(dio);

  return DocumentClient(dio);
}

/// Add interceptors to Dio client
void _addInterceptors(Dio dio) {
  // Add authentication interceptor
  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) async {
      // Add auth token if available
      final token = await _getAuthToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      handler.next(options);
    },
    onError: (error, handler) {
      // Transform DioException to ApiException
      final apiException = _handleDioError(error);
      debugPrint('Document API Error: ${apiException.message}');
      handler.next(error);
    },
  ));

  // Add logging interceptor in debug mode
  if (kDebugMode) {
    dio.interceptors.add(LogInterceptor(
      request: true,
      requestBody: false, // Don't log file bodies for uploads
      responseBody: true,
      error: true,
      logPrint: (obj) => debugPrint('[DocumentClient] $obj'),
    ));
  }

  // Add retry interceptor for network failures
  dio.interceptors.add(InterceptorsWrapper(
    onError: (error, handler) async {
      if (_shouldRetry(error) && error.requestOptions.extra['retryCount'] == null) {
        error.requestOptions.extra['retryCount'] = 1;
        
        // Wait before retry
        await Future.delayed(const Duration(seconds: 2));
        
        try {
          final response = await dio.fetch(error.requestOptions);
          handler.resolve(response);
          return;
        } catch (e) {
          // Retry failed, continue with original error
        }
      }
      handler.next(error);
    },
  ));
}

/// Get authentication token from storage
Future<String?> _getAuthToken() async {
  try {
    // This would integrate with your auth service
    // For now, return null - implement based on your auth pattern
    return null;
  } catch (e) {
    debugPrint('Error getting auth token: $e');
    return null;
  }
}

/// Handle Dio errors and convert to ApiException
ApiException _handleDioError(DioException e) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return ApiException('Request timeout. Please check your connection.');
    case DioExceptionType.badResponse:
      final statusCode = e.response?.statusCode;
      final message = e.response?.data?['message'] ?? 'Unknown error occurred';
      return ApiException('Server error ($statusCode): $message');
    case DioExceptionType.connectionError:
      return ApiException('Connection error. Please check your internet connection.');
    case DioExceptionType.cancel:
      return ApiException('Request was cancelled');
    default:
      return ApiException('Network error: ${e.message}');
  }
}

/// Check if request should be retried
bool _shouldRetry(DioException error) {
  return error.type == DioExceptionType.connectionError ||
         error.type == DioExceptionType.connectionTimeout ||
         (error.response?.statusCode != null && 
          error.response!.statusCode! >= 500);
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

// Use case providers for BLoC pattern
@riverpod
Future<GetPortfolioSummary> getPortfolioSummary(GetPortfolioSummaryRef ref) async {
  final repository = await ref.watch(portfolioRepositoryProvider.future);
  return GetPortfolioSummary(repository);
}

@riverpod
Future<GetPortfolioHoldings> getPortfolioHoldings(GetPortfolioHoldingsRef ref) async {
  final repository = await ref.watch(portfolioRepositoryProvider.future);
  return GetPortfolioHoldings(repository);
}

@riverpod
Future<SearchPortfolioHoldings> searchPortfolioHoldings(SearchPortfolioHoldingsRef ref) async {
  final repository = await ref.watch(portfolioRepositoryProvider.future);
  return SearchPortfolioHoldings(repository);
}

// BLoC/Cubit providers
@riverpod
Future<PortfolioCubit> portfolioCubit(PortfolioCubitRef ref) async {
  final getPortfolioSummary = await ref.watch(getPortfolioSummaryProvider.future);
  final getPortfolioHoldings = await ref.watch(getPortfolioHoldingsProvider.future);
  final searchPortfolioHoldings = await ref.watch(searchPortfolioHoldingsProvider.future);
  
  return PortfolioCubit(
    getPortfolioSummary,
    getPortfolioHoldings,
    searchPortfolioHoldings,
  );
}
