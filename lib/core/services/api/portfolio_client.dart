import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import '../../models/portfolio/portfolio_models.dart';
import 'api_client.dart';

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
  }) : _apiClient = ApiClient(
         baseUrl: baseUrl,
         client: httpClient,
       ) {
    _useMockData = useMockData;
  }
  
  /// Get portfolio summary for a user
  Future<ApiResponse<PortfolioSummary>> getPortfolioSummary(String userId) async {
    try {
      // Always try to fetch from API first
      try {
        final result = await _apiClient.get<PortfolioSummary>(
          '$_portfolioEndpoint/summary',
          queryParams: {'userId': userId},
          parser: (data) => PortfolioSummary.fromJson(data),
        );
        
        debugPrint('Successfully fetched portfolio data from API');
        return ApiResponse.success(result);
      } catch (apiError) {
        // API call failed, log the error
        debugPrint('API call failed: $apiError');
        
        // Always fall back to mock data in debug mode
        if (kDebugMode) {
          debugPrint('Falling back to mock data');
          await Future.delayed(const Duration(milliseconds: 300)); // Small delay
          return ApiResponse.success(await _getMockPortfolioSummary());
        } else {
          // In production, return an error response
          return ApiResponse.error('Failed to connect to API: $apiError');
        }
      }
    } on ApiException catch (e) {
      debugPrint('Error fetching portfolio summary: ${e.message}');
      return ApiResponse.error(e.message);
    } catch (e) {
      debugPrint('Unexpected error fetching portfolio summary: $e');
      return ApiResponse.error('An unexpected error occurred');
    }
  }
  
  /// Flag to use mock data
  bool _useMockData = false;
  
  /// Set whether to use mock data in debug mode
  set useMockData(bool value) {
    _useMockData = value;
  }
  
  /// Get mock portfolio summary data
  Future<PortfolioSummary> _getMockPortfolioSummary() async {
    try {
      // Load mock data from assets
      final mockData = await rootBundle.loadString('assets/mock_data/portfolio_summary.json');
      final json = jsonDecode(mockData);
      return PortfolioSummary.fromJson(json);
    } catch (e) {
      // Throw exception if mock data loading fails
      debugPrint('Error loading mock portfolio data: $e');
      throw ApiException('Failed to load mock portfolio data: $e');
    }
  }
  
  /// Dispose resources
  void dispose() {
    _apiClient.dispose();
  }
}

