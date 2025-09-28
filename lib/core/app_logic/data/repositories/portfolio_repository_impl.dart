import '../../domain/entities/portfolio/portfolio_holdings.dart';
import '../../domain/entities/portfolio/portfolio_summary.dart';
import '../../domain/repositories/portfolio_repository.dart';
import '../mappers/portfolio_holdings_mapper.dart';
import '../mappers/portfolio_summary_mapper.dart';
import '../../../network/portfolio_client.dart';

/// Concrete implementation of PortfolioRepository
/// Handles API calls, caching, and data transformation
class PortfolioRepositoryImpl implements PortfolioRepository {
  /// API client for portfolio data
  final PortfolioClient _apiClient;
  
  /// Cache for portfolio holdings
  final Map<String, _CachedPortfolioData<PortfolioHoldings>> _holdingsCache = {};
  
  /// Cache for portfolio summary
  final Map<String, _CachedPortfolioData<PortfolioSummary>> _summaryCache = {};
  
  /// Cache duration (5 minutes)
  static const Duration _cacheExpiry = Duration(minutes: 5);

  /// Constructor
  PortfolioRepositoryImpl({required PortfolioClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<PortfolioHoldings> getPortfolioHoldings(String userId) async {
    try {
      // Check cache first
      if (isHoldingsCachedDataFresh(userId)) {
        return _holdingsCache[userId]!.data;
      }

      // Fetch from API
      final apiResponse = await _apiClient.getPortfolioHoldings(userId);
      
      // Convert to domain model
      final domainModel = PortfolioHoldingsMapper.fromApiModel(apiResponse.data!);
      
      // Cache the result
      _holdingsCache[userId] = _CachedPortfolioData(
        data: domainModel,
        timestamp: DateTime.now(),
      );
      
      return domainModel;
    } catch (e) {
      // Return cached data if available, even if stale
      if (_holdingsCache.containsKey(userId)) {
        return _holdingsCache[userId]!.data;
      }
      
      // If no cache and API fails, return empty portfolio
      return PortfolioHoldings.empty();
    }
  }

  @override
  Future<PortfolioSummary> getPortfolioSummary(String userId) async {
    try {
      // Check cache first
      if (isSummaryCachedDataFresh(userId)) {
        return _summaryCache[userId]!.data;
      }

      // Fetch from API
      final apiResponse = await _apiClient.getPortfolioSummary(userId);
      
      // Check if API response is successful
      if (!apiResponse.isSuccess || apiResponse.data == null) {
        throw Exception(apiResponse.error ?? 'Failed to fetch portfolio summary');
      }
      
      // Convert to domain model
      final domainModel = PortfolioSummaryMapper.fromApiModel(apiResponse.data!);
      
      // Cache the result
      _summaryCache[userId] = _CachedPortfolioData(
        data: domainModel,
        timestamp: DateTime.now(),
      );
      
      return domainModel;
    } catch (e) {
      // Return cached data if available, even if stale
      if (_summaryCache.containsKey(userId)) {
        return _summaryCache[userId]!.data;
      }
      
      // If no cache and API fails, return empty summary
      return PortfolioSummary.empty();
    }
  }

  @override
  Future<PortfolioHoldings> refreshPortfolioHoldings(String userId) async {
    // Clear holdings cache and fetch fresh data
    _holdingsCache.remove(userId);
    return getPortfolioHoldings(userId);
  }

  @override
  Future<PortfolioSummary> refreshPortfolioSummary(String userId) async {
    // Clear summary cache and fetch fresh data
    _summaryCache.remove(userId);
    return getPortfolioSummary(userId);
  }

  @override
  Stream<PortfolioHoldings> portfolioHoldingsUpdatesStream(String userId) async* {
    // Initial data
    yield await getPortfolioHoldings(userId);
    
    // Periodic updates (every 30 seconds)
    await for (final _ in Stream.periodic(const Duration(seconds: 30))) {
      try {
        final updated = await refreshPortfolioHoldings(userId);
        yield updated;
      } catch (e) {
        // Continue with cached data on error
        if (_holdingsCache.containsKey(userId)) {
          yield _holdingsCache[userId]!.data;
        }
      }
    }
  }

  @override
  Stream<PortfolioSummary> portfolioSummaryUpdatesStream(String userId) async* {
    // Initial data
    yield await getPortfolioSummary(userId);
    
    // Periodic updates (every 30 seconds)
    await for (final _ in Stream.periodic(const Duration(seconds: 30))) {
      try {
        final updated = await refreshPortfolioSummary(userId);
        yield updated;
      } catch (e) {
        // Continue with cached data on error
        if (_summaryCache.containsKey(userId)) {
          yield _summaryCache[userId]!.data;
        }
      }
    }
  }

  @override
  bool isHoldingsCachedDataFresh(String userId) {
    final cached = _holdingsCache[userId];
    if (cached == null) return false;
    
    final age = DateTime.now().difference(cached.timestamp);
    return age < _cacheExpiry;
  }

  @override
  bool isSummaryCachedDataFresh(String userId) {
    final cached = _summaryCache[userId];
    if (cached == null) return false;
    
    final age = DateTime.now().difference(cached.timestamp);
    return age < _cacheExpiry;
  }

  @override
  Future<void> clearHoldingsCache(String userId) async {
    _holdingsCache.remove(userId);
  }

  @override
  Future<void> clearSummaryCache(String userId) async {
    _summaryCache.remove(userId);
  }

  @override
  Future<void> clearAllCache(String userId) async {
    _holdingsCache.remove(userId);
    _summaryCache.remove(userId);
  }

  /// Clear all cached data for all users
  void clearEntireCache() {
    _holdingsCache.clear();
    _summaryCache.clear();
  }

  /// Get cache info for debugging
  Map<String, Map<String, DateTime>> getCacheInfo() {
    return {
      'holdings': _holdingsCache.map((key, value) => MapEntry(key, value.timestamp)),
      'summary': _summaryCache.map((key, value) => MapEntry(key, value.timestamp)),
    };
  }
}

/// Internal class for cached data
class _CachedPortfolioData<T> {
  final T data;
  final DateTime timestamp;

  _CachedPortfolioData({
    required this.data,
    required this.timestamp,
  });
}