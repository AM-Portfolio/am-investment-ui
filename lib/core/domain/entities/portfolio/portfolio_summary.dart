/// Domain model for portfolio summary
/// Business logic representation, independent of API structure
class PortfolioSummary {
  /// Portfolio value information
  final PortfolioValue portfolioValue;
  
  /// Performance metrics
  final PortfolioPerformance performance;
  
  /// Allocation breakdown
  final PortfolioAllocation allocation;
  
  /// Market insights
  final PortfolioInsights insights;
  
  /// Portfolio metadata
  final PortfolioSummaryMetadata metadata;

  /// Constructor
  const PortfolioSummary({
    required this.portfolioValue,
    required this.performance,
    required this.allocation,
    required this.insights,
    required this.metadata,
  });

  /// Create empty portfolio summary
  static PortfolioSummary empty() {
    return PortfolioSummary(
      portfolioValue: PortfolioValue.empty(),
      performance: PortfolioPerformance.empty(),
      allocation: PortfolioAllocation.empty(),
      insights: PortfolioInsights.empty(),
      metadata: PortfolioSummaryMetadata.empty(),
    );
  }

  /// Business logic methods
  bool get isPositive => performance.totalGain >= 0;
  bool get isTodayPositive => performance.todayGain >= 0;
  
  /// Get return on investment percentage
  double get returnOnInvestment => 
      portfolioValue.invested > 0 ? (performance.totalGain / portfolioValue.invested) * 100 : 0.0;
  
  /// Check if portfolio is well diversified (no single sector > 30%)
  bool get isWellDiversified => 
      allocation.sectorBreakdown.values.every((percentage) => percentage <= 30.0);
  
  /// Get dominant sector
  String get dominantSector {
    if (allocation.sectorBreakdown.isEmpty) return 'N/A';
    return allocation.sectorBreakdown.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  /// Copy with modifications
  PortfolioSummary copyWith({
    PortfolioValue? portfolioValue,
    PortfolioPerformance? performance,
    PortfolioAllocation? allocation,
    PortfolioInsights? insights,
    PortfolioSummaryMetadata? metadata,
  }) {
    return PortfolioSummary(
      portfolioValue: portfolioValue ?? this.portfolioValue,
      performance: performance ?? this.performance,
      allocation: allocation ?? this.allocation,
      insights: insights ?? this.insights,
      metadata: metadata ?? this.metadata,
    );
  }
}

/// Value object for portfolio value information
class PortfolioValue {
  final double current;
  final double invested;
  final String currency;

  const PortfolioValue({
    required this.current,
    required this.invested,
    required this.currency,
  });

  static PortfolioValue empty() {
    return const PortfolioValue(
      current: 0.0,
      invested: 0.0,
      currency: 'USD',
    );
  }

  /// Get net worth (current value)
  double get netWorth => current;
  
  /// Check if portfolio has grown
  bool get hasGrown => current > invested;
}

/// Value object for portfolio performance metrics
class PortfolioPerformance {
  final double totalGain;
  final double totalGainPercentage;
  final double todayGain;
  final double todayGainPercentage;

  const PortfolioPerformance({
    required this.totalGain,
    required this.totalGainPercentage,
    required this.todayGain,
    required this.todayGainPercentage,
  });

  static PortfolioPerformance empty() {
    return const PortfolioPerformance(
      totalGain: 0.0,
      totalGainPercentage: 0.0,
      todayGain: 0.0,
      todayGainPercentage: 0.0,
    );
  }

  /// Check if overall performance is positive
  bool get isTotalPositive => totalGain >= 0;
  
  /// Check if today's performance is positive
  bool get isTodayPositive => todayGain >= 0;
  
  /// Get performance category
  PerformanceCategory get category {
    if (totalGainPercentage >= 20) return PerformanceCategory.excellent;
    if (totalGainPercentage >= 10) return PerformanceCategory.good;
    if (totalGainPercentage >= 0) return PerformanceCategory.fair;
    if (totalGainPercentage >= -10) return PerformanceCategory.poor;
    return PerformanceCategory.terrible;
  }
}

/// Value object for portfolio allocation breakdown
class PortfolioAllocation {
  final Map<MarketCapCategory, List<MarketCapHolding>> marketCapBreakdown;
  final Map<String, double> sectorBreakdown;

  const PortfolioAllocation({
    required this.marketCapBreakdown,
    required this.sectorBreakdown,
  });

  static PortfolioAllocation empty() {
    return const PortfolioAllocation(
      marketCapBreakdown: {},
      sectorBreakdown: {},
    );
  }

  /// Get total number of holdings across all market caps
  int get totalHoldings => marketCapBreakdown.values
      .fold(0, (sum, holdings) => sum + holdings.length);
  
  /// Get market cap distribution percentages
  Map<MarketCapCategory, double> get marketCapDistribution {
    final total = totalHoldings;
    if (total == 0) return {};
    
    return marketCapBreakdown.map((category, holdings) => 
        MapEntry(category, (holdings.length / total) * 100));
  }
  
  /// Check if allocation is balanced
  bool get isBalanced => sectorBreakdown.values.every((percentage) => percentage <= 25.0);
}

/// Domain model for market cap holding
class MarketCapHolding {
  final HoldingIdentity identity;
  final double quantity;
  final double investedAmount;
  final List<BrokerAllocation> brokerAllocations;

  const MarketCapHolding({
    required this.identity,
    required this.quantity,
    required this.investedAmount,
    required this.brokerAllocations,
  });

  /// Get primary broker (with highest allocation)
  BrokerAllocation? get primaryBroker {
    if (brokerAllocations.isEmpty) return null;
    return brokerAllocations.reduce((a, b) => a.quantity > b.quantity ? a : b);
  }
}

/// Value object for broker allocation
class BrokerAllocation {
  final String brokerName;
  final double quantity;
  final double percentage;

  const BrokerAllocation({
    required this.brokerName,
    required this.quantity,
    required this.percentage,
  });
}

/// Value object for holding identity (reused from holdings model)
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

/// Value object for portfolio insights
class PortfolioInsights {
  final List<TopPerformer> topPerformers;
  final List<TopLoser> topLosers;
  final List<String> recommendations;

  const PortfolioInsights({
    required this.topPerformers,
    required this.topLosers,
    required this.recommendations,
  });

  static PortfolioInsights empty() {
    return const PortfolioInsights(
      topPerformers: [],
      topLosers: [],
      recommendations: [],
    );
  }

  /// Get best performing stock
  TopPerformer? get bestPerformer {
    if (topPerformers.isEmpty) return null;
    return topPerformers.first;
  }
  
  /// Get worst performing stock
  TopLoser? get worstPerformer {
    if (topLosers.isEmpty) return null;
    return topLosers.first;
  }
}

/// Domain model for top performer
class TopPerformer {
  final String symbol;
  final String displayName;
  final double gainPercentage;
  final double gainAmount;

  const TopPerformer({
    required this.symbol,
    required this.displayName,
    required this.gainPercentage,
    required this.gainAmount,
  });

  /// Check if it's a significant gain (>10%)
  bool get isSignificantGain => gainPercentage >= 10.0;
}

/// Domain model for top loser
class TopLoser {
  final String symbol;
  final String displayName;
  final double lossPercentage;
  final double lossAmount;

  const TopLoser({
    required this.symbol,
    required this.displayName,
    required this.lossPercentage,
    required this.lossAmount,
  });

  /// Check if it's a significant loss (>10%)
  bool get isSignificantLoss => lossPercentage >= 10.0;
}

/// Portfolio summary metadata
class PortfolioSummaryMetadata {
  final DateTime lastUpdated;
  final String currency;
  final int totalHoldings;
  final DataSource dataSource;

  const PortfolioSummaryMetadata({
    required this.lastUpdated,
    required this.currency,
    required this.totalHoldings,
    required this.dataSource,
  });

  static PortfolioSummaryMetadata empty() {
    return PortfolioSummaryMetadata(
      lastUpdated: DateTime.now(),
      currency: 'USD',
      totalHoldings: 0,
      dataSource: DataSource.api,
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

/// Enum for performance categories
enum PerformanceCategory {
  excellent,
  good,
  fair,
  poor,
  terrible;

  String get displayName {
    switch (this) {
      case PerformanceCategory.excellent:
        return 'Excellent';
      case PerformanceCategory.good:
        return 'Good';
      case PerformanceCategory.fair:
        return 'Fair';
      case PerformanceCategory.poor:
        return 'Poor';
      case PerformanceCategory.terrible:
        return 'Terrible';
    }
  }

  String get description {
    switch (this) {
      case PerformanceCategory.excellent:
        return 'Outstanding returns! Your portfolio is performing exceptionally well.';
      case PerformanceCategory.good:
        return 'Strong performance! Your investments are doing well.';
      case PerformanceCategory.fair:
        return 'Modest gains. Consider reviewing your investment strategy.';
      case PerformanceCategory.poor:
        return 'Below expectations. Consider rebalancing your portfolio.';
      case PerformanceCategory.terrible:
        return 'Significant losses. Review your investment strategy immediately.';
    }
  }
}

/// Enum for data source
enum DataSource {
  api,
  cache,
  mock;

  String get displayName {
    switch (this) {
      case DataSource.api:
        return 'Real-time';
      case DataSource.cache:
        return 'Cached';
      case DataSource.mock:
        return 'Demo Data';
    }
  }
}