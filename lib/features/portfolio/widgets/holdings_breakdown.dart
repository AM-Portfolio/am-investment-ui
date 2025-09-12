import 'package:flutter/material.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_segmented_control.dart';
import '../../../core/models/portfolio/portfolio_models.dart';
import 'package:intl/intl.dart';

/// Breakdown type for portfolio holdings
enum BreakdownType {
  /// Breakdown by market capitalization
  marketCap,
  
  /// Breakdown by sector
  sector
}

/// Widget to display portfolio holdings breakdown
class HoldingsBreakdown extends StatefulWidget {
  /// Portfolio summary data
  final PortfolioSummary summary;
  
  /// Constructor
  const HoldingsBreakdown({
    Key? key,
    required this.summary,
  }) : super(key: key);

  @override
  State<HoldingsBreakdown> createState() => _HoldingsBreakdownState();
}

class _HoldingsBreakdownState extends State<HoldingsBreakdown> {
  /// Current breakdown type
  BreakdownType _breakdownType = BreakdownType.marketCap;
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(
      symbol: '₹',
      locale: 'en_IN',
      decimalDigits: 2,
    );
    
    // Get the appropriate holdings map based on the selected breakdown type
    final Map<String, List<AssetHolding>> holdingsMap = _breakdownType == BreakdownType.marketCap
        ? widget.summary.marketCapHoldings
        : widget.summary.sectorialHoldings;
    
    return AppCard(
      title: 'Holdings Breakdown',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Segmented control for switching between breakdown types
          AppSegmentedControl<BreakdownType>(
            selectedValue: _breakdownType,
            children: const {
              BreakdownType.marketCap: 'Market Cap',
              BreakdownType.sector: 'Sector',
            },
            onValueChanged: (value) {
              setState(() {
                _breakdownType = value;
              });
            },
          ),
          
          const SizedBox(height: 16),
          
          // Display holdings breakdown
          if (holdingsMap.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Text('No holdings data available'),
              ),
            )
          else
            ...holdingsMap.entries.map((entry) {
              // Calculate total investment for this category
              final totalInvestment = entry.value.fold<double>(
                0,
                (sum, holding) => sum + holding.investmentCost,
              );
              
              // Calculate percentage of total portfolio
              final percentage = (totalInvestment / widget.summary.investmentValue) * 100;
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            entry.key.isEmpty ? 'Other' : entry.key,
                            style: theme.textTheme.titleSmall,
                          ),
                        ),
                        Text(
                          '${percentage.toStringAsFixed(1)}%',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${entry.value.length} assets • ${currencyFormat.format(totalInvestment)}',
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: percentage / 100,
                      backgroundColor: theme.colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ],
                ),
              );
            }).toList(),
        ],
      ),
    );
  }
}
