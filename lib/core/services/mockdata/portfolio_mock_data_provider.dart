import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../../data/api/models/api_portfolio_holdings.dart';
import '../../data/api/models/api_portfolio_summary.dart';
import '../api/api_exception.dart';

/// Service for providing mock portfolio data
/// Handles loading and transformation of mock data for development and testing
class PortfolioMockDataProvider {
  /// Cache for loaded mock data to avoid repeated file reads
  static Map<String, dynamic>? _cachedSummaryData;
  static Map<String, dynamic>? _cachedHoldingsData;

  /// Load mock portfolio summary data from JSON and convert to domain model
  static Future<ApiPortfolioSummaryResponse> getMockPortfolioSummary() async {
    try {
      final summaryData = await _loadMockSummaryData();
      
      // Use mapper to convert API model to domain model
      return _convertSummaryJsonToApiModel(summaryData);
    } catch (e) {
      debugPrint('Error loading mock portfolio summary data: $e');
      throw ApiException(
        'Failed to load mock portfolio summary data',
        data: e.toString(),
      );
    }
  }

  /// Load mock portfolio holdings data from JSON and convert to domain model
  static Future<ApiPortfolioHoldingsResponse> getMockPortfolioHoldings() async {
    try {
      final holdingsData = await _loadMockHoldingsData();
      
      // Use mapper to convert API model to domain model
      return _convertHoldingsJsonToApiModel(holdingsData);
    } catch (e) {
      debugPrint('Error loading mock portfolio holdings data: $e');
      throw ApiException(
        'Failed to load mock portfolio holdings data',
        data: e.toString(),
      );
    }
  }

  /// Load mock summary data from assets file
  static Future<Map<String, dynamic>> _loadMockSummaryData() async {
    if (_cachedSummaryData != null) {
      return _cachedSummaryData!;
    }

    try {
      final mockDataString = await rootBundle.loadString('assets/mock_data/portfolio_summary.json');
      _cachedSummaryData = jsonDecode(mockDataString) as Map<String, dynamic>;
      return _cachedSummaryData!;
    } catch (e) {
      debugPrint('Error loading mock summary data from assets: $e');
      throw ApiException('Failed to load mock summary data file: $e');
    }
  }

  /// Load mock holdings data from assets file
  static Future<Map<String, dynamic>> _loadMockHoldingsData() async {
    if (_cachedHoldingsData != null) {
      return _cachedHoldingsData!;
    }

    try {
      final mockDataString = await rootBundle.loadString('assets/mock_data/portfolio_holdings.json');
      _cachedHoldingsData = jsonDecode(mockDataString) as Map<String, dynamic>;
      return _cachedHoldingsData!;
    } catch (e) {
      debugPrint('Error loading mock holdings data from assets: $e');
      throw ApiException('Failed to load mock holdings data file: $e');
    }
  }

  /// Convert summary JSON data to API model
  static ApiPortfolioSummaryResponse _convertSummaryJsonToApiModel(Map<String, dynamic> json) {
    return ApiPortfolioSummaryResponse(
      totalValue: (json['currentValue'] as num?)?.toDouble() ?? 0.0,
      investmentValue: (json['investmentValue'] as num?)?.toDouble() ?? 0.0,
      todaysGain: (json['todayGainLoss'] as num?)?.toDouble() ?? 0.0,
      totalGain: (json['totalGainLoss'] as num?)?.toDouble() ?? 0.0,
      totalGainPercentage: (json['totalGainLossPercentage'] as num?)?.toDouble() ?? 0.0,
      todaysGainPercentage: (json['todayGainLossPercentage'] as num?)?.toDouble() ?? 0.0,
      marketCapHoldings: _convertToApiMarketCapHoldings(json['marketCapHoldings']),
      sectorAllocation: _extractSectorAllocation(json['sectorialHoldings']),
      topPerformers: _extractTopPerformers(json),
      topLosers: _extractTopLosers(json),
    );
  }

  /// Convert holdings JSON data to API model
  static ApiPortfolioHoldingsResponse _convertHoldingsJsonToApiModel(Map<String, dynamic> json) {
    final equityHoldings = (json['equityHoldings'] as List? ?? [])
        .map((holding) => ApiEquityHolding(
              isin: holding['isin'] as String? ?? '',
              symbol: holding['symbol'] as String? ?? '',
              sector: holding['sector'] as String? ?? '',
              industry: holding['industry'] as String? ?? '',
              marketCap: holding['marketCap'] as String? ?? '',
              quantity: (holding['quantity'] as num?)?.toDouble() ?? 0.0,
              investmentCost: (holding['investmentCost'] as num?)?.toDouble() ?? 0.0,
              currentValue: (holding['currentValue'] as num?)?.toDouble() ?? 0.0,
              weightInPortfolio: (holding['weightInPortfolio'] as num?)?.toDouble() ?? 0.0,
              gainLoss: (holding['gainLoss'] as num?)?.toDouble() ?? 0.0,
              gainLossPercentage: (holding['gainLossPercentage'] as num?)?.toDouble() ?? 0.0,
              todayGainLoss: (holding['todayGainLoss'] as num?)?.toDouble() ?? 0.0,
              todayGainLossPercentage: (holding['todayGainLossPercentage'] as num?)?.toDouble() ?? 0.0,
              currentPrice: (holding['currentPrice'] as num?)?.toDouble() ?? 0.0,
              percentageChange: (holding['percentageChange'] as num?)?.toDouble() ?? 0.0,
              brokerPortfolios: (holding['brokerPortfolios'] as List? ?? [])
                  .map((broker) => ApiBrokerHolding(
                        brokerType: broker['brokerType'] as String? ?? '',
                        quantity: (broker['quantity'] as num?)?.toDouble() ?? 0.0,
                      ))
                  .toList(),
            ))
        .toList();

    return ApiPortfolioHoldingsResponse(equityHoldings: equityHoldings);
  }

  /// Convert market cap holdings from JSON to API model
  static Map<String, List<ApiMarketCapHolding>> _convertToApiMarketCapHoldings(dynamic value) {
    if (value == null) return {};
    
    final Map<String, List<ApiMarketCapHolding>> result = {};
    final map = value as Map<String, dynamic>;
    
    for (final entry in map.entries) {
      final holdings = (entry.value as List? ?? [])
          .map((h) => ApiMarketCapHolding(
                isin: h['isin'] as String? ?? '',
                symbol: h['symbol'] as String? ?? '',
                sector: h['sector'] as String? ?? '',
                industry: h['industry'] as String? ?? '',
                marketCap: h['marketCap'] as String? ?? entry.key,
                quantity: (h['quantity'] as num?)?.toDouble() ?? 0.0,
                investmentCost: (h['investmentCost'] as num?)?.toDouble() ?? 0.0,
                brokerPortfolios: (h['brokerPortfolios'] as List? ?? [])
                    .map((b) => ApiBrokerHolding(
                          brokerType: b['brokerType'] as String? ?? '',
                          quantity: (b['quantity'] as num?)?.toDouble() ?? 0.0,
                        ))
                    .toList(),
              ))
          .toList();
      result[entry.key] = holdings;
    }
    
    return result;
  }

  /// Extract sector allocation from sectorial holdings
  static Map<String, double> _extractSectorAllocation(dynamic value) {
    if (value == null) return {};
    
    final Map<String, double> result = {};
    final map = value as Map<String, dynamic>;
    
    for (final entry in map.entries) {
      if (entry.key.isEmpty) continue; // Skip empty sector names
      
      double totalInvestment = 0.0;
      final holdings = entry.value as List? ?? [];
      
      for (final holding in holdings) {
        totalInvestment += (holding['investmentCost'] as num?)?.toDouble() ?? 0.0;
      }
      
      if (totalInvestment > 0) {
        result[entry.key] = totalInvestment;
      }
    }
    
    // Convert to percentages
    final totalInvestment = result.values.fold(0.0, (sum, value) => sum + value);
    if (totalInvestment > 0) {
      result.updateAll((key, value) => (value / totalInvestment) * 100);
    }
    
    return result;
  }

  /// Extract top performers from holdings data
  static List<ApiTopPerformer> _extractTopPerformers(Map<String, dynamic> json) {
    final performers = <ApiTopPerformer>[];
    
    // Extract from market cap holdings
    final marketCapHoldings = json['marketCapHoldings'] as Map<String, dynamic>? ?? {};
    
    for (final category in marketCapHoldings.values) {
      final holdings = category as List? ?? [];
      for (final holding in holdings) {
        final gainPercentage = (holding['gainLossPercentage'] as num?)?.toDouble() ?? 0.0;
        final gainAmount = (holding['gainLoss'] as num?)?.toDouble() ?? 0.0;
        
        if (gainPercentage > 0) {
          performers.add(ApiTopPerformer(
            symbol: holding['symbol'] as String? ?? '',
            gainPercentage: gainPercentage,
            gainAmount: gainAmount,
          ));
        }
      }
    }
    
    // Sort by gain percentage and take top 5
    performers.sort((a, b) => b.gainPercentage.compareTo(a.gainPercentage));
    return performers.take(5).toList();
  }

  /// Extract top losers from holdings data
  static List<ApiTopLoser> _extractTopLosers(Map<String, dynamic> json) {
    final losers = <ApiTopLoser>[];
    
    // Extract from market cap holdings
    final marketCapHoldings = json['marketCapHoldings'] as Map<String, dynamic>? ?? {};
    
    for (final category in marketCapHoldings.values) {
      final holdings = category as List? ?? [];
      for (final holding in holdings) {
        final gainPercentage = (holding['gainLossPercentage'] as num?)?.toDouble() ?? 0.0;
        final gainAmount = (holding['gainLoss'] as num?)?.toDouble() ?? 0.0;
        
        if (gainPercentage < 0) {
          losers.add(ApiTopLoser(
            symbol: holding['symbol'] as String? ?? '',
            lossPercentage: gainPercentage.abs(),
            lossAmount: gainAmount.abs(),
          ));
        }
      }
    }
    
    // Sort by loss percentage and take top 5
    losers.sort((a, b) => b.lossPercentage.compareTo(a.lossPercentage));
    return losers.take(5).toList();
  }

  /// Generate random gain amount
  static double _generateRandomGain(double baseValue, {bool isDaily = false}) {
    final maxPercent = isDaily ? 5.0 : 20.0; // Daily: ±5%, Total: ±20%
    final randomPercent = (DateTime.now().millisecondsSinceEpoch % 100 - 50) / 50 * maxPercent;
    return baseValue * randomPercent / 100;
  }

  /// Generate random percentage change
  static double _generateRandomPercentage({bool isDaily = false}) {
    final maxPercent = isDaily ? 5.0 : 20.0;
    return (DateTime.now().millisecondsSinceEpoch % 100 - 50) / 50 * maxPercent;
  }

  /// Create fallback portfolio summary when all else fails
  static PortfolioSummary _createFallbackPortfolioSummary() {
    final fallbackApiModel = ApiPortfolioSummaryResponse(
      totalValue: 100000.0,
      investmentValue: 95000.0,
      todaysGain: 500.0,
      totalGain: 5000.0,
      totalGainPercentage: 5.26,
      todaysGainPercentage: 0.5,
      marketCapHoldings: {},
      sectorAllocation: {
        'Technology': 30.0,
        'Healthcare': 25.0,
        'Finance': 20.0,
        'Consumer': 25.0,
      },
      topPerformers: [],
      topLosers: [],
    );
    
    return PortfolioSummaryMapper.fromApiModel(fallbackApiModel);
  }

  /// Create fallback portfolio holdings when all else fails
  static PortfolioHoldings createFallbackPortfolioHoldings() {
    final fallbackApiModel = ApiPortfolioHoldingsResponse(
      equityHoldings: [
        ApiEquityHolding(
          isin: 'SAMPLE001',
          symbol: 'SAMPLE',
          sector: 'Technology',
          industry: 'Software',
          marketCap: 'Large Cap',
          quantity: 100.0,
          investmentCost: 10000.0,
          currentValue: 11000.0,
          weightInPortfolio: 100.0,
          gainLoss: 1000.0,
          gainLossPercentage: 10.0,
          todayGainLoss: 100.0,
          todayGainLossPercentage: 1.0,
          currentPrice: 110.0,
          percentageChange: 1.0,
          brokerPortfolios: [],
        ),
      ],
    );
    
    return PortfolioHoldingsMapper.fromApiModel(fallbackApiModel);
  }

  /// Clear cached mock data (useful for testing or refreshing)
  static void clearCache() {
    _cachedSummaryData = null;
    _cachedHoldingsData = null;
  }

  /// Check if mock data is available
  static Future<bool> isMockDataAvailable() async {
    try {
      await _loadMockSummaryData();
      await _loadMockHoldingsData();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get mock data statistics for debugging
  static Future<Map<String, dynamic>> getMockDataStats() async {
    try {
      final summaryData = await _loadMockSummaryData();
      final holdingsData = await _loadMockHoldingsData();
      
      final marketCapHoldings = summaryData['marketCapHoldings'] as Map<String, dynamic>? ?? {};
      final equityHoldings = holdingsData['equityHoldings'] as List? ?? [];
      
      int totalHoldings = 0;
      for (final holdings in marketCapHoldings.values) {
        totalHoldings += (holdings as List).length;
      }
      
      return {
        'totalValue': summaryData['currentValue'],
        'investmentValue': summaryData['investmentValue'],
        'marketCapCategories': marketCapHoldings.keys.length,
        'totalHoldings': totalHoldings,
        'equityHoldingsCount': equityHoldings.length,
        'sectorialHoldingsCount': (summaryData['sectorialHoldings'] as Map?)?.keys.length ?? 0,
        'summaryDataSize': summaryData.toString().length,
        'holdingsDataSize': holdingsData.toString().length,
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }
}