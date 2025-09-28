import 'package:flutter/material.dart';
import '../../../core/app_logic/domain/entities/portfolio/portfolio_holdings.dart';

/// Filter type enum to define different types of filters
enum FilterType {
  /// Filter by text fields like symbol, sector, industry
  text,
  
  /// Filter by numeric range like price, quantity
  range,
  
  /// Filter by specific categories like market cap
  category,
  
  /// Filter by performance metrics (gain/loss)
  performance
}

/// Filter category enum to group filters by category
enum FilterCategory {
  /// Basic filters (symbol search, etc.)
  basic,
  
  /// Classification filters (sector, industry, market cap)
  classification,
  
  /// Value filters (investment cost, current value)
  value,
  
  /// Performance filters (gain/loss)
  performance
}

/// Filter criteria class to store filter settings
class FilterCriteria {
  /// The field to filter on
  final String field;
  
  /// The type of filter
  final FilterType type;
  
  /// The category this filter belongs to
  final FilterCategory category;
  
  /// Display name for the filter
  final String displayName;
  
  /// Text value for text filters
  String? textValue;
  
  /// Min value for range filters
  double? minValue;
  
  /// Max value for range filters
  double? maxValue;
  
  /// Selected categories for category filters
  List<String>? selectedCategories;
  
  /// Performance direction (positive/negative)
  bool? isPositive;
  
  /// Constructor
  FilterCriteria({
    required this.field,
    required this.type,
    required this.category,
    required this.displayName,
    this.textValue,
    this.minValue,
    this.maxValue,
    this.selectedCategories,
    this.isPositive,
  });
  
  /// Clone the filter criteria
  FilterCriteria clone() {
    return FilterCriteria(
      field: field,
      type: type,
      category: category,
      displayName: displayName,
      textValue: textValue,
      minValue: minValue,
      maxValue: maxValue,
      selectedCategories: selectedCategories != null 
          ? List.from(selectedCategories!)
          : null,
      isPositive: isPositive,
    );
  }
  
  /// Check if the filter is active
  bool get isActive {
    switch (type) {
      case FilterType.text:
        return textValue != null && textValue!.isNotEmpty;
      case FilterType.range:
        return minValue != null || maxValue != null;
      case FilterType.category:
        return selectedCategories != null && selectedCategories!.isNotEmpty;
      case FilterType.performance:
        return isPositive != null;
    }
  }
  
  /// Reset the filter
  void reset() {
    textValue = null;
    minValue = null;
    maxValue = null;
    selectedCategories = null;
    isPositive = null;
  }
}

/// A widget that provides advanced filtering capabilities for portfolio holdings
class PortfolioFilterWidget extends StatefulWidget {
  /// The list of holdings to filter
  final List<dynamic> holdings;
  
  /// Callback when filters are applied
  final Function(List<dynamic>) onFiltersApplied;
  
  /// Callback when filters are reset
  final VoidCallback? onFiltersReset;
  
  /// Whether to show the filter panel initially
  final bool initiallyExpanded;
  
  /// Constructor
  const PortfolioFilterWidget({
    super.key,
    required this.holdings,
    required this.onFiltersApplied,
    this.onFiltersReset,
    this.initiallyExpanded = false,
  });

  @override
  State<PortfolioFilterWidget> createState() => _PortfolioFilterWidgetState();
}

class _PortfolioFilterWidgetState extends State<PortfolioFilterWidget> {
  bool _isExpanded = false;
  final List<FilterCriteria> _filters = [];
  List<dynamic> _filteredHoldings = [];
  
  // Selected filter categories
  final Set<FilterCategory> _selectedCategories = {FilterCategory.basic};
  
  // Available sectors and industries for dropdown filters
  List<String> _availableSectors = [];
  List<String> _availableIndustries = [];
  List<String> _availableMarketCaps = [];
  
  // Min and max values for range filters
  double _minInvestment = 0;
  double _maxInvestment = 0;
  double _minCurrentValue = 0;
  double _maxCurrentValue = 0;
  double _minGainLoss = 0;
  double _maxGainLoss = 0;
  double _minQuantity = 0;
  double _maxQuantity = 0;
  
  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
    _filteredHoldings = List.from(widget.holdings);
    _initializeFilters();
    _extractAvailableOptions();
  }
  
  @override
  void didUpdateWidget(PortfolioFilterWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.holdings != widget.holdings) {
      _filteredHoldings = List.from(widget.holdings);
      _extractAvailableOptions();
      _applyFilters(); // Re-apply existing filters to new data
    }
  }
  
  /// Initialize the filter criteria
  void _initializeFilters() {
    _filters.clear();
    
    // Add basic filters (always shown)
    _filters.add(FilterCriteria(
      field: 'symbol',
      type: FilterType.text,
      category: FilterCategory.basic,
      displayName: 'Symbol',
    ));
    
    // Add classification filters
    _filters.add(FilterCriteria(
      field: 'sector',
      type: FilterType.category,
      category: FilterCategory.classification,
      displayName: 'Sector',
    ));
    
    _filters.add(FilterCriteria(
      field: 'industry',
      type: FilterType.category,
      category: FilterCategory.classification,
      displayName: 'Industry',
    ));
    
    _filters.add(FilterCriteria(
      field: 'marketCap',
      type: FilterType.category,
      category: FilterCategory.classification,
      displayName: 'Market Cap',
    ));
    
    // Add value filters
    _filters.add(FilterCriteria(
      field: 'investmentCost',
      type: FilterType.range,
      category: FilterCategory.value,
      displayName: 'Investment',
    ));
    
    _filters.add(FilterCriteria(
      field: 'currentValue',
      type: FilterType.range,
      category: FilterCategory.value,
      displayName: 'Current Value',
    ));
    
    _filters.add(FilterCriteria(
      field: 'quantity',
      type: FilterType.range,
      category: FilterCategory.value,
      displayName: 'Quantity',
    ));
    
    // Add performance filters
    _filters.add(FilterCriteria(
      field: 'gainLoss',
      type: FilterType.performance,
      category: FilterCategory.performance,
      displayName: 'Gain/Loss',
    ));
    
    _filters.add(FilterCriteria(
      field: 'gainLossPercentage',
      type: FilterType.range,
      category: FilterCategory.performance,
      displayName: 'Gain/Loss %',
    ));
  }
  
  /// Extract available options for category filters
  void _extractAvailableOptions() {
    final Set<String> sectors = {};
    final Set<String> industries = {};
    final Set<String> marketCaps = {};
    
    double minInv = double.infinity;
    double maxInv = 0;
    double minCurr = double.infinity;
    double maxCurr = 0;
    double minGain = double.infinity;
    double maxGain = -double.infinity;
    double minQty = double.infinity;
    double maxQty = 0;
    
    for (final holding in widget.holdings) {
      // Collect categories
      if (holding.sector.isNotEmpty) sectors.add(holding.sector);
      if (holding.industry.isNotEmpty) industries.add(holding.industry);
      if (holding.marketCap.isNotEmpty) marketCaps.add(holding.marketCap);
      
      // Find min/max values
      minInv = holding.investmentCost < minInv ? holding.investmentCost : minInv;
      maxInv = holding.investmentCost > maxInv ? holding.investmentCost : maxInv;
      
      minCurr = holding.currentValue < minCurr ? holding.currentValue : minCurr;
      maxCurr = holding.currentValue > maxCurr ? holding.currentValue : maxCurr;
      
      minGain = holding.gainLoss < minGain ? holding.gainLoss : minGain;
      maxGain = holding.gainLoss > maxGain ? holding.gainLoss : maxGain;
      
      minQty = holding.quantity < minQty ? holding.quantity : minQty;
      maxQty = holding.quantity > maxQty ? holding.quantity : maxQty;
    }
    
    setState(() {
      _availableSectors = sectors.toList()..sort();
      _availableIndustries = industries.toList()..sort();
      _availableMarketCaps = marketCaps.toList()..sort();
      
      _minInvestment = minInv != double.infinity ? minInv : 0;
      _maxInvestment = maxInv;
      
      _minCurrentValue = minCurr != double.infinity ? minCurr : 0;
      _maxCurrentValue = maxCurr;
      
      _minGainLoss = minGain != double.infinity ? minGain : 0;
      _maxGainLoss = maxGain;
      
      _minQuantity = minQty != double.infinity ? minQty : 0;
      _maxQuantity = maxQty;
    });
  }
  
  /// Apply all active filters
  void _applyFilters() {
    List<dynamic> result = List.from(widget.holdings);
    
    for (final filter in _filters) {
      if (!filter.isActive) continue;
      
      switch (filter.type) {
        case FilterType.text:
          if (filter.textValue != null && filter.textValue!.isNotEmpty) {
            final searchTerm = filter.textValue!.toLowerCase();
            result = result.where((holding) {
              switch (filter.field) {
                case 'symbol':
                  return (holding.symbol ?? '').toLowerCase().contains(searchTerm);
                default:
                  return true;
              }
            }).toList();
          }
          break;
          
        case FilterType.category:
          if (filter.selectedCategories != null && filter.selectedCategories!.isNotEmpty) {
            result = result.where((holding) {
              switch (filter.field) {
                case 'sector':
                  return filter.selectedCategories!.contains(holding.sector ?? '');
                case 'industry':
                  return filter.selectedCategories!.contains(holding.industry ?? '');
                case 'marketCap':
                  return filter.selectedCategories!.contains(holding.marketCap ?? '');
                default:
                  return true;
              }
            }).toList();
          }
          break;
          
        case FilterType.range:
          result = result.where((holding) {
            double value = 0;
            switch (filter.field) {
              case 'investmentCost':
                value = holding.investmentCost ?? 0;
                break;
              case 'currentValue':
                value = holding.currentValue ?? 0;
                break;
              case 'quantity':
                value = (holding.quantity ?? 0).toDouble();
                break;
              case 'gainLossPercentage':
                value = holding.gainLossPercentage ?? 0;
                break;
              default:
                return true;
            }
            
            bool passesMin = filter.minValue == null || value >= filter.minValue!;
            bool passesMax = filter.maxValue == null || value <= filter.maxValue!;
            return passesMin && passesMax;
          }).toList();
          break;
          
        case FilterType.performance:
          if (filter.isPositive != null) {
            result = result.where((holding) {
              switch (filter.field) {
                case 'gainLoss':
                  final gainLoss = holding.gainLoss ?? 0;
                  return filter.isPositive! ? gainLoss >= 0 : gainLoss < 0;
                default:
                  return true;
              }
            }).toList();
          }
          break;
      }
    }
    
    setState(() {
      _filteredHoldings = result;
    });
    
    widget.onFiltersApplied(_filteredHoldings);
  }
  
  /// Reset all filters
  void _resetFilters() {
    setState(() {
      for (final filter in _filters) {
        filter.reset();
      }
    });
    
    _applyFilters();
    if (widget.onFiltersReset != null) {
      widget.onFiltersReset!();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outline.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Filter header with expand/collapse button
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.filter_list,
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Portfolio Filters',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (_getActiveFilterCount() > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _getActiveFilterCount().toString(),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  Row(
                    children: [
                      if (_getActiveFilterCount() > 0)
                        TextButton(
                          onPressed: _resetFilters,
                          child: const Text('Reset'),
                        ),
                      Icon(
                        _isExpanded ? Icons.expand_less : Icons.expand_more,
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // Filter content
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(),
                  
                  // Filter sections by category
                  Wrap(
                    spacing: 16.0,
                    runSpacing: 16.0,
                    children: _filters
                        .where((filter) => filter.category == FilterCategory.basic)
                        .map((filter) => _buildTextFilter('Symbol Search', filter))
                        .toList(),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Apply filters button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: _resetFilters,
                        child: const Text('Reset All'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _applyFilters,
                        child: const Text('Apply Filters'),
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
  
  /// Get the number of active filters
  int _getActiveFilterCount() {
    return _filters.where((filter) => filter.isActive).length;
  }
  
  /// Build a text filter widget
  Widget _buildTextFilter(String label, FilterCriteria filter) {
    return SizedBox(
      width: 250,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          TextField(
            decoration: InputDecoration(
              hintText: 'Search by symbol...',
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              suffixIcon: filter.textValue != null && filter.textValue!.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 16),
                      onPressed: () {
                        setState(() {
                          filter.textValue = null;
                          _applyFilters();
                        });
                      },
                    )
                  : null,
            ),
            onChanged: (value) {
              setState(() {
                filter.textValue = value;
                _applyFilters();
              });
            },
          ),
        ],
      ),
    );
  }
}
