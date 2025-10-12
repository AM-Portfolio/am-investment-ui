import '../../../../core/network/api_client.dart';
import '../dtos/trade_dtos.dart';

abstract class TradeDataSource {
  // Portfolio Discovery (Step 1) - same pattern as portfolio
  Future<List<ApiTradePortfolioSummaryDto>> getPortfoliosByOwner(String ownerId);
  
  // Portfolio Analysis (Step 2) - following portfolio patterns
  Future<ApiTradePortfolioSummaryDto> getPortfolioSummary(String portfolioId);
  Future<List<ApiTradeHoldingDto>> getTradeHoldings({
    required String portfolioId,
    int page = 1,
    int limit = 50,
    String? searchQuery,
    String? statusFilter,
  });
  
  // Trade Details (Step 3) - trade-specific
  Future<List<ApiTradeHoldingDto>> getTradeDetailsByIds(List<String> tradeIds);
}

// Implementation following portfolio_datasource_impl.dart pattern
class TradeDataSourceImpl implements TradeDataSource {
  final ApiClient _apiClient;
  
  const TradeDataSourceImpl({required ApiClient apiClient}) : _apiClient = apiClient;
  
  @override
  Future<List<ApiTradePortfolioSummaryDto>> getPortfoliosByOwner(String ownerId) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/api/v1/portfolio-summary/by-owner/$ownerId',
    );
    
    final List<dynamic> portfolioList = response.data!['portfolios'];
    return portfolioList
        .cast<Map<String, dynamic>>()
        .map((json) => ApiTradePortfolioSummaryDto.fromJson(json))
        .toList();
  }

  @override
  Future<ApiTradePortfolioSummaryDto> getPortfolioSummary(String portfolioId) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/api/v1/portfolio-summary/$portfolioId',
    );
    return ApiTradePortfolioSummaryDto.fromJson(response.data!);
  }

  @override
  Future<List<ApiTradeHoldingDto>> getTradeHoldings({
    required String portfolioId,
    int page = 1,
    int limit = 50,
    String? searchQuery,
    String? statusFilter,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
      if (searchQuery != null) 'search': searchQuery,
      if (statusFilter != null) 'status': statusFilter,
    };

    final response = await _apiClient.get<Map<String, dynamic>>(
      '/api/v1/trades/portfolio-details/$portfolioId',
      queryParameters: queryParams,
    );
    final List<dynamic> tradeHoldingsList = response.data!['trades'];
    return tradeHoldingsList
        .cast<Map<String, dynamic>>()
        .map((json) => ApiTradeHoldingDto.fromJson(json))
        .toList();
  }

  @override
  Future<List<ApiTradeHoldingDto>> getTradeDetailsByIds(List<String> tradeIds) async {
    final request = ApiTradeDetailsByIdsRequest(
      tradeIds: tradeIds,
      includeExecutions: true,
      includePerformanceMetrics: true,
    );

    final response = await _apiClient.post<List<dynamic>>(
      '/api/v1/trades/details/by-ids',
      data: request.toJson(),
    );

    return response.data!
        .cast<Map<String, dynamic>>()
        .map((json) => ApiTradeHoldingDto.fromJson(json))
        .toList();
  }
}
  }

  @override
  Future<ApiCalendarResponse> getCalendarData({
    required String portfolioId,
    required String viewType,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final String endpoint;
    final queryParams = <String, dynamic>{};

    switch (viewType.toLowerCase()) {
      case 'month':
        endpoint =
            '/api/v1/trades/calendar/$portfolioId/month/${startDate.year}/${startDate.month}';
        break;
      case 'day':
        endpoint =
            '/api/v1/trades/calendar/$portfolioId/day/${startDate.year}/${startDate.month}/${startDate.day}';
        break;
      case 'quarter':
        final quarter = ((startDate.month - 1) ~/ 3) + 1;
        endpoint =
            '/api/v1/trades/calendar/$portfolioId/quarter/${startDate.year}/$quarter';
        break;
      case 'financial-year':
        endpoint =
            '/api/v1/trades/calendar/$portfolioId/financial-year/${startDate.year}';
        break;
      default:
        throw ArgumentError('Invalid view type: $viewType');
    }

    final response = await _apiClient.get<Map<String, dynamic>>(
      endpoint,
      queryParameters: queryParams,
    );
    return ApiCalendarResponse.fromJson(response.data!);
  }
}
