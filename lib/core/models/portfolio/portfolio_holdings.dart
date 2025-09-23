/// Model class for portfolio holdings response
class PortfolioHoldings {
  /// List of equity holdings
  final List<EquityHolding> equityHoldings;

  /// Constructor
  PortfolioHoldings({required this.equityHoldings});

  /// Create from JSON
  factory PortfolioHoldings.fromJson(Map<String, dynamic> json) {
    return PortfolioHoldings(
      equityHoldings: (json['equityHoldings'] as List)
          .map((e) => EquityHolding.fromJson(e))
          .toList(),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {'equityHoldings': equityHoldings.map((e) => e.toJson()).toList()};
  }
}

/// Model class for equity holding
class EquityHolding {
  /// ISIN code
  final String isin;

  /// Stock symbol
  final String symbol;

  /// Sector
  final String sector;

  /// Industry
  final String industry;

  /// Market capitalization category
  final String marketCap;

  /// Quantity of shares
  final double quantity;

  /// Investment cost
  final double investmentCost;

  /// Current value
  final double currentValue;

  /// Weight in portfolio (percentage)
  final double weightInPortfolio;

  /// Total gain/loss
  final double gainLoss;

  /// Total gain/loss percentage
  final double gainLossPercentage;

  /// Today's gain/loss
  final double todayGainLoss;

  /// Today's gain/loss percentage
  final double todayGainLossPercentage;

  /// Current price per share
  final double currentPrice;

  /// Percentage change today
  final double percentageChange;

  /// Broker portfolios containing this holding
  final List<BrokerHolding> brokerPortfolios;

  /// Constructor
  EquityHolding({
    required this.isin,
    required this.symbol,
    required this.sector,
    required this.industry,
    required this.marketCap,
    required this.quantity,
    required this.investmentCost,
    required this.currentValue,
    required this.weightInPortfolio,
    required this.gainLoss,
    required this.gainLossPercentage,
    required this.todayGainLoss,
    required this.todayGainLossPercentage,
    required this.currentPrice,
    required this.percentageChange,
    required this.brokerPortfolios,
  });

  /// Create from JSON
  factory EquityHolding.fromJson(Map<String, dynamic> json) {
    return EquityHolding(
      isin: json['isin'] as String? ?? '',
      symbol: json['symbol'] as String? ?? '',
      sector: json['sector'] as String? ?? '',
      industry: json['industry'] as String? ?? '',
      marketCap: json['marketCap'] as String? ?? '',
      quantity: _parseDouble(json['quantity']),
      investmentCost: _parseDouble(json['investmentCost']),
      currentValue: _parseDouble(json['currentValue']),
      weightInPortfolio: _parseDouble(json['weightInPortfolio']),
      gainLoss: _parseDouble(json['gainLoss']),
      gainLossPercentage: _parseDouble(json['gainLossPercentage']),
      todayGainLoss: _parseDouble(json['todayGainLoss']),
      todayGainLossPercentage: _parseDouble(json['todayGainLossPercentage']),
      currentPrice: _parseDouble(json['currentPrice']),
      percentageChange: _parseDouble(json['percentageChange']),
      brokerPortfolios: json['brokerPortfolios'] != null
          ? (json['brokerPortfolios'] as List)
                .map((e) => BrokerHolding.fromJson(e))
                .toList()
          : [],
    );
  }

  /// Helper method to parse double values safely
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
      'currentValue': currentValue,
      'weightInPortfolio': weightInPortfolio,
      'gainLoss': gainLoss,
      'gainLossPercentage': gainLossPercentage,
      'todayGainLoss': todayGainLoss,
      'todayGainLossPercentage': todayGainLossPercentage,
      'currentPrice': currentPrice,
      'percentageChange': percentageChange,
      'brokerPortfolios': brokerPortfolios.map((e) => e.toJson()).toList(),
    };
  }
}

/// Model class for broker holding
class BrokerHolding {
  /// Broker type
  final String brokerType;

  /// Quantity of shares
  final double quantity;

  /// Constructor
  BrokerHolding({required this.brokerType, required this.quantity});

  /// Create from JSON
  factory BrokerHolding.fromJson(Map<String, dynamic> json) {
    return BrokerHolding(
      brokerType: json['brokerType'] as String? ?? '',
      quantity: EquityHolding._parseDouble(json['quantity']),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {'brokerType': brokerType, 'quantity': quantity};
  }
}
