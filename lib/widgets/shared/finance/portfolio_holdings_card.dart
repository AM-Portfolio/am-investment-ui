import 'dart:math';
import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import '../../../core/models/portfolio/portfolio_holdings.dart';
import '../table/sortable_table.dart';

/// A widget to display portfolio holdings in a card format
/// Works on both Android and web platforms
class PortfolioHoldingsCard extends StatefulWidget {
  /// Portfolio holdings data
  final PortfolioHoldings holdings;
  
  /// Whether to show detailed information
  final bool showDetails;
  
  /// Maximum number of holdings to show per page
  final int maxHoldings;
  
  /// Callback when a holding is tapped
  final Function(EquityHolding)? onHoldingTap;
  
  /// Callback when "View All" button is tapped
  final VoidCallback? onViewAll;
  
  /// Row height for the table
  final double? rowHeight;
  
  /// Constructor
  const PortfolioHoldingsCard({
    Key? key,
    required this.holdings,
    this.showDetails = false,
    this.maxHoldings = 25,
    this.onHoldingTap,
    this.onViewAll,
    this.rowHeight,
  }) : super(key: key);

  @override
  State<PortfolioHoldingsCard> createState() => _PortfolioHoldingsCardState();
}

class _PortfolioHoldingsCardState extends State<PortfolioHoldingsCard> {
  int _currentPage = 0;
  List<EquityHolding> _sortedHoldings = [];
  int _totalPages = 1;
  
  @override
  void initState() {
    super.initState();
    _sortHoldingsByAllocation();
  }
  
  @override
  void didUpdateWidget(PortfolioHoldingsCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.holdings != widget.holdings) {
      _sortHoldingsByAllocation();
    }
  }
  
  void _sortHoldingsByAllocation() {
    // Sort holdings by weight in portfolio (allocation percentage) in descending order
    _sortedHoldings = List.from(widget.holdings.equityHoldings);
    _sortedHoldings.sort((a, b) => b.weightInPortfolio.compareTo(a.weightInPortfolio));
    
    // Calculate total pages
    _totalPages = (_sortedHoldings.length / widget.maxHoldings).ceil();
    if (_totalPages == 0) _totalPages = 1; // At least one page even if empty
    
    // Reset to first page when data changes
    _currentPage = 0;
  }
  
  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      setState(() {
        _currentPage++;
      });
    }
  }
  
  void _previousPage() {
    if (_currentPage > 0) {
      setState(() {
        _currentPage--;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(
      symbol: '₹',
      locale: 'en_IN',
      decimalDigits: 2,
    );
    
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate start and end indices for current page
        final startIndex = _currentPage * widget.maxHoldings;
        final endIndex = min(startIndex + widget.maxHoldings, _sortedHoldings.length);
        
        // Get holdings for current page
        final List<EquityHolding> displayHoldings = _sortedHoldings.isEmpty ? <EquityHolding>[] : 
            _sortedHoldings.sublist(startIndex, endIndex);
        
        // Use a fixed row height that works well for all content
        final rowHeight = 40.0;
        
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: theme.colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0), // Fixed padding for consistency
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with title
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6.0),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.account_balance,
                            color: theme.colorScheme.primary,
                            size: 16.0, // Fixed size for consistency
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        Text(
                          'Portfolio Holdings',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 12.0),
                
                // Summary section if enabled
                if (widget.showDetails) ...[                  
                  _buildSummarySection(theme, currencyFormat),
                  const SizedBox(height: 12.0),
                ],
                
                // Sortable table for holdings - use Expanded to fill available space
                // and ensure scrolling works for large datasets
                Expanded(
                  child: SortableTable<EquityHolding>(
                    items: displayHoldings,
                    columns: _buildColumns(currencyFormat),
                    initialSortColumnIndex: 2, // Sort by current value initially
                    initialSortDirection: SortDirection.descending,
                    onItemTap: widget.onHoldingTap,
                    showDividers: true,
                    rowHeight: rowHeight,
                  ),
                ),
                
                const SizedBox(height: 12.0),
                
                // Pagination controls
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Pagination controls
                    if (_totalPages > 1)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Previous page button
                          IconButton(
                            onPressed: _currentPage > 0 ? _previousPage : null,
                            icon: const Icon(Icons.chevron_left),
                            tooltip: 'Previous page',
                            color: theme.colorScheme.primary,
                            disabledColor: theme.colorScheme.onSurface.withOpacity(0.3),
                            iconSize: 16.0, // Fixed size for consistency
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 24.0, 
                              minHeight: 24.0
                            ),
                          ),
                          
                          // Page indicator
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              'Page ${_currentPage + 1} of $_totalPages',
                              style: theme.textTheme.bodySmall,
                            ),
                          ),
                          
                          // Next page button
                          IconButton(
                            onPressed: _currentPage < _totalPages - 1 ? _nextPage : null,
                            icon: const Icon(Icons.chevron_right),
                            tooltip: 'Next page',
                            color: theme.colorScheme.primary,
                            disabledColor: theme.colorScheme.onSurface.withOpacity(0.3),
                            iconSize: 16.0, // Fixed size for consistency
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 24.0,
                              minHeight: 24.0
                            ),
                          ),
                        ],
                      ),
                    
                    const SizedBox(height: 4.0),
                    
                    // Total holdings count
                    Text(
                      'Showing ${startIndex + 1}-$endIndex of ${_sortedHoldings.length} holdings',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  /// Build summary section with fixed sizing
  Widget _buildSummarySection(ThemeData theme, NumberFormat currencyFormat) {
    // Calculate total investment and current value
    double totalInvestment = 0;
    double totalCurrentValue = 0;
    
    for (final holding in widget.holdings.equityHoldings) {
      totalInvestment += holding.investmentCost;
      totalCurrentValue += holding.currentValue;
    }
    
    // Calculate total gain/loss
    final totalGainLoss = totalCurrentValue - totalInvestment;
    final totalGainLossPercentage = totalInvestment > 0
        ? (totalGainLoss / totalInvestment) * 100
        : 0;
    
    // Determine color based on gain/loss
    final isPositive = totalGainLoss >= 0;
    final valueColor = isPositive ? Colors.green.shade700 : Colors.red.shade700;
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          // Investment value
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Investment',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4.0),
                Text(
                  currencyFormat.format(totalInvestment),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          
          // Current value
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Current Value',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4.0),
                Text(
                  currencyFormat.format(totalCurrentValue),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: valueColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          
          // Gain/Loss
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Gain/Loss',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4.0),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        '${isPositive ? "+" : ""}${currencyFormat.format(totalGainLoss)}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: valueColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4.0),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4.0,
                        vertical: 2.0,
                      ),
                      decoration: BoxDecoration(
                        color: valueColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${isPositive ? "+" : ""}${totalGainLossPercentage.toStringAsFixed(2)}%',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: valueColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  /// Build columns for the sortable table with fixed sizing
  List<SortableColumn<EquityHolding>> _buildColumns(NumberFormat currencyFormat) {
    final theme = Theme.of(context);
    
    return [
      // Symbol column
      SortableColumn<EquityHolding>(
        title: 'Symbol',
        flex: 1,
        sortBy: (holding) => holding.symbol,
        builder: (holding) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              holding.symbol,
              style: const TextStyle(fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
            if (widget.showDetails)
              Text(
                holding.sector,
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                  fontSize: 11, // Fixed smaller font size
                ),
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
      ),
      
      // Quantity column
      SortableColumn<EquityHolding>(
        title: 'Qty',
        flex: 1,
        sortBy: (holding) => holding.quantity,
        builder: (holding) => Text(
          holding.quantity.toString(),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      
      // % of Portfolio column
      SortableColumn<EquityHolding>(
        title: '% of Port',
        flex: 1,
        textAlign: TextAlign.end,
        sortBy: (holding) => holding.weightInPortfolio,
        builder: (holding) => Text(
          '${holding.weightInPortfolio.toStringAsFixed(1)}%',
          textAlign: TextAlign.end,
          style: const TextStyle(fontWeight: FontWeight.w500),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      
      // Investment Cost column
      SortableColumn<EquityHolding>(
        title: 'Invested',
        flex: 1,
        textAlign: TextAlign.end,
        sortBy: (holding) => holding.investmentCost,
        builder: (holding) => Text(
          currencyFormat.format(holding.investmentCost),
          textAlign: TextAlign.end,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      
      // Current Value column
      SortableColumn<EquityHolding>(
        title: 'Curr Value',
        flex: 1,
        textAlign: TextAlign.end,
        sortBy: (holding) => holding.currentValue,
        builder: (holding) => Text(
          currencyFormat.format(holding.currentValue),
          textAlign: TextAlign.end,
          style: const TextStyle(fontWeight: FontWeight.w500),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      
      // Average price column
      SortableColumn<EquityHolding>(
        title: 'Avg Price',
        flex: 1,
        textAlign: TextAlign.end,
        sortBy: (holding) => holding.investmentCost / holding.quantity,
        builder: (holding) => Text(
          currencyFormat.format(holding.investmentCost / holding.quantity),
          textAlign: TextAlign.end,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      
      // Current price column
      SortableColumn<EquityHolding>(
        title: 'LTP',
        flex: 1,
        textAlign: TextAlign.end,
        sortBy: (holding) => holding.currentPrice,
        builder: (holding) => Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              currencyFormat.format(holding.currentPrice),
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
            ),
            if (widget.showDetails)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    holding.percentageChange >= 0
                        ? Icons.arrow_upward
                        : Icons.arrow_downward,
                    color: holding.percentageChange >= 0
                        ? Colors.green
                        : Colors.red,
                    size: 10, // Fixed icon size
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '${holding.percentageChange.abs().toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: holding.percentageChange >= 0
                          ? Colors.green
                          : Colors.red,
                      fontWeight: FontWeight.w500,
                      fontSize: 10, // Fixed font size
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
          ],
        ),
      ),
      
      // Gain/Loss column
      SortableColumn<EquityHolding>(
        title: 'Gain/Loss',
        flex: 1,
        textAlign: TextAlign.end,
        sortBy: (holding) => holding.gainLoss,
        builder: (holding) {
          final isPositive = holding.gainLoss >= 0;
          final valueColor = isPositive ? Colors.green.shade700 : Colors.red.shade700;
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${isPositive ? "+" : ""}${currencyFormat.format(holding.gainLoss)}',
                style: TextStyle(
                  color: valueColor,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.end,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                '${isPositive ? "+" : ""}${holding.gainLossPercentage.toStringAsFixed(1)}%',
                style: TextStyle(
                  color: valueColor,
                  fontSize: 11, // Fixed smaller font size
                ),
                textAlign: TextAlign.end,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          );
        },
      ),
    ];
  }
}
