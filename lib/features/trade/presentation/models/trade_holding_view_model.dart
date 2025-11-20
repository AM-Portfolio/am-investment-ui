import '../../internal/domain/entities/trade_controller_entities.dart';
import '../../internal/domain/entities/trade_holding.dart';

/// View model for presenting trade holding data in UI
/// Flattens nested domain structure for easier template consumption
class TradeHoldingViewModel {
  const TradeHoldingViewModel({
    required this.tradeId,
    required this.portfolioId,
    required this.symbol,
    required this.companyName,
    this.sector,
    this.industry,
    this.exchange,
    this.status,
    this.tradePositionType,
    this.quantity,
    this.entryPrice,
    this.exitPrice,
    this.currentPrice,
    this.avgPrice,
    this.currentValue,
    this.profitLoss,
    this.profitLossPercentage,
    this.riskAmount,
    this.rewardAmount,
    this.riskRewardRatio,
    this.holdingDays,
    this.entryTimestamp,
    this.exitTimestamp,
    this.broker,
    this.executionCount = 0,
  });

  /// Factory to create view model from domain entity
  factory TradeHoldingViewModel.fromEntity(TradeDetails entity) {
    final metrics = entity.metrics;
    final exitInfo = entity.exitInfo;

    // Extract broker from first execution (if available)
    String? broker;
    if (entity.tradeExecutions != null && entity.tradeExecutions!.isNotEmpty) {
      broker = entity.tradeExecutions!.first.basicInfo?.brokerType?.name;
    }

    return TradeHoldingViewModel(
      tradeId: entity.tradeId,
      portfolioId: entity.portfolioId,
      symbol: entity.instrumentInfo.symbol ?? 'UNKNOWN',
      companyName: entity.instrumentInfo.description ?? 'Unknown Company',
      sector: entity.instrumentInfo.segment?.name,
      industry: entity.instrumentInfo.series?.name,
      exchange: entity.instrumentInfo.exchange?.name,
      status: entity.status.name,
      tradePositionType: entity.tradePositionType.name,
      quantity: entity.entryInfo.quantity ?? exitInfo?.quantity,
      entryPrice: entity.entryInfo.price,
      exitPrice: exitInfo?.price,
      currentPrice: exitInfo?.price ?? entity.entryInfo.price,
      avgPrice: entity.entryInfo.price,
      currentValue:
          (exitInfo?.quantity ?? entity.entryInfo.quantity ?? 0) * (exitInfo?.price ?? entity.entryInfo.price ?? 0),
      profitLoss: metrics?.profitLoss,
      profitLossPercentage: metrics?.profitLossPercentage,
      riskAmount: metrics?.riskAmount,
      rewardAmount: metrics?.rewardAmount,
      riskRewardRatio: metrics?.riskRewardRatio,
      holdingDays: metrics?.holdingTimeDays,
      entryTimestamp: entity.entryInfo.timestamp,
      exitTimestamp: exitInfo?.timestamp,
      broker: broker,
      executionCount: entity.tradeExecutions?.length ?? 0,
    );
  }

  final String tradeId;
  final String portfolioId;
  final String symbol;
  final String companyName;
  final String? sector;
  final String? industry;
  final String? exchange;
  final String? status;
  final String? tradePositionType;
  final int? quantity;
  final double? entryPrice;
  final double? exitPrice;
  final double? currentPrice;
  final double? avgPrice;
  final double? currentValue;
  final double? profitLoss;
  final double? profitLossPercentage;
  final double? riskAmount;
  final double? rewardAmount;
  final double? riskRewardRatio;
  final int? holdingDays;
  final DateTime? entryTimestamp;
  final DateTime? exitTimestamp;
  final String? broker;
  final int executionCount;

  /// Computed properties for UI display
  String get displaySymbol => symbol;
  String get displayCompanyName => companyName;
  String get displaySector => sector ?? 'Unknown';
  String get displayIndustry => industry ?? 'Unknown';
  String get displayExchange => exchange ?? 'Unknown';
  String get displayStatus => status ?? 'Unknown';

  String get displayQuantity => quantity != null ? quantity!.toStringAsFixed(0) : '0';
  String get displayEntryPrice => entryPrice != null ? '\$${entryPrice!.toStringAsFixed(2)}' : 'N/A';
  String get displayExitPrice => exitPrice != null ? '\$${exitPrice!.toStringAsFixed(2)}' : 'N/A';
  String get displayCurrentPrice => currentPrice != null ? '\$${currentPrice!.toStringAsFixed(2)}' : 'N/A';
  String get displayAvgPrice => avgPrice != null ? '\$${avgPrice!.toStringAsFixed(2)}' : 'N/A';
  String get displayCurrentValue => currentValue != null ? '\$${currentValue!.toStringAsFixed(2)}' : 'N/A';

  // Computed values
  double get totalGainLoss => profitLoss ?? 0.0;
  double get totalGainLossPercentage => profitLossPercentage ?? 0.0;
  double get todayChange => 0.0; // Not available in new structure
  double get todayChangePercentage => 0.0; // Not available in new structure

  String get displayProfitLoss => profitLoss != null ? '\$${profitLoss!.toStringAsFixed(2)}' : r'$0.00';
  String get displayProfitLossPercentage =>
      profitLossPercentage != null ? '${profitLossPercentage!.toStringAsFixed(2)}%' : '0.00%';

  String get displayRiskAmount => riskAmount != null ? '\$${riskAmount!.toStringAsFixed(2)}' : 'N/A';
  String get displayRewardAmount => rewardAmount != null ? '\$${rewardAmount!.toStringAsFixed(2)}' : 'N/A';
  String get displayRiskRewardRatio => riskRewardRatio != null ? '${riskRewardRatio!.toStringAsFixed(2)}:1' : 'N/A';

  String get displayHoldingPeriod => holdingDays != null ? '$holdingDays days' : 'N/A';

  bool get isProfit => (profitLoss ?? 0) >= 0;
  bool get isLoss => (profitLoss ?? 0) < 0;

  /// Convert list of entities to view models
  static List<TradeHoldingViewModel> fromEntityList(List<TradeDetails> entities) =>
      entities.map(TradeHoldingViewModel.fromEntity).toList();
}

/// View model for holdings collection
class TradeHoldingsViewModel {
  const TradeHoldingsViewModel({
    required this.userId,
    required this.portfolioId,
    required this.holdings,
    required this.totalElements,
    this.totalPages = 0,
    this.currentPage = 0,
    this.hasMore = false,
  });

  /// Factory from domain entity
  factory TradeHoldingsViewModel.fromEntity(TradeHoldings entity) => TradeHoldingsViewModel(
    userId: entity.userId,
    portfolioId: entity.portfolioId,
    holdings: TradeHoldingViewModel.fromEntityList(entity.content),
    totalElements: entity.totalElements,
    totalPages: entity.totalPages,
    currentPage: entity.number,
    hasMore: !entity.last,
  );

  /// Empty state
  factory TradeHoldingsViewModel.empty(String userId, String portfolioId) =>
      TradeHoldingsViewModel(userId: userId, portfolioId: portfolioId, holdings: [], totalElements: 0);

  final String userId;
  final String portfolioId;
  final List<TradeHoldingViewModel> holdings;
  final int totalElements;
  final int totalPages;
  final int currentPage;
  final bool hasMore;

  /// Computed properties
  int get displayCount => holdings.length;
  String get displayTotal => '$totalElements total trades';
}
