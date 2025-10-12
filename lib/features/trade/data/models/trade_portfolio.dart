import 'package:freezed_annotation/freezed_annotation.dart';

part 'trade_portfolio.freezed.dart';
part 'trade_portfolio.g.dart';

@freezed
class TradePortfolio with _$TradePortfolio {
  const factory TradePortfolio({
    required String portfolioId,
    required String name,
    String? description,
    required String ownerId,
    required bool active,
    String? currency,
    double? initialCapital,
    double? currentCapital,
    required String createdDate,
    required String lastUpdatedDate,
    PortfolioMetrics? metrics,
    List<String>? tradeIds,
    List<String>? winningTradeIds,
    List<String>? losingTradeIds,
    Map<String, dynamic>? assetAllocations,
  }) = _TradePortfolio;

  factory TradePortfolio.fromJson(Map<String, dynamic> json) =>
      _$TradePortfolioFromJson(json);
}

@freezed
class PortfolioMetrics with _$PortfolioMetrics {
  const factory PortfolioMetrics({
    required int totalTrades,
    required int winningTrades,
    required int losingTrades,
    required int breakEvenTrades,
    required int openPositions,
    required double winRate,
    required double lossRate,
    double? profitFactor,
    double? expectancy,
    double? totalValue,
    double? totalProfit,
    double? totalLoss,
    double? netProfitLoss,
    double? netProfitLossPercentage,
    double? maxDrawdown,
    double? maxDrawdownPercentage,
    double? sharpeRatio,
    double? sortinoRatio,
    Map<String, dynamic>? monthlyReturns,
    Map<String, dynamic>? weeklyReturns,
  }) = _PortfolioMetrics;

  factory PortfolioMetrics.fromJson(Map<String, dynamic> json) =>
      _$PortfolioMetricsFromJson(json);
}
