import 'package:freezed_annotation/freezed_annotation.dart';

part 'portfolio_summary.freezed.dart';
part 'portfolio_summary.g.dart';

/// Domain entity representing portfolio summary
@freezed
class PortfolioSummary with _$PortfolioSummary {
  const PortfolioSummary._();
  
  const factory PortfolioSummary({
    required String userId,
    required double totalValue,
    required double totalInvested,
    required double totalGainLoss,
    required double totalGainLossPercentage,
    required double todayChange,
    required double todayChangePercentage,
    required int totalHoldings,
    required DateTime lastUpdated,
    @Default([]) List<SectorAllocation> sectorAllocation,
    @Default([]) List<TopPerformer> topPerformers,
    @Default([]) List<TopPerformer> worstPerformers,
  }) = _PortfolioSummary;

  factory PortfolioSummary.fromJson(Map<String, dynamic> json) =>
      _$PortfolioSummaryFromJson(json);

  factory PortfolioSummary.empty(String userId) {
    return PortfolioSummary(
      userId: userId,
      totalValue: 0.0,
      totalInvested: 0.0,
      totalGainLoss: 0.0,
      totalGainLossPercentage: 0.0,
      todayChange: 0.0,
      todayChangePercentage: 0.0,
      totalHoldings: 0,
      lastUpdated: DateTime.now(),
    );
  }

  /// Check if portfolio is profitable
  bool get isProfitable => totalGainLoss >= 0;
  
  /// Check if today's performance is positive
  bool get isTodayPositive => todayChange >= 0;
  
  /// Get formatted total value
  String get formattedTotalValue => _formatCurrency(totalValue);
  
  /// Get formatted gain/loss
  String get formattedGainLoss => _formatCurrency(totalGainLoss);
  
  /// Get formatted today's change
  String get formattedTodayChange => _formatCurrency(todayChange);

  String _formatCurrency(double amount) {
    if (amount.abs() >= 10000000) {
      return '₹${(amount / 10000000).toStringAsFixed(2)}Cr';
    } else if (amount.abs() >= 100000) {
      return '₹${(amount / 100000).toStringAsFixed(2)}L';
    } else if (amount.abs() >= 1000) {
      return '₹${(amount / 1000).toStringAsFixed(1)}K';
    } else {
      return '₹${amount.toStringAsFixed(2)}';
    }
  }
}

/// Domain entity representing sector allocation
@freezed
class SectorAllocation with _$SectorAllocation {
  const factory SectorAllocation({
    required String sector,
    required double value,
    required double percentage,
    required int holdings,
  }) = _SectorAllocation;

  factory SectorAllocation.fromJson(Map<String, dynamic> json) =>
      _$SectorAllocationFromJson(json);
}

/// Domain entity representing top/worst performers
@freezed
class TopPerformer with _$TopPerformer {
  const factory TopPerformer({
    required String symbol,
    required String companyName,
    required double gainLoss,
    required double gainLossPercentage,
    required double currentValue,
  }) = _TopPerformer;

  factory TopPerformer.fromJson(Map<String, dynamic> json) =>
      _$TopPerformerFromJson(json);
}