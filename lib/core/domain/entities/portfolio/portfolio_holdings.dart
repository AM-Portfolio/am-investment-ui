/// Domain model for portfolio holdings
/// Business logic representation, independent of API structure
class PortfolioHoldings {
  /// List of equity holdings
  final List<EquityHolding> holdings;
  
  /// Portfolio metadata
  final PortfolioMetadata metadata;

  /// Constructor
  const PortfolioHoldings({
    required this.holdings,
    required this.metadata,
  });

  /// Create empty portfolio
  static PortfolioHoldings empty() {
    return PortfolioHoldings(
      holdings: const [],
      metadata: PortfolioMetadata.empty(),
    );
  }

  /// Business logic methods
  bool get isEmpty => holdings.isEmpty;
  int get totalHoldings => holdings.length;
  
  /// Get total portfolio value
  double get totalValue => holdings.fold(0.0, (sum, holding) => sum + holding.currentValue);
  
  /// Get total invested amount
  double get totalInvested => holdings.fold(0.0, (sum, holding) => sum + holding.investedAmount);
  
  /// Get overall gain/loss
  double get totalGainLoss => totalValue - totalInvested;
  
  /// Get overall gain/loss percentage
  double get totalGainLossPercentage => 
      totalInvested > 0 ? (totalGainLoss / totalInvested) * 100 : 0.0;

  /// Get holdings by sector
  Map<String, List<EquityHolding>> get holdingsBySector {
    final Map<String, List<EquityHolding>> sectors = {};
    for (final holding in holdings) {
      sectors.putIfAbsent(holding.sector, () => []).add(holding);
    }
    return sectors;
  }

  /// Get top performing holdings
  List<EquityHolding> getTopPerformers(int count) {
    final sorted = List<EquityHolding>.from(holdings);
    sorted.sort((a, b) => b.performance.totalGainLossPercentage
        .compareTo(a.performance.totalGainLossPercentage));
    return sorted.take(count).toList();
  }

  /// Copy with modifications
  PortfolioHoldings copyWith({
    List<EquityHolding>? holdings,
    PortfolioMetadata? metadata,
  }) {
    return PortfolioHoldings(
      holdings: holdings ?? this.holdings,
      metadata: metadata ?? this.metadata,
    );
  }
}

/// Domain model for individual equity holding
class EquityHolding {
  /// Identity
  final HoldingIdentity identity;
  
  /// Investment details
  final InvestmentDetails investment;
  
  /// Performance metrics
  final PerformanceMetrics performance;
  
  /// Broker distribution
  final List<BrokerHolding> brokerHoldings;

  /// Constructor
  const EquityHolding({
    required this.identity,
    required this.investment,
    required this.performance,
    required this.brokerHoldings,
  });

  /// Convenience getters
  String get id => identity.isin;
  String get symbol => identity.symbol;
  String get sector => identity.sector;
  String get industry => identity.industry;
  double get shares => investment.quantity;
  double get currentPrice => investment.currentPrice;
  double get currentValue => investment.currentValue;
  double get investedAmount => investment.totalInvested;
  double get portfolioWeight => investment.portfolioWeight;

  /// Business logic methods
  bool get isProfitable => performance.totalGainLoss >= 0;
  bool get isTodayPositive => performance.todayGainLoss >= 0;
  
  /// Get broker with highest holding
  BrokerHolding? get primaryBroker {
    if (brokerHoldings.isEmpty) return null;
    return brokerHoldings.reduce((a, b) => a.quantity > b.quantity ? a : b);
  }

  /// Copy with modifications
  EquityHolding copyWith({
    HoldingIdentity? identity,
    InvestmentDetails? investment,
    PerformanceMetrics? performance,
    List<BrokerHolding>? brokerHoldings,
  }) {
    return EquityHolding(
      identity: identity ?? this.identity,
      investment: investment ?? this.investment,
      performance: performance ?? this.performance,
      brokerHoldings: brokerHoldings ?? this.brokerHoldings,
    );
  }
}

/// Value object for holding identity
class HoldingIdentity {
  final String isin;
  final String symbol;
  final String companyName;
  final String sector;
  final String industry;
  final MarketCapCategory marketCap;

  const HoldingIdentity({
    required this.isin,
    required this.symbol,
    required this.companyName,
    required this.sector,
    required this.industry,
    required this.marketCap,
  });

  /// Get display name (prefer company name over symbol)
  String get displayName => companyName.isNotEmpty ? companyName : symbol;
}

/// Value object for investment details
class InvestmentDetails {
  final double quantity;
  final double averageCost;
  final double totalInvested;
  final double currentPrice;
  final double currentValue;
  final double portfolioWeight;

  const InvestmentDetails({
    required this.quantity,
    required this.averageCost,
    required this.totalInvested,
    required this.currentPrice,
    required this.currentValue,
    required this.portfolioWeight,
  });

  /// Calculate profit per share
  double get profitPerShare => currentPrice - averageCost;
}

/// Value object for performance metrics
class PerformanceMetrics {
  final double totalGainLoss;
  final double totalGainLossPercentage;
  final double todayGainLoss;
  final double todayGainLossPercentage;
  final double priceChange;
  final double priceChangePercentage;

  const PerformanceMetrics({
    required this.totalGainLoss,
    required this.totalGainLossPercentage,
    required this.todayGainLoss,
    required this.todayGainLossPercentage,
    required this.priceChange,
    required this.priceChangePercentage,
  });

  /// Check if overall performance is positive
  bool get isTotalPositive => totalGainLoss >= 0;
  
  /// Check if today's performance is positive
  bool get isTodayPositive => todayGainLoss >= 0;
}

/// Domain model for broker holding
class BrokerHolding {
  final String brokerName;
  final double quantity;
  final double percentage;
  final String brokerType;

  const BrokerHolding({
    required this.brokerName,
    required this.quantity,
    required this.percentage,
    required this.brokerType,
  });
}

/// Portfolio metadata
class PortfolioMetadata {
  final DateTime lastUpdated;
  final String currency;
  final int totalHoldings;

  const PortfolioMetadata({
    required this.lastUpdated,
    required this.currency,
    required this.totalHoldings,
  });

  static PortfolioMetadata empty() {
    return PortfolioMetadata(
      lastUpdated: DateTime.now(),
      currency: 'USD',
      totalHoldings: 0,
    );
  }
}

/// Enum for market cap categories
enum MarketCapCategory {
  largeCap,
  midCap,
  smallCap,
  microCap,
  unknown;

  /// Create from string
  static MarketCapCategory fromString(String value) {
    switch (value.toLowerCase()) {
      case 'large':
      case 'largecap':
      case 'large cap':
        return MarketCapCategory.largeCap;
      case 'mid':
      case 'midcap':
      case 'mid cap':
        return MarketCapCategory.midCap;
      case 'small':
      case 'smallcap':
      case 'small cap':
        return MarketCapCategory.smallCap;
      case 'micro':
      case 'microcap':
      case 'micro cap':
        return MarketCapCategory.microCap;
      default:
        return MarketCapCategory.unknown;
    }
  }

  /// Display string
  String get displayName {
    switch (this) {
      case MarketCapCategory.largeCap:
        return 'Large Cap';
      case MarketCapCategory.midCap:
        return 'Mid Cap';
      case MarketCapCategory.smallCap:
        return 'Small Cap';
      case MarketCapCategory.microCap:
        return 'Micro Cap';
      case MarketCapCategory.unknown:
        return 'Unknown';
    }
  }
}