import 'package:flutter/material.dart';
import '../../../core/models/portfolio/portfolio_holdings.dart';
import 'portfolio_holdings_card.dart';
import 'portfolio_filter_widget.dart';
import 'portfolio_filter_dialog.dart';
import 'dart:developer' as dev;

/// A widget to display portfolio holdings
class PortfolioHoldingsView extends StatefulWidget {
  /// Future for portfolio holdings data
  final Future<PortfolioHoldings> holdingsFuture;

  /// Callback to refresh holdings data
  final VoidCallback onRefresh;

  /// Constructor
  const PortfolioHoldingsView({
    super.key,
    required this.holdingsFuture,
    required this.onRefresh,
  });

  @override
  State<PortfolioHoldingsView> createState() => _PortfolioHoldingsViewState();
}

class _PortfolioHoldingsViewState extends State<PortfolioHoldingsView> {
  // Available entry count options
  final List<int> _entryCounts = [10, 20, 25, 50, 100];

  // Default entry count
  int _selectedEntryCount = 20;
  
  // Filtered holdings
  List<EquityHolding>? _filteredHoldings;
  
  // Filter visibility state
  bool _isFilterExpanded = false;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PortfolioHoldings>(
      future: widget.holdingsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading holdings: ${snapshot.error}',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.red),
            ),
          );
        }

        final holdings = snapshot.data!;

        // Use LayoutBuilder to get available constraints
        return LayoutBuilder(
          builder: (context, constraints) {
            // Log available space for debugging
            dev.log(
              'Available width: ${constraints.maxWidth}, height: ${constraints.maxHeight}',
            );

            // Use a Column with dynamic layout for the content
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Filter and entry count controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Filter controls
                    Row(
                      children: [
                        // Inline filter toggle button
                        ElevatedButton.icon(
                          icon: Icon(
                            _isFilterExpanded ? Icons.filter_list_off : Icons.filter_list,
                            size: 16,
                          ),
                          label: Text(_isFilterExpanded ? 'Hide Filters' : 'Show Filters'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            textStyle: Theme.of(context).textTheme.bodySmall,
                            backgroundColor: _isFilterExpanded
                                ? Theme.of(context).colorScheme.primary.withOpacity(0.8)
                                : null,
                          ),
                          onPressed: () {
                            setState(() {
                              _isFilterExpanded = !_isFilterExpanded;
                            });
                          },
                        ),
                        
                        // Popup filter dialog button
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.filter_alt),
                          tooltip: 'Open Filter Dialog',
                          onPressed: () => _showFilterDialog(holdings),
                          style: IconButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    
                    // Entry count selector
                    Row(
                      children: [
                        Text(
                          'Show entries: ',
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
                          items: _entryCounts.map<DropdownMenuItem<int>>((int value,) {
                            return DropdownMenuItem<int>(
                              value: value,
                              child: Text(
                                '$value',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ],
                ),
                
                // Always show the filter widget when expanded
                if (_isFilterExpanded)
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0, bottom: 8.0),
                    child: PortfolioFilterWidget(
                      holdings: holdings.equityHoldings,
                      onFiltersApplied: _applyFilters,
                      onFiltersReset: _resetFilters,
                      initiallyExpanded: true,
                    ),
                  ),
                
                // Filter status indicator when filters are applied
                if (_filteredHoldings != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
                    child: Row(
                      children: [
                        Text(
                          'Showing ${_filteredHoldings!.length} of ${holdings.equityHoldings.length} holdings',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: _resetFilters,
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text('Clear Filters'),
                        ),
                      ],
                    ),
                  ),

                // Use SizedBox with responsive height for the holdings card
                // This ensures consistent display regardless of filter state
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6, // 60% of screen height
                  child: PortfolioHoldingsCard(
                    holdings: _filteredHoldings != null
                        ? PortfolioHoldings(equityHoldings: _filteredHoldings!)
                        : holdings,
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
  
  
  /// Apply filters to the holdings
  void _applyFilters(List<EquityHolding> filtered) {
    setState(() {
      _filteredHoldings = filtered;
    });
  }
  
  /// Reset all filters
  void _resetFilters() {
    setState(() {
      _filteredHoldings = null;
    });
  }
  
  /// Show filter dialog
  void _showFilterDialog(PortfolioHoldings holdings) async {
    final result = await PortfolioFilterDialog.show(
      context,
      holdings.equityHoldings,
    );
    
    if (result != null) {
      _applyFilters(result);
    }
  }
}
