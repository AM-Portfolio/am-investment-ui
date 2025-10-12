import '../../internal/domain/entities/trade_portfolio.dart';

/// View model for trade portfolio presentation
class TradePortfolioViewModel {
  const TradePortfolioViewModel({
    required this.id,
    required this.name,
    this.ownerId,
    this.totalValue = 0.0,
    this.totalGainLoss = 0.0,
    this.totalGainLossPercentage = 0.0,
    this.holdingsCount = 0,
    this.description,
    this.lastUpdated,
  });

  final String id;
  final String name;
  final String? ownerId;
  final double totalValue;
  final double totalGainLoss;
  final double totalGainLossPercentage;
  final int holdingsCount;
  final String? description;
  final DateTime? lastUpdated;

  /// Computed properties for UI
  String get displayName => name;
  String get displayValue => '\$${totalValue.toStringAsFixed(2)}';
  String get displayGainLoss => '\$${totalGainLoss.toStringAsFixed(2)}';
  String get displayGainLossPercentage => '${totalGainLossPercentage.toStringAsFixed(2)}%';
  String get displayHoldingsCount => '$holdingsCount holdings';
  bool get isProfit => totalGainLoss >= 0;

  /// Factory from domain entity
  factory TradePortfolioViewModel.fromEntity(TradePortfolio entity) {
    return TradePortfolioViewModel(
      id: entity.id,
      name: entity.name,
      ownerId: entity.ownerId,
      totalValue: entity.totalValue ?? 0.0,
      totalGainLoss: entity.totalGainLoss ?? 0.0,
      totalGainLossPercentage: entity.totalGainLossPercentage ?? 0.0,
      holdingsCount: entity.holdingsCount,
      description: entity.description,
      lastUpdated: entity.lastUpdated,
    );
  }

  static List<TradePortfolioViewModel> fromEntityList(
      List<TradePortfolio> entities) {
    return entities.map((e) => TradePortfolioViewModel.fromEntity(e)).toList();
  }
}

/// View model for portfolio list
class TradePortfolioListViewModel {
  const TradePortfolioListViewModel({
    required this.userId,
    required this.portfolios,
    this.totalCount = 0,
  });

  final String userId;
  final List<TradePortfolioViewModel> portfolios;
  final int totalCount;

  /// Computed properties
  int get displayCount => portfolios.length;
  String get displayTotal => '$totalCount portfolios';

  /// Factory from domain entity
  factory TradePortfolioListViewModel.fromEntity(TradePortfolioList entity) {
    return TradePortfolioListViewModel(
      userId: entity.userId,
      portfolios: TradePortfolioViewModel.fromEntityList(entity.portfolios),
      totalCount: entity.totalCount,
    );
  }

  factory TradePortfolioListViewModel.empty(String userId) {
    return TradePortfolioListViewModel(
      userId: userId,
      portfolios: [],
      totalCount: 0,
    );
  }
}
