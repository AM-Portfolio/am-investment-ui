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
    
    // Calculate total pages correctly
    // If we have 59 records and maxHoldings is 50, we should have 2 pages (not 3)
    _totalPages = (_sortedHoldings.length / widget.maxHoldings).ceil();
    if (_totalPages == 0) _totalPages = 1; // At least one page even if empty
    
    // Ensure current page is valid
    _currentPage = min(_currentPage, max(0, _totalPages - 1));
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
        
        // Calculate dynamic row height based on container size
        final rowHeight = constraints.maxHeight * 0.06; // 6% of container height
        
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: theme.colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: LayoutBuilder(
            builder: (context, cardConstraints) {
              // Minimal padding to maximize table space
              final horizontalPadding = cardConstraints.maxWidth * 0.01;
              final verticalPadding = cardConstraints.maxHeight * 0.01;
              
              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: verticalPadding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Compact header with title
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.account_balance,
                          color: theme.colorScheme.primary,
                          size: cardConstraints.maxWidth * 0.02,
                        ),
                        SizedBox(width: cardConstraints.maxWidth * 0.01),
                        Text(
                          'Portfolio Holdings',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                
                // Summary section if enabled
                if (widget.showDetails) ...[                  
                  _buildSummarySection(theme, currencyFormat),
                  SizedBox(height: cardConstraints.maxHeight * 0.01),
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
                
                // Compact pagination controls integrated with table footer
                if (_totalPages > 1)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Total holdings count
                      Text(
                        _sortedHoldings.isEmpty
                            ? 'No holdings'
                            : '${startIndex + 1}-$endIndex of ${_sortedHoldings.length}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                          fontSize: cardConstraints.maxWidth * 0.015,
                        ),
                      ),
                      
                      // Page navigation
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Previous page button
                          IconButton(
                            onPressed: _currentPage > 0 ? _previousPage : null,
                            icon: const Icon(Icons.chevron_left, size: 16),
                            tooltip: 'Previous page',
                            color: theme.colorScheme.primary,
                            disabledColor: theme.colorScheme.onSurface.withOpacity(0.3),
                            padding: EdgeInsets.zero,
                            visualDensity: VisualDensity.compact,
                            constraints: BoxConstraints.tightFor(),
                          ),
                          
                          // Page indicator
                          Text(
                            '${_currentPage + 1}/$_totalPages',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: cardConstraints.maxWidth * 0.015,
                            ),
                          ),
                          
                          // Next page button
                          IconButton(
                            onPressed: _currentPage < _totalPages - 1 ? _nextPage : null,
                            icon: const Icon(Icons.chevron_right, size: 16),
                            tooltip: 'Next page',
                            color: theme.colorScheme.primary,
                            disabledColor: theme.colorScheme.onSurface.withOpacity(0.3),
                            padding: EdgeInsets.zero,
                            visualDensity: VisualDensity.compact,
                            constraints: BoxConstraints.tightFor(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
          },
        ),
      );
    }
  }
  
  /// Build summary section with dynamic sizing
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
      margin: const EdgeInsets.symmetric(vertical: 2.0),
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(4),
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
                    fontSize: 10,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2.0),
                Text(
                  currencyFormat.format(totalInvestment),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
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
                    fontSize: 10,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2.0),
                Text(
                  currencyFormat.format(totalCurrentValue),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
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
                    fontSize: 10,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2.0),
                Row(
                  children: [
                    Text(
                      '${isPositive ? '+' : ''}${currencyFormat.format(totalGainLoss)}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: valueColor,
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(width: 2.0),
                    Text(
                      '(${isPositive ? '+' : ''}${totalGainLossPercentage.toStringAsFixed(1)}%)',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: valueColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
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
