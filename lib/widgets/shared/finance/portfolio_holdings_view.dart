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
                // Entry count selector
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0, right: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text('Show entries: ', 
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      DropdownButton<int>(
                        value: _selectedEntryCount,
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
                            child: Text('$value'),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
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
                
                // Action buttons - use fixed padding for consistency
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Export feature coming soon')),
                          );
                        },
                        icon: const Icon(Icons.download_outlined),
                        label: const Text('Export'),
                      ),
                      const SizedBox(width: 8.0),
                      ElevatedButton.icon(
                        onPressed: widget.onRefresh,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Refresh'),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
