/// Web domain model for portfolio holdings
/// This model is decoupled from the API and represents the data as needed by the UI
class WebPortfolioHoldings {
  /// List of equity holdings for web display
  final List<WebEquityHolding> holdings;

  /// Total portfolio metrics
  final WebPortfolioMetrics? metrics;

  /// Constructor
  const WebPortfolioHoldings({
    required this.holdings,
    this.metrics,
  });

  /// Create empty holdings
  static const WebPortfolioHoldings empty = WebPortfolioHoldings(holdings: []);

  /// Check if holdings are empty
  bool get isEmpty => holdings.isEmpty;

  /// Get total number of holdings
  int get totalHoldings => holdings.length;

  /// Copy with new values
  WebPortfolioHoldings copyWith({
    List<WebEquityHolding>? holdings,
    WebPortfolioMetrics? metrics,
  }) {
    return WebPortfolioHoldings(
      holdings: holdings ?? this.holdings,
      metrics: metrics ?? this.metrics,
    );
  }
}

/// Web domain model for individual equity holding
class WebEquityHolding {
  /// Unique identifier (ISIN)
  final String id;

  /// Display information
  final String symbol;
  final String companyName;
  final String sector;
  final String industry;
  final String marketCapCategory;

  /// Investment details
  final double shares;
  final double averageCost;
  final double currentPrice;
  final double totalInvested;
  final double currentValue;
  final double portfolioWeight;

  /// Performance metrics
  final WebPerformanceMetrics performance;

  /// Broker breakdown
  final List<WebBrokerHolding> brokerBreakdown;

  /// Constructor
  const WebEquityHolding({
    required this.id,
    required this.symbol,
    required this.companyName,
    required this.sector,
    required this.industry,
    required this.marketCapCategory,
    required this.shares,
    required this.averageCost,
    required this.currentPrice,
    required this.totalInvested,
    required this.currentValue,
    required this.portfolioWeight,
    required this.performance,
    required this.brokerBreakdown,
  });

  /// Get formatted display name
  String get displayName => companyName.isNotEmpty ? companyName : symbol;

  /// Check if holding is profitable
  bool get isProfitable => performance.totalGainLoss >= 0;

  /// Copy with new values
  WebEquityHolding copyWith({
    String? id,
    String? symbol,
    String? companyName,
    String? sector,
    String? industry,
    String? marketCapCategory,
    double? shares,
    double? averageCost,
    double? currentPrice,
    double? totalInvested,
    double? currentValue,
    double? portfolioWeight,
    WebPerformanceMetrics? performance,
    List<WebBrokerHolding>? brokerBreakdown,
  }) {
    return WebEquityHolding(
      id: id ?? this.id,
      symbol: symbol ?? this.symbol,
      companyName: companyName ?? this.companyName,
      sector: sector ?? this.sector,
      industry: industry ?? this.industry,
      marketCapCategory: marketCapCategory ?? this.marketCapCategory,
      shares: shares ?? this.shares,
      averageCost: averageCost ?? this.averageCost,
      currentPrice: currentPrice ?? this.currentPrice,
      totalInvested: totalInvested ?? this.totalInvested,
      currentValue: currentValue ?? this.currentValue,
      portfolioWeight: portfolioWeight ?? this.portfolioWeight,
      performance: performance ?? this.performance,
      brokerBreakdown: brokerBreakdown ?? this.brokerBreakdown,
    );
  }
}

/// Performance metrics for web display
class WebPerformanceMetrics {
  /// Total gains/losses
  final double totalGainLoss;
  final double totalGainLossPercentage;

  /// Today's performance
  final double todayGainLoss;
  final double todayGainLossPercentage;

  /// Daily price change
  final double dailyPriceChange;
  final double dailyPriceChangePercentage;

  /// Constructor
  const WebPerformanceMetrics({
    required this.totalGainLoss,
    required this.totalGainLossPercentage,
    required this.todayGainLoss,
    required this.todayGainLossPercentage,
    required this.dailyPriceChange,
    required this.dailyPriceChangePercentage,
  });

  /// Check if today's performance is positive
  bool get isTodayPositive => todayGainLoss >= 0;

  /// Check if total performance is positive
  bool get isTotalPositive => totalGainLoss >= 0;

  /// Copy with new values
  WebPerformanceMetrics copyWith({
    double? totalGainLoss,
    double? totalGainLossPercentage,
    double? todayGainLoss,
    double? todayGainLossPercentage,
    double? dailyPriceChange,
    double? dailyPriceChangePercentage,
  }) {
    return WebPerformanceMetrics(
      totalGainLoss: totalGainLoss ?? this.totalGainLoss,
      totalGainLossPercentage: totalGainLossPercentage ?? this.totalGainLossPercentage,
      todayGainLoss: todayGainLoss ?? this.todayGainLoss,
      todayGainLossPercentage: todayGainLossPercentage ?? this.todayGainLossPercentage,
      dailyPriceChange: dailyPriceChange ?? this.dailyPriceChange,
      dailyPriceChangePercentage: dailyPriceChangePercentage ?? this.dailyPriceChangePercentage,
    );
  }
}

/// Broker holding breakdown for web display
class WebBrokerHolding {
  /// Broker name/type
  final String brokerName;

  /// Number of shares with this broker
  final double shares;

  /// Percentage of total holding
  final double percentage;

  /// Constructor
  const WebBrokerHolding({
    required this.brokerName,
    required this.shares,
    required this.percentage,
  });

  /// Copy with new values
  WebBrokerHolding copyWith({
    String? brokerName,
    double? shares,
    double? percentage,
  }) {
    return WebBrokerHolding(
      brokerName: brokerName ?? this.brokerName,
      shares: shares ?? this.shares,
      percentage: percentage ?? this.percentage,
    );
  }
}

/// Portfolio-level metrics for web display
class WebPortfolioMetrics {
  /// Total portfolio value
  final double totalValue;

  /// Total invested amount
  final double totalInvested;

  /// Overall performance
  final WebPerformanceMetrics overallPerformance;

  /// Number of holdings
  final int totalHoldings;

  /// Constructor
  const WebPortfolioMetrics({
    required this.totalValue,
    required this.totalInvested,
    required this.overallPerformance,
    required this.totalHoldings,
  });

  /// Copy with new values
  WebPortfolioMetrics copyWith({
    double? totalValue,
    double? totalInvested,
    WebPerformanceMetrics? overallPerformance,
    int? totalHoldings,
  }) {
    return WebPortfolioMetrics(
      totalValue: totalValue ?? this.totalValue,
      totalInvested: totalInvested ?? this.totalInvested,
      overallPerformance: overallPerformance ?? this.overallPerformance,
      totalHoldings: totalHoldings ?? this.totalHoldings,
    );
  }
}