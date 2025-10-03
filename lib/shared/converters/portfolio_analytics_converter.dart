import 'dart:convert';
import '../models/investment/investment_types.dart';

/// Utility class to convert portfolio analytics JSON data to investment input data
class PortfolioAnalyticsConverter {
  /// Convert portfolio analytics JSON to portfolio input data
  static List<PortfolioInputData> convertPortfolioSectors(
    Map<String, dynamic> analyticsJson,
  ) {
    final analytics = analyticsJson['analytics'] as Map<String, dynamic>?;
    if (analytics == null) return [];

    final heatmap = analytics['heatmap'] as Map<String, dynamic>?;
    if (heatmap == null) return [];

    final sectors = heatmap['sectors'] as List<dynamic>?;
    if (sectors == null) return [];

    return sectors.map((sectorData) {
      final data = sectorData as Map<String, dynamic>;

      return PortfolioInputData(
        id: data['sectorName'] ?? 'unknown',
        name: data['sectorName'] ?? 'Unknown Sector',
        currentValue: (data['totalValue'] as num?)?.toDouble() ?? 0.0,
        changeAmount: (data['totalReturnAmount'] as num?)?.toDouble() ?? 0.0,
        changePercent: (data['changePercent'] as num?)?.toDouble() ?? 0.0,
        lastUpdated: DateTime.parse(
          analyticsJson['timestamp'] ?? DateTime.now().toIso8601String(),
        ),
        weightage: (data['weightage'] as num?)?.toDouble() ?? 0.0,
        sector: data['sectorName'] as String?,
        additionalData: {
          'performanceRank': data['performanceRank'],
          'performance': data['performance'],
          'color': data['color'],
          'stockCount': data['stockCount'],
          'stocks': data['stocks'],
        },
      );
    }).toList();
  }

  /// Convert individual stocks from sectors to portfolio input data
  static List<PortfolioInputData> convertPortfolioStocks(
    Map<String, dynamic> analyticsJson,
  ) {
    final analytics = analyticsJson['analytics'] as Map<String, dynamic>?;
    if (analytics == null) return [];

    final heatmap = analytics['heatmap'] as Map<String, dynamic>?;
    if (heatmap == null) return [];

    final sectors = heatmap['sectors'] as List<dynamic>?;
    if (sectors == null) return [];

    List<PortfolioInputData> stocks = [];

    for (final sectorData in sectors) {
      final sector = sectorData as Map<String, dynamic>;
      final sectorName = sector['sectorName'] as String?;
      final stocksData = sector['stocks'] as List<dynamic>?;

      if (stocksData != null) {
        for (final stockData in stocksData) {
          final stock = stockData as Map<String, dynamic>;

          stocks.add(
            PortfolioInputData(
              id: stock['symbol'] ?? 'unknown',
              name: stock['companyName'] ?? stock['symbol'] ?? 'Unknown Stock',
              currentValue: (stock['lastPrice'] as num?)?.toDouble() ?? 0.0,
              changeAmount: (stock['changeAmount'] as num?)?.toDouble() ?? 0.0,
              changePercent:
                  (stock['changePercent'] as num?)?.toDouble() ?? 0.0,
              lastUpdated: DateTime.parse(
                analyticsJson['timestamp'] ?? DateTime.now().toIso8601String(),
              ),
              weightage: (stock['weightage'] as num?)?.toDouble() ?? 0.0,
              sector: sectorName,
              quantity: stock['quantity'] as int?,
              averagePrice: (stock['averagePrice'] as num?)?.toDouble(),
              additionalData: {
                'symbol': stock['symbol'],
                'totalValue': stock['totalValue'],
                'totalReturnAmount': stock['totalReturnAmount'],
                'totalReturnPercent': stock['totalReturnPercent'],
                'dayReturnAmount': stock['dayReturnAmount'],
                'dayReturnPercent': stock['dayReturnPercent'],
              },
            ),
          );
        }
      }
    }

    return stocks;
  }

  /// Convert top gainers/losers to stock input data
  static List<PortfolioInputData> convertMovers(
    Map<String, dynamic> analyticsJson, {
    required bool topGainers,
  }) {
    final analytics = analyticsJson['analytics'] as Map<String, dynamic>?;
    if (analytics == null) return [];

    final movers = analytics['movers'] as Map<String, dynamic>?;
    if (movers == null) return [];

    final List<dynamic>? moversList = topGainers
        ? movers['topGainers'] as List<dynamic>?
        : movers['topLosers'] as List<dynamic>?;

    if (moversList == null) return [];

    return moversList.map((moverData) {
      final data = moverData as Map<String, dynamic>;

      return PortfolioInputData(
        id: data['symbol'] ?? 'unknown',
        name: data['companyName'] ?? data['symbol'] ?? 'Unknown Stock',
        currentValue: (data['lastPrice'] as num?)?.toDouble() ?? 0.0,
        changeAmount: (data['changeAmount'] as num?)?.toDouble() ?? 0.0,
        changePercent: (data['changePercent'] as num?)?.toDouble() ?? 0.0,
        lastUpdated: DateTime.parse(
          analyticsJson['timestamp'] ?? DateTime.now().toIso8601String(),
        ),
        weightage: 1.0, // Equal weightage for movers
        sector: data['sector'] as String?,
        additionalData: {
          'symbol': data['symbol'],
          'type': topGainers ? 'gainer' : 'loser',
        },
      );
    }).toList();
  }

  /// Convert sector allocation to sector input data
  static List<PortfolioInputData> convertSectorAllocation(
    Map<String, dynamic> analyticsJson,
  ) {
    final analytics = analyticsJson['analytics'] as Map<String, dynamic>?;
    if (analytics == null) return [];

    final sectorAllocation =
        analytics['sectorAllocation'] as Map<String, dynamic>?;
    if (sectorAllocation == null) return [];

    final sectorWeights = sectorAllocation['sectorWeights'] as List<dynamic>?;
    if (sectorWeights == null) return [];

    return sectorWeights.map((sectorData) {
      final data = sectorData as Map<String, dynamic>;

      return PortfolioInputData(
        id: data['sectorName'] ?? 'unknown',
        name: data['sectorName'] ?? 'Unknown Sector',
        currentValue: (data['marketCap'] as num?)?.toDouble() ?? 0.0,
        changeAmount: 0.0, // Not available in sector allocation
        changePercent: 0.0, // Not available in sector allocation
        lastUpdated: DateTime.parse(
          analyticsJson['timestamp'] ?? DateTime.now().toIso8601String(),
        ),
        weightage: (data['weightPercentage'] as num?)?.toDouble() ?? 0.0,
        sector: data['sectorName'] as String?,
        additionalData: {'topStocks': data['topStocks']},
      );
    }).toList();
  }

  /// Convert market cap allocation to market cap input data
  static List<PortfolioInputData> convertMarketCapAllocation(
    Map<String, dynamic> analyticsJson,
  ) {
    final analytics = analyticsJson['analytics'] as Map<String, dynamic>?;
    if (analytics == null) return [];

    final marketCapAllocation =
        analytics['marketCapAllocation'] as Map<String, dynamic>?;
    if (marketCapAllocation == null) return [];

    final segments = marketCapAllocation['segments'] as List<dynamic>?;
    if (segments == null) return [];

    return segments.map((segmentData) {
      final data = segmentData as Map<String, dynamic>;

      return PortfolioInputData(
        id: data['segmentName'] ?? 'unknown',
        name: data['segmentName'] ?? 'Unknown Segment',
        currentValue: (data['totalValue'] as num?)?.toDouble() ?? 0.0,
        changeAmount: (data['totalReturnAmount'] as num?)?.toDouble() ?? 0.0,
        changePercent: (data['totalReturnPercent'] as num?)?.toDouble() ?? 0.0,
        lastUpdated: DateTime.parse(
          analyticsJson['timestamp'] ?? DateTime.now().toIso8601String(),
        ),
        weightage: (data['weightPercentage'] as num?)?.toDouble() ?? 0.0,
        marketCap: data['segmentName'] as String?,
        additionalData: {
          'stockCount': data['stockCount'],
          'averageReturn': data['averageReturn'],
          'topStocks': data['topStocks'],
        },
      );
    }).toList();
  }

  /// Create sample mutual fund data (since not in the JSON)
  static List<MutualFundInputData> createSampleMutualFunds() {
    return [
      MutualFundInputData(
        id: 'fund-1',
        name: 'Large Cap Growth Fund',
        currentValue: 45.67,
        changeAmount: 0.23,
        changePercent: 0.51,
        lastUpdated: DateTime.now(),
        aum: 2500000000, // 2.5B
        category: 'Large Cap',
        expenseRatio: 0.8,
        holdings: 45,
      ),
      MutualFundInputData(
        id: 'fund-2',
        name: 'Mid Cap Value Fund',
        currentValue: 32.18,
        changeAmount: -0.15,
        changePercent: -0.46,
        lastUpdated: DateTime.now(),
        aum: 1200000000, // 1.2B
        category: 'Mid Cap',
        expenseRatio: 1.2,
        holdings: 38,
      ),
      MutualFundInputData(
        id: 'fund-3',
        name: 'Small Cap Opportunities',
        currentValue: 28.94,
        changeAmount: 0.45,
        changePercent: 1.58,
        lastUpdated: DateTime.now(),
        aum: 800000000, // 800M
        category: 'Small Cap',
        expenseRatio: 1.5,
        holdings: 62,
      ),
    ];
  }

  /// Create sample ETF data (since not in the JSON)
  static List<EtfInputData> createSampleEtfs() {
    return [
      EtfInputData(
        id: 'etf-1',
        name: 'Nifty 50 ETF',
        currentValue: 156.78,
        changeAmount: 1.23,
        changePercent: 0.79,
        lastUpdated: DateTime.now(),
        volume: 5000000,
        trackingIndex: 'Nifty 50',
        trackingError: 0.02,
        sector: 'Diversified',
      ),
      EtfInputData(
        id: 'etf-2',
        name: 'Bank Nifty ETF',
        currentValue: 423.45,
        changeAmount: -2.15,
        changePercent: -0.50,
        lastUpdated: DateTime.now(),
        volume: 2500000,
        trackingIndex: 'Bank Nifty',
        trackingError: 0.03,
        sector: 'Financial Services',
      ),
      EtfInputData(
        id: 'etf-3',
        name: 'IT Sector ETF',
        currentValue: 89.12,
        changeAmount: 0.67,
        changePercent: 0.76,
        lastUpdated: DateTime.now(),
        volume: 1800000,
        trackingIndex: 'Nifty IT',
        trackingError: 0.04,
        sector: 'Information Technology',
      ),
    ];
  }

  /// Create sample index data (since not in the JSON)
  static List<IndexInputData> createSampleIndices() {
    return [
      IndexInputData(
        id: 'index-1',
        name: 'Nifty 50',
        currentValue: 19456.78,
        changeAmount: 123.45,
        changePercent: 0.64,
        lastUpdated: DateTime.now(),
        marketCap: 15000000000000, // 15T
        constituents: 50,
      ),
      IndexInputData(
        id: 'index-2',
        name: 'Bank Nifty',
        currentValue: 43234.56,
        changeAmount: -234.67,
        changePercent: -0.54,
        lastUpdated: DateTime.now(),
        marketCap: 8000000000000, // 8T
        sector: 'Financial Services',
        constituents: 12,
      ),
      IndexInputData(
        id: 'index-3',
        name: 'Nifty IT',
        currentValue: 32145.89,
        changeAmount: 187.23,
        changePercent: 0.59,
        lastUpdated: DateTime.now(),
        marketCap: 5000000000000, // 5T
        sector: 'Information Technology',
        constituents: 10,
      ),
    ];
  }

  /// Parse portfolio analytics from JSON string
  static Map<String, dynamic> parsePortfolioAnalytics(String jsonString) {
    try {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      throw FormatException('Invalid JSON format: $e');
    }
  }

  /// Get all available data types from portfolio analytics
  static Map<InvestmentFilterType, List<InvestmentInputData>> getAllDataTypes(
    Map<String, dynamic> analyticsJson,
  ) {
    return {
      InvestmentFilterType.portfolio: convertPortfolioSectors(analyticsJson),
      InvestmentFilterType.stocks: convertPortfolioStocks(analyticsJson),
      InvestmentFilterType.sectors: convertSectorAllocation(analyticsJson),
      InvestmentFilterType.mutualFunds: createSampleMutualFunds(),
      InvestmentFilterType.etf: createSampleEtfs(),
      InvestmentFilterType.index: createSampleIndices(),
    };
  }
}
