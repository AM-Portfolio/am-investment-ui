import 'package:freezed_annotation/freezed_annotation.dart';

part 'portfolio_holdings.freezed.dart';
part 'portfolio_holdings.g.dart';

@freezed
class PortfolioHoldings with _$PortfolioHoldings {
  const PortfolioHoldings._();
  
  const factory PortfolioHoldings({
    required List<EquityHolding> holdings,
    required PortfolioMetadata metadata,
  }) = _PortfolioHoldings;

  factory PortfolioHoldings.empty() {
    return PortfolioHoldings(
      holdings: const [],
      metadata: PortfolioMetadata.empty(),
    );
  }

  factory PortfolioHoldings.fromJson(Map<String, dynamic> json) =>
      _$PortfolioHoldingsFromJson(json);

  bool get isEmpty => holdings.isEmpty;
  int get totalHoldings => holdings.length;
  
  double get totalValue => holdings.fold(0.0, (sum, holding) => sum + holding.currentValue);
  
  double get totalInvested => holdings.fold(0.0, (sum, holding) => sum + holding.investedAmount);
  
  double get totalGainLoss => totalValue - totalInvested;
  
  double get totalGainLossPercentage => 
      totalInvested > 0 ? (totalGainLoss / totalInvested) * 100 : 0.0;

  Map<String, List<EquityHolding>> get holdingsBySector {
    final Map<String, List<EquityHolding>> sectors = {};
    for (final holding in holdings) {
      sectors.putIfAbsent(holding.sector, () => []).add(holding);
    }
    return sectors;
  }

  List<EquityHolding> getTopPerformers(int count) {
    final sorted = List<EquityHolding>.from(holdings);
    sorted.sort((a, b) => b.performance.totalGainLossPercentage
        .compareTo(a.performance.totalGainLossPercentage));
    return sorted.take(count).toList();
  }
}

@freezed
class EquityHolding with _$EquityHolding {
  const EquityHolding._();
  
  const factory EquityHolding({
    required HoldingIdentity identity,
    required InvestmentDetails investment,
    required PerformanceMetrics performance,
    required List<BrokerHolding> brokerHoldings,
  }) = _EquityHolding;

  factory EquityHolding.fromJson(Map<String, dynamic> json) =>
      _$EquityHoldingFromJson(json);

  String get id => identity.isin;
  String get symbol => identity.symbol;
  String get sector => identity.sector;
  String get industry => identity.industry;
  double get shares => investment.quantity;
  double get currentPrice => investment.currentPrice;
  double get currentValue => investment.currentValue;
  double get investedAmount => investment.totalInvested;
  double get portfolioWeight => investment.portfolioWeight;

  bool get isProfitable => performance.totalGainLoss >= 0;
  bool get isTodayPositive => performance.todayGainLoss >= 0;
  
  BrokerHolding? get primaryBroker {
    if (brokerHoldings.isEmpty) return null;
    return brokerHoldings.reduce((a, b) => a.quantity > b.quantity ? a : b);
  }
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
class InvestmentDetails with _$InvestmentDetails {
  const InvestmentDetails._();
  
  const factory InvestmentDetails({
    required double quantity,
    required double averageCost,
    required double totalInvested,
    required double currentPrice,
    required double currentValue,
    required double portfolioWeight,
  }) = _InvestmentDetails;

  factory InvestmentDetails.fromJson(Map<String, dynamic> json) =>
      _$InvestmentDetailsFromJson(json);

  double get profitPerShare => currentPrice - averageCost;
}

@freezed
class PerformanceMetrics with _$PerformanceMetrics {
  const PerformanceMetrics._();
  
  const factory PerformanceMetrics({
    required double totalGainLoss,
    required double totalGainLossPercentage,
    required double todayGainLoss,
    required double todayGainLossPercentage,
    required double priceChange,
    required double priceChangePercentage,
  }) = _PerformanceMetrics;

  factory PerformanceMetrics.fromJson(Map<String, dynamic> json) =>
      _$PerformanceMetricsFromJson(json);

  bool get isTotalPositive => totalGainLoss >= 0;
  bool get isTodayPositive => todayGainLoss >= 0;
}

@freezed
class BrokerHolding with _$BrokerHolding {
  const factory BrokerHolding({
    required String brokerName,
    required double quantity,
    required double percentage,
    required String brokerType,
  }) = _BrokerHolding;

  factory BrokerHolding.fromJson(Map<String, dynamic> json) =>
      _$BrokerHoldingFromJson(json);
}

@freezed
class PortfolioMetadata with _$PortfolioMetadata {
  const factory PortfolioMetadata({
    required DateTime lastUpdated,
    required String currency,
    required int totalHoldings,
  }) = _PortfolioMetadata;

  factory PortfolioMetadata.empty() {
    return PortfolioMetadata(
      lastUpdated: DateTime.now(),
      currency: 'USD',
      totalHoldings: 0,
    );
  }

  factory PortfolioMetadata.fromJson(Map<String, dynamic> json) =>
      _$PortfolioMetadataFromJson(json);
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