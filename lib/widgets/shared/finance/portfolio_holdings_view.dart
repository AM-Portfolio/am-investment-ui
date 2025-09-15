import 'package:flutter/material.dart';
import '../../../core/models/portfolio/portfolio_holdings.dart';
import 'portfolio_holdings_card.dart';
import 'dart:math';
import 'dart:developer' as dev;

/// A widget to display portfolio holdings
class PortfolioHoldingsView extends StatefulWidget {
  /// Future for portfolio holdings data
  final Future<PortfolioHoldings> holdingsFuture;
  
  /// Callback to refresh holdings data
  final VoidCallback onRefresh;
  
  /// Constructor
  const PortfolioHoldingsView({
    Key? key,
    required this.holdingsFuture,
    required this.onRefresh,
  }) : super(key: key);
  
  @override
  State<PortfolioHoldingsView> createState() => _PortfolioHoldingsViewState();
}

class _PortfolioHoldingsViewState extends State<PortfolioHoldingsView> {
  // Available entry count options
  final List<int> _entryCounts = [10, 20, 25, 50, 100];
  
  // Default entry count
  int _selectedEntryCount = 20;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PortfolioHoldings>(
      future: widget.holdingsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading holdings: ${snapshot.error}',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.red,
              ),
            ),
          );
        }
        
        final holdings = snapshot.data!;
        
        // Use LayoutBuilder to get available constraints
        return LayoutBuilder(
          builder: (context, constraints) {
            // Log available space for debugging
            dev.log('Available width: ${constraints.maxWidth}, height: ${constraints.maxHeight}');
            
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Entry count selector - make more compact
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('Show entries: ', 
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    DropdownButton<int>(
                      value: _selectedEntryCount,
                      isDense: true, // Make dropdown more compact
                      underline: Container(
                        height: 1,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      onChanged: (int? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedEntryCount = newValue;
                          });
                        }
                      },
                      items: _entryCounts.map<DropdownMenuItem<int>>((int value) {
                        return DropdownMenuItem<int>(
                          value: value,
                          child: Text('$value', style: Theme.of(context).textTheme.bodySmall),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                
                // Holdings card with sortable table - use Expanded to fill available space
                Expanded(
                  child: PortfolioHoldingsCard(
                    holdings: holdings,
                    showDetails: true,
                    maxHoldings: _selectedEntryCount, // Use selected entry count
                    onHoldingTap: (holding) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Selected ${holding.symbol}')),
                      );
                    },
                  ),
                ),
                
                // Removed bottom action buttons to maximize space for the table
              ],
            );
          },
        );
      },
    );
  }
}
