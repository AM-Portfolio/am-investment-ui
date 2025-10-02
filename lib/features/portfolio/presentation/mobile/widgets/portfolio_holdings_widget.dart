import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/utils/logger.dart';
import '../../../../../shared/widgets/portfolio_display_controller.dart';
import '../../../../../shared/widgets/cards/investment_card.dart';
import '../../../providers/portfolio_providers.dart';

/// Portfolio holdings widget with comprehensive display controller at bottom
class PortfolioHoldingsWidget extends ConsumerStatefulWidget {
  final String userId;

  const PortfolioHoldingsWidget({Key? key, required this.userId})
    : super(key: key);

  @override
  ConsumerState<PortfolioHoldingsWidget> createState() =>
      _PortfolioHoldingsWidgetState();
}

class _PortfolioHoldingsWidgetState
    extends ConsumerState<PortfolioHoldingsWidget> {
  ChangeType _changeType = ChangeType.daily;
  DisplayFormat _displayFormat = DisplayFormat.value;
  SortBy _sortBy = SortBy.name;
  bool _sortAscending = true;

  @override
  Widget build(BuildContext context) {
    AppLogger.debug(
      'Building PortfolioHoldingsWidget for userId: ${widget.userId}',
      tag: 'PortfolioHoldingsWidget',
    );

    final portfolioHoldingsAsync = ref.watch(
      portfolioHoldingsProvider(widget.userId),
    );

    return Column(
      children: [
        Expanded(
          child: portfolioHoldingsAsync.when(
            data: (portfolioHoldings) {
              AppLogger.debug(
                'Portfolio holdings loaded: ${portfolioHoldings.holdings.length} holdings',
                tag: 'PortfolioHoldingsWidget',
              );

              // Sort holdings based on selected criteria
              final sortedHoldings = _sortHoldings(portfolioHoldings.holdings);

              return RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(portfolioHoldingsProvider(widget.userId));
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: sortedHoldings.length,
                  itemBuilder: (context, index) {
                    final holding = sortedHoldings[index];

                    // Calculate values based on selected change type
                    final changeValue = _changeType == ChangeType.daily
                        ? holding.todayChange
                        : holding.totalGainLoss;
                    final changePercent = _changeType == ChangeType.daily
                        ? holding.todayChangePercentage
                        : holding.totalGainLossPercentage;
                    final isPositive = changeValue >= 0;

                    return InvestmentCard.legacy(
                      symbol: holding.symbol,
                      name: holding.companyName,
                      currentValue: holding.currentValue,
                      investedAmount: holding.investedAmount,
                      avgPrice: holding.avgPrice,
                      quantity: holding.quantity.toInt(),
                      currentPrice: holding.currentPrice,
                      changeValue: changeValue,
                      changePercent: changePercent,
                      isPositive: isPositive,
                      onTap: () {
                        // TODO: Navigate to holding details
                      },
                      // Custom display based on format preference
                      customBottomWidget: _buildCustomBottomRow(
                        holding,
                        changeValue,
                        changePercent,
                        isPositive,
                      ),
                    );
                  },
                ),
              );
            },
            loading: () {
              AppLogger.debug(
                'Showing loading indicator for portfolio holdings',
                tag: 'PortfolioHoldingsWidget',
              );
              return const Center(child: CircularProgressIndicator());
            },
            error: (error, stackTrace) {
              AppLogger.warning(
                'Showing error state in portfolio holdings: $error',
                tag: 'PortfolioHoldingsWidget',
              );
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading portfolio: $error',
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.invalidate(
                        portfolioHoldingsProvider(widget.userId),
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        // Portfolio Display Controller at bottom
        PortfolioDisplayController(
          selectedChangeType: _changeType,
          selectedDisplayFormat: _displayFormat,
          selectedSortBy: _sortBy,
          sortAscending: _sortAscending,
          onChangeTypeChanged: (type) {
            setState(() {
              _changeType = type;
            });
            AppLogger.debug(
              'Change type updated to: $type',
              tag: 'PortfolioHoldingsWidget',
            );
          },
          onDisplayFormatChanged: (format) {
            setState(() {
              _displayFormat = format;
            });
            AppLogger.debug(
              'Display format updated to: $format',
              tag: 'PortfolioHoldingsWidget',
            );
          },
          onSortByChanged: (sortBy) {
            setState(() {
              _sortBy = sortBy;
            });
            AppLogger.debug(
              'Sort by updated to: $sortBy',
              tag: 'PortfolioHoldingsWidget',
            );
          },
          onSortOrderChanged: (ascending) {
            setState(() {
              _sortAscending = ascending;
            });
            AppLogger.debug(
              'Sort order updated to: ${ascending ? "ascending" : "descending"}',
              tag: 'PortfolioHoldingsWidget',
            );
          },
        ),
      ],
    );
  }

  /// Build custom bottom row with display format preference
  Widget _buildCustomBottomRow(
    dynamic holding,
    double changeValue,
    double changePercent,
    bool isPositive,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Left: Investment details
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Inv. ',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
                Text(
                  '₹${holding.investedAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Icon(
                  isPositive ? Icons.trending_up : Icons.trending_down,
                  color: isPositive ? Colors.green : Colors.red,
                  size: 12,
                ),
                const SizedBox(width: 2),
                Text(
                  'Avg ${holding.avgPrice.toStringAsFixed(2)}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.inventory_2_outlined,
                  color: Colors.grey.shade600,
                  size: 12,
                ),
                const SizedBox(width: 2),
                Text(
                  '${holding.quantity.toInt()}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        // Right: P&L and Current Price with format preference
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _displayFormat == DisplayFormat.value
                  ? '${isPositive ? '+' : ''}₹${changeValue.toStringAsFixed(2)}'
                  : '${isPositive ? '+' : ''}${changePercent.toStringAsFixed(2)}%',
              style: TextStyle(
                color: isPositive ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 2),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Live ',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
                Text(
                  '${holding.currentPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  /// Sort holdings based on selected criteria
  List<dynamic> _sortHoldings(List<dynamic> holdings) {
    final sortedList = List.from(holdings);

    sortedList.sort((a, b) {
      dynamic valueA, valueB;

      switch (_sortBy) {
        case SortBy.name:
          valueA = a.symbol.toLowerCase();
          valueB = b.symbol.toLowerCase();
          break;
        case SortBy.profitLoss:
          valueA = _changeType == ChangeType.daily
              ? a.todayChange
              : a.totalGainLoss;
          valueB = _changeType == ChangeType.daily
              ? b.todayChange
              : b.totalGainLoss;
          break;
        case SortBy.profitLossPercentage:
          valueA = _changeType == ChangeType.daily
              ? a.todayChangePercentage
              : a.totalGainLossPercentage;
          valueB = _changeType == ChangeType.daily
              ? b.todayChangePercentage
              : b.totalGainLossPercentage;
          break;
        case SortBy.currentValue:
          valueA = a.currentValue;
          valueB = b.currentValue;
          break;
      }

      int comparison;
      if (valueA is String && valueB is String) {
        comparison = valueA.compareTo(valueB);
      } else {
        comparison = (valueA as num).compareTo(valueB as num);
      }

      return _sortAscending ? comparison : -comparison;
    });

    return sortedList;
  }
}
