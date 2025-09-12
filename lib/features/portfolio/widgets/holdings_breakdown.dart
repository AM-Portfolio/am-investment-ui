import 'package:flutter/material.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_segmented_control.dart';
import '../../../core/models/portfolio/portfolio_models.dart';
import '../screens/category_details_screen.dart';
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
              
              // Create a more elegant category card
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: () {
                    // Navigate to category details screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CategoryDetailsScreen(
                          categoryName: entry.key.isEmpty ? 'Other' : entry.key,
                          assets: entry.value,
                          categoryType: _breakdownType == BreakdownType.marketCap
                              ? CategoryType.marketCap
                              : CategoryType.sector,
                        ),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  // Category icon
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: _getCategoryColor(entry.key, theme),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      _getCategoryIcon(entry.key, _breakdownType),
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // Category name
                                  Expanded(
                                    child: Text(
                                      entry.key.isEmpty ? 'Other' : entry.key,
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Percentage
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${percentage.toStringAsFixed(1)}%',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Assets and investment info
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${entry.value.length} assets',
                              style: theme.textTheme.bodyMedium,
                            ),
                            Text(
                              currencyFormat.format(totalInvestment),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Progress bar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: percentage / 100,
                            backgroundColor: theme.colorScheme.surfaceVariant,
                            minHeight: 6,
                          ),
                        ),
                        // View details hint
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: null, // Already handled by the card's InkWell
                            icon: const Icon(Icons.arrow_forward, size: 16),
                            label: const Text('View details'),
                            style: TextButton.styleFrom(padding: EdgeInsets.zero),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
        ],
      ),
    );
  }
  
  /// Get color for category
  Color _getCategoryColor(String category, ThemeData theme) {
    // For market cap categories
    if (category.contains('LARGE') || category.contains('Large')) {
      return Colors.blue.shade700;
    } else if (category.contains('MID') || category.contains('Mid')) {
      return Colors.green.shade700;
    } else if (category.contains('SMALL') || category.contains('Small')) {
      return Colors.orange.shade700;
    } else if (category.contains('MICRO') || category.contains('Micro')) {
      return Colors.purple.shade700;
    }
    
    // For sector categories - use a hash of the name to get a consistent color
    final hash = category.hashCode.abs() % 10;
    switch (hash) {
      case 0: return Colors.blue.shade700;
      case 1: return Colors.green.shade700;
      case 2: return Colors.orange.shade700;
      case 3: return Colors.purple.shade700;
      case 4: return Colors.red.shade700;
      case 5: return Colors.teal.shade700;
      case 6: return Colors.indigo.shade700;
      case 7: return Colors.amber.shade700;
      case 8: return Colors.pink.shade700;
      case 9: return Colors.cyan.shade700;
      default: return theme.colorScheme.primary;
    }
  }
  
  /// Get icon for category
  IconData _getCategoryIcon(String category, BreakdownType type) {
    // For market cap breakdown
    if (type == BreakdownType.marketCap) {
      if (category.contains('LARGE') || category.contains('Large')) {
        return Icons.trending_up;
      } else if (category.contains('MID') || category.contains('Mid')) {
        return Icons.trending_flat;
      } else if (category.contains('SMALL') || category.contains('Small')) {
        return Icons.trending_down;
      } else if (category.contains('MICRO') || category.contains('Micro')) {
        return Icons.grain;
      }
      return Icons.category;
    }
    
    // For sector breakdown - use sector-specific icons
    if (category.contains('Tech') || category.contains('IT')) {
      return Icons.computer;
    } else if (category.contains('Finance') || category.contains('Bank')) {
      return Icons.account_balance;
    } else if (category.contains('Health') || category.contains('Pharma')) {
      return Icons.medical_services;
    } else if (category.contains('Energy') || category.contains('Oil')) {
      return Icons.bolt;
    } else if (category.contains('Consumer') || category.contains('Retail')) {
      return Icons.shopping_cart;
    } else if (category.contains('Industrial') || category.contains('Manufacturing')) {
      return Icons.factory;
    } else if (category.contains('Real Estate') || category.contains('Property')) {
      return Icons.home;
    } else if (category.contains('Telecom') || category.contains('Communication')) {
      return Icons.cell_tower;
    } else if (category.contains('Materials') || category.contains('Chemical')) {
      return Icons.science;
    }
    
    return Icons.business;
  }
}
