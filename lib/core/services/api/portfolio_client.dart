import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import '../../data/api/models/api_portfolio_holdings.dart';
import '../../data/api/models/api_portfolio_summary.dart';
import 'api_client.dart';
import 'api_exception.dart';
import 'portfolio_mock_data_provider.dart';

/// Client for portfolio-related API calls
class PortfolioClient {
  /// Base API client
  final ApiClient _apiClient;

  /// API endpoint for portfolios
  static const String _portfolioEndpoint = 'api/v1/portfolios';

  /// Constructor
  PortfolioClient({
    required String baseUrl,
    http.Client? httpClient,
    bool useMockData = false,
  }) : _apiClient = ApiClient(baseUrl: baseUrl, client: httpClient) {
    _useMockData = useMockData;
  }

  /// Get portfolio summary for a user
  Future<ApiResponse<ApiPortfolioSummaryResponse>> getPortfolioSummary(
    String userId,
  ) async {
    final String fullUrl =
        '${_apiClient.baseUrl}/$_portfolioEndpoint/summary?userId=$userId';
    debugPrint('API call: GET $fullUrl');

    try {
      // Always try to fetch from API first
      try {
        debugPrint('Attempting to fetch portfolio summary from: $fullUrl');
        
        // Use new API model and then convert to legacy format for backward compatibility
        final apiResult = await _apiClient.get<ApiPortfolioSummaryResponse>(
          '$_portfolioEndpoint/summary',
          queryParams: {'userId': userId},
          parser: (data) => ApiPortfolioSummaryResponse.fromJson(data),
        );

        // Convert API model to domain model
        final domainSummary = PortfolioSummaryMapper.fromApiModel(apiResult);
        

        debugPrint('Successfully fetched portfolio data from API: $fullUrl');
        return ApiResponse.success(domainSummary);
      } catch (apiError) {
        // API call failed, log the error
        debugPrint('API call failed: $apiError');

        // Always fall back to mock data in debug mode
        if (kDebugMode) {
          debugPrint('Falling back to mock data');
          await Future.delayed(
            const Duration(milliseconds: 300),
          ); // Small delay
          return ApiResponse.success(await PortfolioMockDataProvider.getMockPortfolioSummary());
        } else {
          // In production, return an error response
          return ApiResponse.error('Failed to connect to API: $apiError');
        }
      }
    } catch (e) {
      if (e is ApiException) {
        debugPrint('Error fetching portfolio summary: ${e.message}');
        return ApiResponse.error(e.message);
      } else {
        debugPrint('Unexpected error fetching portfolio summary: $e');
        return ApiResponse.error('An unexpected error occurred');
      }
    }
  }

  /// Flag to use mock data
  bool _useMockData = false;

  /// Set whether to use mock data in debug mode
  set useMockData(bool value) {
    _useMockData = value;
  }

  /// Get portfolio holdings for a user
  Future<ApiPortfolioHoldingsResponse> getPortfolioHoldings(String userId) async {
    final String fullUrl =
        '${_apiClient.baseUrl}/$_portfolioEndpoint/holdings?userId=$userId';
    debugPrint('API call: GET $fullUrl');

    try {
      // Always try to fetch from API first
            final apiResult = await _apiClient.get<ApiPortfolioHoldingsResponse>(
              '$_portfolioEndpoint/holdings',
              queryParams: {'userId': userId},
              parser: (data) {
                debugPrint(
                  'Parsing API response data: ${data.toString().substring(0, min(100, data.toString().length))}...',
                );
                return ApiPortfolioHoldingsResponse.fromJson(data);
              },
            );

            debugPrint(
              'Successfully fetched portfolio holdings from API: $fullUrl',
            );
            return apiResult;
    } catch (e) {
      if (e is ApiException) {
        debugPrint('Error fetching portfolio holdings: ${e.message}');
        rethrow;
      } else {
        debugPrint('Unexpected error fetching portfolio holdings: $e');
        throw ApiException('An unexpected error occurred');
      }
    }
  }

  /// Dispose resources
  void dispose() {
    _apiClient.dispose();
  }
}

