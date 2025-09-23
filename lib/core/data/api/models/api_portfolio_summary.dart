/// API response model for portfolio summary
/// This model directly maps to the API response structure
class ApiPortfolioSummaryResponse {
  /// Raw API fields - exact mapping to backend response
  final double totalValue;
  final double investmentValue;
  final double todaysGain;
  final double totalGain;
  final double totalGainPercentage;
  final double todaysGainPercentage;
  final Map<String, List<ApiMarketCapHolding>> marketCapHoldings;
  final Map<String, double> sectorAllocation;
  final List<ApiTopPerformer> topPerformers;
  final List<ApiTopLoser> topLosers;

  /// Constructor
  const ApiPortfolioSummaryResponse({
    required this.totalValue,
    required this.investmentValue,
    required this.todaysGain,
    required this.totalGain,
    required this.totalGainPercentage,
    required this.todaysGainPercentage,
    required this.marketCapHoldings,
    required this.sectorAllocation,
    required this.topPerformers,
    required this.topLosers,
  });

  /// Create from JSON response
  factory ApiPortfolioSummaryResponse.fromJson(Map<String, dynamic> json) {
    return ApiPortfolioSummaryResponse(
      totalValue: _parseDouble(json['totalValue']),
      investmentValue: _parseDouble(json['investmentValue']),
      todaysGain: _parseDouble(json['todaysGain']),
      totalGain: _parseDouble(json['totalGain']),
      totalGainPercentage: _parseDouble(json['totalGainPercentage']),
      todaysGainPercentage: _parseDouble(json['todaysGainPercentage']),
      marketCapHoldings: _parseMarketCapHoldings(json['marketCapHoldings']),
      sectorAllocation: _parseSectorAllocation(json['sectorAllocation']),
      topPerformers: _parseTopPerformers(json['topPerformers']),
      topLosers: _parseTopLosers(json['topLosers']),
    );
  }

  /// Helper method to safely parse double values from API
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is String) {
      try {
        return double.parse(value);
      } catch (_) {
        return 0.0;
      }
    }
    return 0.0;
  }

  /// Parse market cap holdings
  static Map<String, List<ApiMarketCapHolding>> _parseMarketCapHoldings(
      dynamic value) {
    if (value == null) return {};
    
    final Map<String, List<ApiMarketCapHolding>> result = {};
    final map = value as Map<String, dynamic>;
    
    for (final entry in map.entries) {
      final holdings = (entry.value as List? ?? [])
          .map((h) => ApiMarketCapHolding.fromJson(h))
          .toList();
      result[entry.key] = holdings;
    }
    
    return result;
  }

  /// Parse sector allocation
  static Map<String, double> _parseSectorAllocation(dynamic value) {
    if (value == null) return {};
    
    final Map<String, double> result = {};
    final map = value as Map<String, dynamic>;
    
    for (final entry in map.entries) {
      result[entry.key] = _parseDouble(entry.value);
    }
    
    return result;
  }

  /// Parse top performers
  static List<ApiTopPerformer> _parseTopPerformers(dynamic value) {
    if (value == null) return [];
    return (value as List)
        .map((p) => ApiTopPerformer.fromJson(p))
        .toList();
  }

  /// Parse top losers
  static List<ApiTopLoser> _parseTopLosers(dynamic value) {
    if (value == null) return [];
    return (value as List)
        .map((l) => ApiTopLoser.fromJson(l))
        .toList();
  }

  /// Convert to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'totalValue': totalValue,
      'investmentValue': investmentValue,
      'todaysGain': todaysGain,
      'totalGain': totalGain,
      'totalGainPercentage': totalGainPercentage,
      'todaysGainPercentage': todaysGainPercentage,
      'marketCapHoldings': marketCapHoldings.map(
        (key, value) => MapEntry(key, value.map((h) => h.toJson()).toList()),
      ),
      'sectorAllocation': sectorAllocation,
      'topPerformers': topPerformers.map((p) => p.toJson()).toList(),
      'topLosers': topLosers.map((l) => l.toJson()).toList(),
    };
  }
}

/// API model for market cap holding
class ApiMarketCapHolding {
  final String isin;
  final String symbol;
  final String sector;
  final String industry;
  final String marketCap;
  final double quantity;
  final double investmentCost;
  final List<ApiBrokerHolding> brokerPortfolios;

  const ApiMarketCapHolding({
    required this.isin,
    required this.symbol,
    required this.sector,
    required this.industry,
    required this.marketCap,
    required this.quantity,
    required this.investmentCost,
    required this.brokerPortfolios,
  });

  factory ApiMarketCapHolding.fromJson(Map<String, dynamic> json) {
    return ApiMarketCapHolding(
      isin: json['isin'] as String? ?? '',
      symbol: json['symbol'] as String? ?? '',
      sector: json['sector'] as String? ?? '',
      industry: json['industry'] as String? ?? '',
      marketCap: json['marketCap'] as String? ?? '',
      quantity: ApiPortfolioSummaryResponse._parseDouble(json['quantity']),
      investmentCost: ApiPortfolioSummaryResponse._parseDouble(json['investmentCost']),
      brokerPortfolios: (json['brokerPortfolios'] as List? ?? [])
          .map((b) => ApiBrokerHolding.fromJson(b))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isin': isin,
      'symbol': symbol,
      'sector': sector,
      'industry': industry,
      'marketCap': marketCap,
      'quantity': quantity,
      'investmentCost': investmentCost,
      'brokerPortfolios': brokerPortfolios.map((b) => b.toJson()).toList(),
    };
  }
}

/// API model for broker holding in summary
class ApiBrokerHolding {
  final String brokerType;
  final double quantity;

  const ApiBrokerHolding({
    required this.brokerType,
    required this.quantity,
  });

  factory ApiBrokerHolding.fromJson(Map<String, dynamic> json) {
    return ApiBrokerHolding(
      brokerType: json['brokerType'] as String? ?? '',
      quantity: ApiPortfolioSummaryResponse._parseDouble(json['quantity']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'brokerType': brokerType,
      'quantity': quantity,
    };
  }
}

/// API model for top performer
class ApiTopPerformer {
  final String symbol;
  final double gainPercentage;
  final double gainAmount;

  const ApiTopPerformer({
    required this.symbol,
    required this.gainPercentage,
    required this.gainAmount,
  });

  factory ApiTopPerformer.fromJson(Map<String, dynamic> json) {
    return ApiTopPerformer(
      symbol: json['symbol'] as String? ?? '',
      gainPercentage: ApiPortfolioSummaryResponse._parseDouble(json['gainPercentage']),
      gainAmount: ApiPortfolioSummaryResponse._parseDouble(json['gainAmount']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'gainPercentage': gainPercentage,
      'gainAmount': gainAmount,
    };
  }
}

/// API model for top loser
class ApiTopLoser {
  final String symbol;
  final double lossPercentage;
  final double lossAmount;

  const ApiTopLoser({
    required this.symbol,
    required this.lossPercentage,
    required this.lossAmount,
  });

  factory ApiTopLoser.fromJson(Map<String, dynamic> json) {
    return ApiTopLoser(
      symbol: json['symbol'] as String? ?? '',
      lossPercentage: ApiPortfolioSummaryResponse._parseDouble(json['lossPercentage']),
      lossAmount: ApiPortfolioSummaryResponse._parseDouble(json['lossAmount']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'lossPercentage': lossPercentage,
      'lossAmount': lossAmount,
    };
  }
}