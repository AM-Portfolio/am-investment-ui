import 'package:freezed_annotation/freezed_annotation.dart';

part 'portfolio_summary.freezed.dart';
part 'portfolio_summary.g.dart';

@freezed
class PortfolioSummary with _$PortfolioSummary {
  const factory PortfolioSummary({
    required String userId,
    required double totalValue,
    required double dailyChange,
    @Default([]) List<String> holdings,
  }) = _PortfolioSummary;

  factory PortfolioSummary.empty() {
    return const PortfolioSummary(
      userId: '',
      totalValue: 0.0,
      dailyChange: 0.0,
      holdings: [],
    );
  }

  factory PortfolioSummary.fromJson(Map<String, dynamic> json) =>
      _$PortfolioSummaryFromJson(json);
}

@freezed
class PortfolioValue with _$PortfolioValue {
  const PortfolioValue._();
  
  const factory PortfolioValue({
    required double current,
    required double invested,
    required String currency,
  }) = _PortfolioValue;

  factory PortfolioValue.empty() {
    return const PortfolioValue(
      current: 0.0,
      invested: 0.0,
      currency: 'USD',
    );
  }

  factory PortfolioValue.fromJson(Map<String, dynamic> json) =>
      _$PortfolioValueFromJson(json);

  double get netWorth => current;
  bool get hasGrown => current > invested;
}

@freezed
class PortfolioPerformance with _$PortfolioPerformance {
  const PortfolioPerformance._();
  
  const factory PortfolioPerformance({
    required double totalGain,
    required double totalGainPercentage,
    required double todayGain,
    required double todayGainPercentage,
  }) = _PortfolioPerformance;

  factory PortfolioPerformance.empty() {
    return const PortfolioPerformance(
      totalGain: 0.0,
      totalGainPercentage: 0.0,
      todayGain: 0.0,
      todayGainPercentage: 0.0,
    );
  }

  factory PortfolioPerformance.fromJson(Map<String, dynamic> json) =>
      _$PortfolioPerformanceFromJson(json);

  bool get isTotalPositive => totalGain >= 0;
  bool get isTodayPositive => todayGain >= 0;
  
  PerformanceCategory get category {
    if (totalGainPercentage >= 20) return PerformanceCategory.excellent;
    if (totalGainPercentage >= 10) return PerformanceCategory.good;
    if (totalGainPercentage >= 0) return PerformanceCategory.fair;
    if (totalGainPercentage >= -10) return PerformanceCategory.poor;
    return PerformanceCategory.terrible;
  }
}

@freezed
class PortfolioAllocation with _$PortfolioAllocation {
  const PortfolioAllocation._();
  
  const factory PortfolioAllocation({
    required Map<MarketCapCategory, List<MarketCapHolding>> marketCapBreakdown,
    required Map<String, double> sectorBreakdown,
  }) = _PortfolioAllocation;

  factory PortfolioAllocation.empty() {
    return const PortfolioAllocation(
      marketCapBreakdown: {},
      sectorBreakdown: {},
    );
  }

  factory PortfolioAllocation.fromJson(Map<String, dynamic> json) =>
      _$PortfolioAllocationFromJson(json);

  int get totalHoldings => marketCapBreakdown.values
      .fold(0, (sum, holdings) => sum + holdings.length);
  
  Map<MarketCapCategory, double> get marketCapDistribution {
    final total = totalHoldings;
    if (total == 0) return {};
    
    return marketCapBreakdown.map((category, holdings) => 
        MapEntry(category, (holdings.length / total) * 100));
  }
  
  bool get isBalanced => sectorBreakdown.values.every((percentage) => percentage <= 25.0);
}

@freezed
class MarketCapHolding with _$MarketCapHolding {
  const MarketCapHolding._();
  
  const factory MarketCapHolding({
    required HoldingIdentity identity,
    required double quantity,
    required double investedAmount,
    required List<BrokerAllocation> brokerAllocations,
  }) = _MarketCapHolding;

  factory MarketCapHolding.fromJson(Map<String, dynamic> json) =>
      _$MarketCapHoldingFromJson(json);

  BrokerAllocation? get primaryBroker {
    if (brokerAllocations.isEmpty) return null;
    return brokerAllocations.reduce((a, b) => a.quantity > b.quantity ? a : b);
  }
}

@freezed
class BrokerAllocation with _$BrokerAllocation {
  const factory BrokerAllocation({
    required String brokerName,
    required double quantity,
    required double percentage,
  }) = _BrokerAllocation;

  factory BrokerAllocation.fromJson(Map<String, dynamic> json) =>
      _$BrokerAllocationFromJson(json);
}

@freezed
class HoldingIdentity with _$HoldingIdentity {
  const HoldingIdentity._();
  
  const factory HoldingIdentity({
    required String isin,
    required String symbol,
    required String companyName,
    required String sector,
    required String industry,
    required MarketCapCategory marketCap,
  }) = _HoldingIdentity;

  factory HoldingIdentity.fromJson(Map<String, dynamic> json) =>
      _$HoldingIdentityFromJson(json);

  String get displayName => companyName.isNotEmpty ? companyName : symbol;
}

@freezed
class PortfolioInsights with _$PortfolioInsights {
  const PortfolioInsights._();
  
  const factory PortfolioInsights({
    required List<TopPerformer> topPerformers,
    required List<TopLoser> topLosers,
    required List<String> recommendations,
  }) = _PortfolioInsights;

  factory PortfolioInsights.empty() {
    return const PortfolioInsights(
      topPerformers: [],
      topLosers: [],
      recommendations: [],
    );
  }

  factory PortfolioInsights.fromJson(Map<String, dynamic> json) =>
      _$PortfolioInsightsFromJson(json);

  TopPerformer? get bestPerformer {
    if (topPerformers.isEmpty) return null;
    return topPerformers.first;
  }

  TopLoser? get worstPerformer {
    if (topLosers.isEmpty) return null;
    return topLosers.first;
  }
}

@freezed
class TopPerformer with _$TopPerformer {
  const TopPerformer._();
  
  const factory TopPerformer({
    required String symbol,
    required String displayName,
    required double gainPercentage,
    required double gainAmount,
  }) = _TopPerformer;

  factory TopPerformer.fromJson(Map<String, dynamic> json) =>
      _$TopPerformerFromJson(json);

  bool get isSignificantGain => gainPercentage >= 10.0;
}

@freezed
class TopLoser with _$TopLoser {
  const TopLoser._();
  
  const factory TopLoser({
    required String symbol,
    required String displayName,
    required double lossPercentage,
    required double lossAmount,
  }) = _TopLoser;

  factory TopLoser.fromJson(Map<String, dynamic> json) =>
      _$TopLoserFromJson(json);

  bool get isSignificantLoss => lossPercentage >= 10.0;
}

@freezed
class PortfolioSummaryMetadata with _$PortfolioSummaryMetadata {
  const factory PortfolioSummaryMetadata({
    required DateTime lastUpdated,
    required String currency,
    required int totalHoldings,
    required DataSource dataSource,
  }) = _PortfolioSummaryMetadata;

  factory PortfolioSummaryMetadata.empty() {
    return PortfolioSummaryMetadata(
      lastUpdated: DateTime.now(),
      currency: 'USD',
      totalHoldings: 0,
      dataSource: DataSource.api,
    );
  }

  factory PortfolioSummaryMetadata.fromJson(Map<String, dynamic> json) =>
      _$PortfolioSummaryMetadataFromJson(json);
}

enum MarketCapCategory {
  largeCap,
  midCap,
  smallCap,
  microCap,
  unknown;

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