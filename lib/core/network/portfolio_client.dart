import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'dtos/portfolio/portfolio_holdings_dtos.dart';
import 'dtos/portfolio/portfolio_summary_dtos.dart';
import 'api_client.dart';
import 'dtos/exception/exception_dtos.dart';
import '../mockdataprovider/portfolio_mock_data_provider.dart';


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

  /// Get portfolio holdings for a user
  Future<ApiResponse<ApiPortfolioHoldingsResponse>> getPortfolioHoldings(String userId) async {
    // Try API first, fallback to mock if needed
    final apiResult = await _fetchPortfolioHoldingsFromApi(userId);
    if (apiResult != null) {
      return ApiResponse.success(apiResult);
    }

    // API failed, check if we should use mock data
    if (_shouldUseMockData()) {
      return await _getMockPortfolioHoldings();
    }

    // Return error if no fallback is available
    return ApiResponse.error('Failed to connect to API and no fallback available');
  }
  
  /// Get portfolio summary for a user
  Future<ApiResponse<ApiPortfolioSummaryResponse>> getPortfolioSummary(
    String userId,
  ) async {
    // Try API first, fallback to mock if needed
    final apiResult = await _fetchPortfolioSummaryFromApi(userId);
    if (apiResult != null) {
      return ApiResponse.success(apiResult);
    }

    // API failed, check if we should use mock data
    if (_shouldUseMockData()) {
      return await _getMockPortfolioSummary();
    }

    // Return error if no fallback is available
    return ApiResponse.error('Failed to connect to API and no fallback available');
  }

  /// Attempts to fetch portfolio summary from API
  /// Returns null if API call fails
  Future<ApiPortfolioSummaryResponse?> _fetchPortfolioSummaryFromApi(String userId) async {
    final String fullUrl =
        '${_apiClient.baseUrl}/$_portfolioEndpoint/summary?userId=$userId';
    debugPrint('API call: GET $fullUrl');

    try {
      debugPrint('Attempting to fetch portfolio summary from: $fullUrl');
      
      // Use new API model and then convert to legacy format for backward compatibility
      final apiResult = await _apiClient.get<ApiPortfolioSummaryResponse>(
        '$_portfolioEndpoint/summary',
        queryParams: {'userId': userId},
        parser: (data) => ApiPortfolioSummaryResponse.fromJson(data),
      );

      debugPrint('Successfully fetched portfolio data from API: $fullUrl');
      return apiResult;
    } catch (e) {
      debugPrint('API call failed: $e');
      return null;
    }
  }

  /// Flag to use mock data
  bool _useMockData = false;

  /// Set whether to use mock data in debug mode
  set useMockData(bool value) {
    _useMockData = value;
  }

  /// Determines if mock data should be used
  bool _shouldUseMockData() {
    return kDebugMode || _useMockData;
  }

  /// Returns mock portfolio summary data
  Future<ApiResponse<ApiPortfolioSummaryResponse>> _getMockPortfolioSummary() async {
    debugPrint('Falling back to mock data');
    await Future.delayed(
      const Duration(milliseconds: 300),
    ); // Small delay to simulate network call
    return ApiResponse.success(await PortfolioMockDataProvider.getMockPortfolioSummary());
  }

  /// Attempts to fetch portfolio holdings from API
  /// Returns null if API call fails
  Future<ApiPortfolioHoldingsResponse?> _fetchPortfolioHoldingsFromApi(String userId) async {
    final String fullUrl =
        '${_apiClient.baseUrl}/$_portfolioEndpoint/holdings?userId=$userId';
    debugPrint('API call: GET $fullUrl');

    try {
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

      debugPrint('Successfully fetched portfolio holdings from API: $fullUrl');
      return apiResult;
    } catch (e) {
      debugPrint('API call failed: $e');
      return null;
    }
  }

  /// Returns mock portfolio holdings data
  Future<ApiResponse<ApiPortfolioHoldingsResponse>> _getMockPortfolioHoldings() async {
    debugPrint('Falling back to mock portfolio holdings data');
    await Future.delayed(
      const Duration(milliseconds: 300),
    ); // Small delay to simulate network call
    return ApiResponse.success(await PortfolioMockDataProvider.getMockPortfolioHoldings());
  }

  /// Dispose resources
  void dispose() {
    _apiClient.dispose();
  }
}

