/// Model classes for portfolio data

/// Portfolio summary model
class PortfolioSummary {
  /// Total investment value
  final double investmentValue;
  
  /// Current portfolio value
  final double currentValue;
  
  /// Total gain/loss amount
  final double totalGainLoss;
  
  /// Total gain/loss percentage
  final double totalGainLossPercentage;
  
  /// Today's gain/loss amount
  final double todayGainLoss;
  
  /// Today's gain/loss percentage
  final double todayGainLossPercentage;
  
  /// Total number of assets
  final int totalAssets;
  
  /// Number of gaining assets
  final int gainersCount;
  
  /// Number of losing assets
  final int losersCount;
  
  /// Number of assets gaining today
  final int todayGainersCount;
  
  /// Number of assets losing today
  final int todayLosersCount;
  
  /// Last updated timestamp
  final DateTime lastUpdated;
  
  /// Broker portfolios breakdown
  final Map<String, BrokerPortfolio> brokerPortfolios;
  
  /// Market cap holdings breakdown
  final Map<String, List<AssetHolding>> marketCapHoldings;
  
  /// Sectorial holdings breakdown
  final Map<String, List<AssetHolding>> sectorialHoldings;

  /// Constructor
  PortfolioSummary({
    required this.investmentValue,
    required this.currentValue,
    required this.totalGainLoss,
    required this.totalGainLossPercentage,
    required this.todayGainLoss,
    required this.todayGainLossPercentage,
    required this.totalAssets,
    required this.gainersCount,
    required this.losersCount,
    required this.todayGainersCount,
    required this.todayLosersCount,
    required this.lastUpdated,
    required this.brokerPortfolios,
    required this.marketCapHoldings,
    required this.sectorialHoldings,
  });

  /// Create from JSON
  factory PortfolioSummary.fromJson(Map<String, dynamic> json) {
    // Parse broker portfolios
    final Map<String, BrokerPortfolio> brokerPortfolios = {};
    if (json['brokerPortfolios'] != null) {
      json['brokerPortfolios'].forEach((key, value) {
        brokerPortfolios[key] = BrokerPortfolio.fromJson(value);
      });
    }

    // Parse market cap holdings
    final Map<String, List<AssetHolding>> marketCapHoldings = {};
    if (json['marketCapHoldings'] != null) {
      json['marketCapHoldings'].forEach((key, value) {
        marketCapHoldings[key] = (value as List)
            .map((item) => AssetHolding.fromJson(item))
            .toList();
      });
    }

    // Parse sectorial holdings
    final Map<String, List<AssetHolding>> sectorialHoldings = {};
    if (json['sectorialHoldings'] != null) {
      json['sectorialHoldings'].forEach((key, value) {
        sectorialHoldings[key] = (value as List)
            .map((item) => AssetHolding.fromJson(item))
            .toList();
      });
    }

    return PortfolioSummary(
      investmentValue: json['investmentValue']?.toDouble() ?? 0.0,
      currentValue: json['currentValue']?.toDouble() ?? 0.0,
      totalGainLoss: json['totalGainLoss']?.toDouble() ?? 0.0,
      totalGainLossPercentage: json['totalGainLossPercentage']?.toDouble() ?? 0.0,
      todayGainLoss: json['todayGainLoss']?.toDouble() ?? 0.0,
      todayGainLossPercentage: json['todayGainLossPercentage']?.toDouble() ?? 0.0,
      totalAssets: json['totalAssets'] ?? 0,
      gainersCount: json['gainersCount'] ?? 0,
      losersCount: json['losersCount'] ?? 0,
      todayGainersCount: json['todayGainersCount'] ?? 0,
      todayLosersCount: json['todayLosersCount'] ?? 0,
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'])
          : DateTime.now(),
      brokerPortfolios: brokerPortfolios,
      marketCapHoldings: marketCapHoldings,
      sectorialHoldings: sectorialHoldings,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> brokerPortfoliosJson = {};
    brokerPortfolios.forEach((key, value) {
      brokerPortfoliosJson[key] = value.toJson();
    });

    final Map<String, dynamic> marketCapHoldingsJson = {};
    marketCapHoldings.forEach((key, value) {
      marketCapHoldingsJson[key] = value.map((item) => item.toJson()).toList();
    });

    final Map<String, dynamic> sectorialHoldingsJson = {};
    sectorialHoldings.forEach((key, value) {
      sectorialHoldingsJson[key] = value.map((item) => item.toJson()).toList();
    });

    return {
      'investmentValue': investmentValue,
      'currentValue': currentValue,
      'totalGainLoss': totalGainLoss,
      'totalGainLossPercentage': totalGainLossPercentage,
      'todayGainLoss': todayGainLoss,
      'todayGainLossPercentage': todayGainLossPercentage,
      'totalAssets': totalAssets,
      'gainersCount': gainersCount,
      'losersCount': losersCount,
      'todayGainersCount': todayGainersCount,
      'todayLosersCount': todayLosersCount,
      'lastUpdated': lastUpdated.toIso8601String(),
      'brokerPortfolios': brokerPortfoliosJson,
      'marketCapHoldings': marketCapHoldingsJson,
      'sectorialHoldings': sectorialHoldingsJson,
    };
  }
}

/// Broker portfolio model
class BrokerPortfolio {
  /// Investment value in this broker
  final double investmentValue;
  
  /// Total assets in this broker
  final int totalAssets;

  /// Constructor
  BrokerPortfolio({
    required this.investmentValue,
    required this.totalAssets,
  });

  /// Create from JSON
  factory BrokerPortfolio.fromJson(Map<String, dynamic> json) {
    return BrokerPortfolio(
      investmentValue: json['investmentValue']?.toDouble() ?? 0.0,
      totalAssets: json['totalAssets'] ?? 0,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'investmentValue': investmentValue,
      'totalAssets': totalAssets,
    };
  }
}

/// Asset holding model
class AssetHolding {
  /// ISIN code
  final String isin;
  
  /// Symbol/ticker
  final String symbol;
  
  /// Sector
  final String? sector;
  
  /// Industry
  final String? industry;
  
  /// Market cap category
  final String? marketCap;
  
  /// Quantity held
  final double quantity;
  
  /// Investment cost
  final double investmentCost;
  
  /// Broker portfolios containing this asset
  final List<BrokerAssetHolding> brokerPortfolios;

  /// Constructor
  AssetHolding({
    required this.isin,
    required this.symbol,
    this.sector,
    this.industry,
    this.marketCap,
    required this.quantity,
    required this.investmentCost,
    required this.brokerPortfolios,
  });

  /// Create from JSON
  factory AssetHolding.fromJson(Map<String, dynamic> json) {
    return AssetHolding(
      isin: json['isin'] ?? '',
      symbol: json['symbol'] ?? '',
      sector: json['sector'],
      industry: json['industry'],
      marketCap: json['marketCap'],
      quantity: json['quantity']?.toDouble() ?? 0.0,
      investmentCost: json['investmentCost']?.toDouble() ?? 0.0,
      brokerPortfolios: json['brokerPortfolios'] != null
          ? (json['brokerPortfolios'] as List)
              .map((item) => BrokerAssetHolding.fromJson(item))
              .toList()
          : [],
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'isin': isin,
      'symbol': symbol,
      'sector': sector,
      'industry': industry,
      'marketCap': marketCap,
      'quantity': quantity,
      'investmentCost': investmentCost,
      'brokerPortfolios': brokerPortfolios.map((item) => item.toJson()).toList(),
    };
  }
}

/// Broker asset holding model
class BrokerAssetHolding {
  /// Broker type
  final String brokerType;
  
  /// Quantity held in this broker
  final double quantity;

  /// Constructor
  BrokerAssetHolding({
    required this.brokerType,
    required this.quantity,
  });

  /// Create from JSON
  factory BrokerAssetHolding.fromJson(Map<String, dynamic> json) {
    return BrokerAssetHolding(
      brokerType: json['brokerType'] ?? '',
      quantity: json['quantity']?.toDouble() ?? 0.0,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'brokerType': brokerType,
      'quantity': quantity,
    };
  }
}
