import 'package:freezed_annotation/freezed_annotation.dart';

import '../domain/entities/trade_entities.dart';
import '../domain/usecases/trade_usecases.dart';

part 'trade_service.freezed.dart';

/// Trade Service orchestrates complex workflows involving multiple use cases
/// Following exact pattern from portfolio_service.dart for consistency
class TradeService {
  TradeService({
    required GetPortfoliosByOwnerUseCase getPortfoliosByOwner,
    required GetPortfolioSummaryUseCase getPortfolioSummary,
    required GetTradeHoldingsUseCase getTradeHoldings,
  }) : _getPortfoliosByOwner = getPortfoliosByOwner,
       _getPortfolioSummary = getPortfolioSummary,
       _getTradeHoldings = getTradeHoldings;

  final GetPortfoliosByOwnerUseCase _getPortfoliosByOwner;
  final GetPortfolioSummaryUseCase _getPortfolioSummary;
  final GetTradeHoldingsUseCase _getTradeHoldings;

  /// Get complete portfolio analysis (following portfolio service pattern)
  Future<TradeAnalysisResult> getCompletePortfolioAnalysis(
    String portfolioId,
  ) async {
    try {
      // Execute operations in parallel (same pattern as portfolio service)
      final results = await Future.wait([
        _getPortfolioSummary(portfolioId),
        _getTradeHoldings(
          TradeHoldingsParams(portfolioId: portfolioId, limit: 100),
        ),
      ]);

      final summary = results[0] as TradePortfolioSummary;
      final holdings = results[1] as List<TradeHolding>;

      // Generate analysis insights (same pattern as portfolio)
      final insights = _generateAnalysisInsights(summary, holdings);

      return TradeAnalysisResult(
        summary: summary,
        holdings: holdings,
        insights: insights,
        analysisDate: DateTime.now(),
      );
    } catch (e) {
      throw TradeServiceException('Failed to complete portfolio analysis: $e');
    }
  }

  /// Portfolio discovery workflow (same pattern as portfolio service)
  Future<TradeDiscoveryResult> discoverTradePortfolios(String ownerId) async {
    try {
      // Step 1: Get all portfolios (same as portfolio service)
      final portfolios = await _getPortfoliosByOwner(ownerId);

      // Step 2: Analyze active portfolios (same pattern)
      final analysisResults = <String, TradeAnalysisResult>{};

      final activePortfolios =
          portfolios.where((p) => p.hasActiveTrades).toList()..sort(
            (a, b) =>
                b.totalReturnPercentage.compareTo(a.totalReturnPercentage),
          );

      for (final portfolio in activePortfolios.take(3)) {
        try {
          final analysis = await getCompletePortfolioAnalysis(
            portfolio.portfolioId,
          );
          analysisResults[portfolio.portfolioId] = analysis;
        } catch (e) {
          // Continue with other portfolios if one fails (same pattern)
          continue;
        }
      }

      return TradeDiscoveryResult(
        portfolios: portfolios,
        analyses: analysisResults,
        discoveryDate: DateTime.now(),
      );
    } catch (e) {
      throw TradeServiceException('Failed to discover trade portfolios: $e');
    }
  }

  // Private helper methods (following portfolio service pattern)
  List<TradeInsight> _generateAnalysisInsights(
    TradePortfolioSummary summary,
    List<TradeHolding> holdings,
  ) {
    final insights = <TradeInsight>[];

    // Performance analysis (same pattern as portfolio service)
    final profitableHoldings = holdings.where((h) => h.isProfitable).length;
    final winRate = holdings.isNotEmpty
        ? profitableHoldings / holdings.length
        : 0.0;

    if (winRate > 0.7) {
      insights.add(
        TradeInsight(
          type: InsightType.positive,
          title: 'Strong Performance',
          description:
              'High win rate of ${(winRate * 100).toStringAsFixed(1)}%',
        ),
      );
    } else if (winRate < 0.4) {
      insights.add(
        const TradeInsight(
          type: InsightType.warning,
          title: 'Performance Review Needed',
          description: 'Consider reviewing trade selection strategy',
        ),
      );
    }

    // Risk analysis (same pattern as portfolio service)
    final symbolConcentration = _calculateSymbolConcentration(holdings);
    if (symbolConcentration > 0.3) {
      insights.add(
        const TradeInsight(
          type: InsightType.warning,
          title: 'High Concentration Risk',
          description: 'Portfolio concentrated in few positions',
        ),
      );
    }

    return insights;
  }

  double _calculateSymbolConcentration(List<TradeHolding> holdings) {
    if (holdings.isEmpty) return 0.0;

    final symbolValues = <String, double>{};
    var totalValue = 0.0;

    for (final holding in holdings) {
      symbolValues[holding.symbol] =
          (symbolValues[holding.symbol] ?? 0.0) + holding.currentValue;
      totalValue += holding.currentValue;
    }

    if (totalValue == 0) return 0.0;

    // Return highest symbol concentration (same calculation as portfolio)
    return symbolValues.values.isNotEmpty
        ? symbolValues.values.reduce((a, b) => a > b ? a : b) / totalValue
        : 0.0;
  }
}

// Result classes (following portfolio service pattern)
@freezed
class TradeAnalysisResult with _$TradeAnalysisResult {
  const factory TradeAnalysisResult({
    required TradePortfolioSummary summary,
    required List<TradeHolding> holdings,
    required List<TradeInsight> insights,
    required DateTime analysisDate,
  }) = _TradeAnalysisResult;
}

@freezed
class TradeDiscoveryResult with _$TradeDiscoveryResult {
  const factory TradeDiscoveryResult({
    required List<TradePortfolioSummary> portfolios,
    required Map<String, TradeAnalysisResult> analyses,
    required DateTime discoveryDate,
  }) = _TradeDiscoveryResult;
}

@freezed
class TradeInsight with _$TradeInsight {
  const factory TradeInsight({
    required InsightType type,
    required String title,
    required String description,
  }) = _TradeInsight;
}

// Enums (same as portfolio service)
enum InsightType { positive, warning, info, negative }

// Exception class (same pattern as portfolio service)
class TradeServiceException implements Exception {
  TradeServiceException(this.message);
  final String message;
}
