import 'package:freezed_annotation/freezed_annotation.dart';

part 'trade_portfolio.freezed.dart';
part 'trade_portfolio.g.dart';

/// Domain entity for trade portfolio discovery
@freezed
class TradePortfolio with _$TradePortfolio {
  const factory TradePortfolio({
    required String id,
    required String name,
    required String ownerId,
    required double totalValue,
    required double totalGainLoss,
    required double totalGainLossPercentage,
    @Default(0) int holdingsCount,
    String? description,
    DateTime? lastUpdated,
  }) = _TradePortfolio;

  factory TradePortfolio.fromJson(Map<String, dynamic> json) =>
      _$TradePortfolioFromJson(json);
}

/// Domain entity for trade portfolio list
@freezed
class TradePortfolioList with _$TradePortfolioList {
  const factory TradePortfolioList({
    required String userId,
    required List<TradePortfolio> portfolios,
    @Default(0) int totalCount,
  }) = _TradePortfolioList;

  factory TradePortfolioList.fromJson(Map<String, dynamic> json) =>
      _$TradePortfolioListFromJson(json);

  /// Create empty portfolio list
  factory TradePortfolioList.empty(String userId) => TradePortfolioList(
        userId: userId,
        portfolios: [],
        totalCount: 0,
      );
}
