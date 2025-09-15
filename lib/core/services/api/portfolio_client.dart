import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import '../../models/portfolio/portfolio_models.dart';
import '../../models/portfolio/portfolio_holdings.dart';
import 'api_client.dart';
import 'api_exception.dart';

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
    final String fullUrl = '${_apiClient.baseUrl}/$_portfolioEndpoint/summary?userId=$userId';
    debugPrint('API call: GET $fullUrl');
    
    try {
      // Always try to fetch from API first
      try {
        debugPrint('Attempting to fetch portfolio summary from: $fullUrl');
        final result = await _apiClient.get<PortfolioSummary>(
          '$_portfolioEndpoint/summary',
          queryParams: {'userId': userId},
          parser: (data) => PortfolioSummary.fromJson(data),
        );
        
        debugPrint('Successfully fetched portfolio data from API: $fullUrl');
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
      throw ApiException('Failed to load mock portfolio data', data: e.toString());
    }
  }
  
  /// Get portfolio holdings for a user
  Future<PortfolioHoldings> getPortfolioHoldings(String userId) async {
    final String fullUrl = '${_apiClient.baseUrl}/$_portfolioEndpoint/holdings?userId=$userId';
    debugPrint('API call: GET $fullUrl');
    
    try {
      // Always try to fetch from API first
      try {
        // Only use API in production or when mock data is disabled
        if (!_useMockData) {
          debugPrint('Attempting to fetch real data from: $fullUrl');
          try {
            final result = await _apiClient.get<PortfolioHoldings>(
              '$_portfolioEndpoint/holdings',
              queryParams: {'userId': userId},
              parser: (data) {
                debugPrint('Parsing API response data: ${data.toString().substring(0, min(100, data.toString().length))}...');
                return PortfolioHoldings.fromJson(data);
              },
            );
            
            debugPrint('Successfully fetched portfolio holdings from API: $fullUrl');
            return result;
          } catch (parseError) {
            debugPrint('Error parsing API response: $parseError');
            // Try to handle the error gracefully
            if (parseError.toString().contains("'null' is not a subtype of type 'double'")) {
              debugPrint('Detected null value in numeric field, using null-safe parsing');
              // Continue with mock data as fallback
              throw ApiException('Error parsing API response: $parseError');
            }
            rethrow;
          }
        } else {
          debugPrint('Mock data configured, skipping API call to: $fullUrl');
          throw ApiException('Using mock data as configured');
        }
      } catch (apiError) {
        // API call failed, log the error
        debugPrint('API call failed: $apiError');
        
        // Fall back to mock data in debug mode or when mock data is enabled
        if (kDebugMode || _useMockData) {
          debugPrint('Falling back to mock data');
          await Future.delayed(const Duration(milliseconds: 300)); // Small delay
          return await _getMockPortfolioHoldings();
        } else {
          // In production, rethrow the error
          throw ApiException('Failed to connect to API: $apiError');
        }
      }
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

  /// Get mock portfolio holdings data
  Future<PortfolioHoldings> _getMockPortfolioHoldings() async {
    try {
      // Create mock data for portfolio holdings
      final mockData = {
        "equityHoldings": [
          {
            "isin": "INE124G01033",
            "symbol": "DELTACORP",
            "sector": "Amusement Parks/ Other Recreation",
            "industry": "Amusement Parks/ Other Recreation",
            "marketCap": "MICRO_CAP",
            "quantity": 7.0,
            "investmentCost": 892.15,
            "currentValue": 573.3,
            "weightInPortfolio": 0.13,
            "gainLoss": -318.85,
            "gainLossPercentage": -35.74,
            "todayGainLoss": -10.85,
            "todayGainLossPercentage": -1.86,
            "currentPrice": 81.9,
            "percentageChange": -1.86,
            "brokerPortfolios": [
              {
                "brokerType": "ZERODHA",
                "quantity": 7.0
              }
            ]
          },
          {
            "isin": "INE009A01021",
            "symbol": "RELIANCE",
            "sector": "Oil & Gas",
            "industry": "Refineries",
            "marketCap": "LARGE_CAP",
            "quantity": 5.0,
            "investmentCost": 12500.0,
            "currentValue": 13250.0,
            "weightInPortfolio": 3.05,
            "gainLoss": 750.0,
            "gainLossPercentage": 6.0,
            "todayGainLoss": 125.0,
            "todayGainLossPercentage": 0.95,
            "currentPrice": 2650.0,
            "percentageChange": 0.95,
            "brokerPortfolios": [
              {
                "brokerType": "ZERODHA",
                "quantity": 3.0
              },
              {
                "brokerType": "UPSTOX",
                "quantity": 2.0
              }
            ]
          },
          {
            "isin": "INE040A01034",
            "symbol": "HDFCBANK",
            "sector": "Financial Services",
            "industry": "Banks",
            "marketCap": "LARGE_CAP",
            "quantity": 10.0,
            "investmentCost": 15000.0,
            "currentValue": 16200.0,
            "weightInPortfolio": 3.73,
            "gainLoss": 1200.0,
            "gainLossPercentage": 8.0,
            "todayGainLoss": 150.0,
            "todayGainLossPercentage": 0.94,
            "currentPrice": 1620.0,
            "percentageChange": 0.94,
            "brokerPortfolios": [
              {
                "brokerType": "ZERODHA",
                "quantity": 10.0
              }
            ]
          }
        ]
      };
      
      return PortfolioHoldings.fromJson(mockData);
    } catch (e) {
      // Throw exception if mock data creation fails
      debugPrint('Error creating mock portfolio holdings data: $e');
      throw ApiException('Failed to create mock portfolio holdings data', data: e.toString());
    }
  }
  
  /// Dispose resources
  void dispose() {
    _apiClient.dispose();
  }
}

