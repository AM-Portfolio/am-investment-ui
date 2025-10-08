import 'package:flutter/material.dart';

import '../../../../features/portfolio/internal/domain/entities/portfolio_holding.dart';
import '../core/holdings_selector_core.dart';

/// Abstract base class for holdings layout builders
/// Follows the strategy pattern similar to HeatmapLayoutBuilder
abstract class HoldingsLayoutBuilder {
  /// Build the layout with the provided holdings data
  Widget build(
    BuildContext context,
    List<PortfolioHolding> holdings, {
    required HoldingsSortBy sortBy,
    required bool sortAscending,
    required HoldingsDisplayFormat displayFormat,
    required HoldingsChangeType changeType,
    ValueChanged<PortfolioHolding>? onHoldingTap,
    double? width,
    double? height,
  });

  /// Sort holdings based on criteria
  List<PortfolioHolding> sortHoldings(
    List<PortfolioHolding> holdings,
    HoldingsSortBy sortBy,
    bool ascending,
  ) {
    final sorted = List<PortfolioHolding>.from(holdings);

    sorted.sort((a, b) {
      dynamic valueA, valueB;

      switch (sortBy) {
        case HoldingsSortBy.symbol:
          valueA = a.symbol.toLowerCase();
          valueB = b.symbol.toLowerCase();
          break;
        case HoldingsSortBy.currentValue:
          valueA = a.currentValue;
          valueB = b.currentValue;
          break;
        case HoldingsSortBy.gainLoss:
          valueA = a.totalGainLoss;
          valueB = b.totalGainLoss;
          break;
        case HoldingsSortBy.gainLossPercent:
          valueA = a.totalGainLossPercentage;
          valueB = b.totalGainLossPercentage;
          break;
        case HoldingsSortBy.todayChange:
          valueA = a.todayChange;
          valueB = b.todayChange;
          break;
        case HoldingsSortBy.quantity:
          valueA = a.quantity;
          valueB = b.quantity;
          break;
        case HoldingsSortBy.portfolioWeight:
          valueA = a.portfolioWeight;
          valueB = b.portfolioWeight;
          break;
      }

      int comparison;
      if (valueA is String && valueB is String) {
        comparison = valueA.compareTo(valueB);
      } else {
        comparison = (valueA as num).compareTo(valueB as num);
      }

      return ascending ? comparison : -comparison;
    });

    return sorted;
  }

  /// Get change value based on change type
  double getChangeValue(PortfolioHolding holding, HoldingsChangeType changeType) {
    return changeType == HoldingsChangeType.daily
        ? holding.todayChange
        : holding.totalGainLoss;
  }

  /// Get change percentage based on change type
  double getChangePercentage(
    PortfolioHolding holding,
    HoldingsChangeType changeType,
  ) {
    return changeType == HoldingsChangeType.daily
        ? holding.todayChangePercentage
        : holding.totalGainLossPercentage;
  }

  /// Format currency value
  String formatCurrency(double value) {
    return '₹${value.toStringAsFixed(2)}';
  }

  /// Format percentage value
  String formatPercentage(double value) {
    final sign = value >= 0 ? '+' : '';
    return '$sign${value.toStringAsFixed(2)}%';
  }
}
