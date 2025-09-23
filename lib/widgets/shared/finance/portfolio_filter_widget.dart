import 'package:flutter/material.dart';
import '../../../core/models/portfolio/portfolio_holdings.dart';

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
  final List<EquityHolding> holdings;
  
  /// Callback when filters are applied
  final Function(List<EquityHolding>) onFiltersApplied;
  
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
  List<EquityHolding> _filteredHoldings = [];
  
  // Selected filter categories
  final Set<FilterCategory> _selectedCategories = {FilterCategory.basic};
  
  // Available sectors and industries for dropdown filters
  List<String> _availableSectors = [];
  List<String> _availableIndustries = [];
  List<String> _availableMarketCaps = [];
  List<String> _availableBrokers = [];
  
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
    final Set<String> brokers = {};
    
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
      
      // Collect broker types
      for (final broker in holding.brokerPortfolios) {
        if (broker.brokerType.isNotEmpty) brokers.add(broker.brokerType);
      }
      
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
    
    // Update the lists and values without using setState directly on the variables
    List<String> sortedSectors = sectors.toList()..sort();
    List<String> sortedIndustries = industries.toList()..sort();
    List<String> sortedMarketCaps = marketCaps.toList()..sort();
    List<String> sortedBrokers = brokers.toList()..sort();
    
    double newMinInv = minInv != double.infinity ? minInv : 0;
    double newMaxInv = maxInv;
    
    double newMinCurr = minCurr != double.infinity ? minCurr : 0;
    double newMaxCurr = maxCurr;
    
    double newMinGain = minGain != double.infinity ? minGain : 0;
    double newMaxGain = maxGain;
    
    double newMinQty = minQty != double.infinity ? minQty : 0;
    double newMaxQty = maxQty;
    
    setState(() {
      _availableSectors = sortedSectors;
      _availableIndustries = sortedIndustries;
      _availableMarketCaps = sortedMarketCaps;
      _availableBrokers = sortedBrokers;
      
      _minInvestment = newMinInv;
      _maxInvestment = newMaxInv;
      
      _minCurrentValue = newMinCurr;
      _maxCurrentValue = newMaxCurr;
      
      _minGainLoss = newMinGain;
      _maxGainLoss = newMaxGain;
      
      _minQuantity = newMinQty;
      _maxQuantity = newMaxQty;
    });
  }
  
  /// Apply all active filters
  void _applyFilters() {
    List<EquityHolding> result = List.from(widget.holdings);
    
    for (final filter in _filters) {
      if (!filter.isActive) continue;
      
      switch (filter.type) {
        case FilterType.text:
          if (filter.textValue != null && filter.textValue!.isNotEmpty) {
            final searchTerm = filter.textValue!.toLowerCase();
            result = result.where((holding) {
              switch (filter.field) {
                case 'symbol':
                  // Check if the symbol contains all characters in the search term in order
                  final symbol = holding.symbol.toLowerCase();
                  final searchChars = searchTerm.split('');
                  int lastFoundIndex = -1;
                  bool allCharsFound = true;
                  
                  for (final char in searchChars) {
                    int index = symbol.indexOf(char, lastFoundIndex + 1);
                    if (index == -1) {
                      allCharsFound = false;
                      break;
                    }
                    lastFoundIndex = index;
                  }
                  
                  return allCharsFound;
                default:
                  return true;
              }
            }).toList();
            
            // Sort matching symbols to show most relevant matches first
            if (filter.field == 'symbol') {
              result.sort((a, b) {
                final symbolA = a.symbol.toLowerCase();
                final symbolB = b.symbol.toLowerCase();
                
                // First prioritize exact matches
                bool aExactMatch = symbolA == searchTerm;
                bool bExactMatch = symbolB == searchTerm;
                
                if (aExactMatch && !bExactMatch) return -1;
                if (!aExactMatch && bExactMatch) return 1;
                
                // Then prioritize symbols that start with the search term
                bool aStartsWith = symbolA.startsWith(searchTerm);
                bool bStartsWith = symbolB.startsWith(searchTerm);
                
                if (aStartsWith && !bStartsWith) return -1;
                if (!aStartsWith && bStartsWith) return 1;
                
                // Then prioritize by how early the first character appears
                int aFirstCharIndex = symbolA.indexOf(searchTerm[0]);
                int bFirstCharIndex = symbolB.indexOf(searchTerm[0]);
                
                if (aFirstCharIndex < bFirstCharIndex) return -1;
                if (aFirstCharIndex > bFirstCharIndex) return 1;
                
                // Then prioritize by sequence match quality (fewer gaps between matched chars)
                int aGapSum = _calculateMatchGapSum(symbolA, searchTerm);
                int bGapSum = _calculateMatchGapSum(symbolB, searchTerm);
                
                if (aGapSum < bGapSum) return -1;
                if (aGapSum > bGapSum) return 1;
                
                // Finally sort alphabetically
                return symbolA.compareTo(symbolB);
              });
            }
          }
          break;
          
        case FilterType.category:
          if (filter.selectedCategories != null && filter.selectedCategories!.isNotEmpty) {
            result = result.where((holding) {
              switch (filter.field) {
                case 'sector':
                  return filter.selectedCategories!.contains(holding.sector);
                case 'industry':
                  return filter.selectedCategories!.contains(holding.industry);
                case 'marketCap':
                  return filter.selectedCategories!.contains(holding.marketCap);
                default:
                  return true;
              }
            }).toList();
          }
          break;
          
        case FilterType.range:
          result = result.where((holding) {
            double value;
            switch (filter.field) {
              case 'investmentCost':
                value = holding.investmentCost;
                break;
              case 'currentValue':
                value = holding.currentValue;
                break;
              case 'quantity':
                value = holding.quantity;
                break;
              case 'gainLossPercentage':
                value = holding.gainLossPercentage;
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
                  return filter.isPositive! ? holding.gainLoss >= 0 : holding.gainLoss < 0;
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
        filter.textValue = null;
        filter.selectedCategories = null;
        filter.minValue = null;
        filter.maxValue = null;
        filter.isPositive = null;
      }
    });
    
    _applyFilters();
  }
  
  /// Calculate the sum of gaps between matched characters in a symbol
  /// Lower values indicate better matches with fewer gaps between matched characters
  int _calculateMatchGapSum(String symbol, String searchTerm) {
    final searchChars = searchTerm.split('');
    int lastFoundIndex = -1;
    int gapSum = 0;
    
    for (final char in searchChars) {
      int index = symbol.indexOf(char, lastFoundIndex + 1);
      if (index == -1) return 999; // Large penalty for missing characters
      
      if (lastFoundIndex >= 0) {
        // Add the gap between this character and the previous one
        gapSum += (index - lastFoundIndex - 1);
      }
      
      lastFoundIndex = index;
    }
    
    return gapSum;
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
                        'Advanced Filters',
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
                  
                  // Category selection chips
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Select Filter Categories:',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          children: [
                            _buildCategoryChip(
                              theme,
                              FilterCategory.basic,
                              'Basic',
                              Icons.search,
                            ),
                            _buildCategoryChip(
                              theme,
                              FilterCategory.classification,
                              'Classification',
                              Icons.category,
                            ),
                            _buildCategoryChip(
                              theme,
                              FilterCategory.value,
                              'Value',
                              Icons.attach_money,
                            ),
                            _buildCategoryChip(
                              theme,
                              FilterCategory.performance,
                              'Performance',
                              Icons.trending_up,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const Divider(),
                  
                  // Filter sections by category
                  Wrap(
                    spacing: 16.0,
                    runSpacing: 16.0,
                    children: _filters
                      .where((filter) => _selectedCategories.contains(filter.category))
                      .map((filter) {
                        switch (filter.type) {
                          case FilterType.text:
                            return _buildTextFilter(
                              filter.displayName,
                              filter,
                              hintText: 'Search by ${filter.displayName.toLowerCase()}...',
                            );
                          case FilterType.category:
                            List<String> options = [];
                            if (filter.field == 'sector') options = _availableSectors;
                            else if (filter.field == 'industry') options = _availableIndustries;
                            else if (filter.field == 'marketCap') options = _availableMarketCaps;
                            
                            return _buildCategoryFilter(
                              filter.displayName,
                              filter,
                              options,
                            );
                          case FilterType.range:
                            double minValue = 0;
                            double maxValue = 0;
                            
                            if (filter.field == 'investmentCost') {
                              minValue = _minInvestment;
                              maxValue = _maxInvestment;
                            } else if (filter.field == 'currentValue') {
                              minValue = _minCurrentValue;
                              maxValue = _maxCurrentValue;
                            } else if (filter.field == 'quantity') {
                              minValue = _minQuantity;
                              maxValue = _maxQuantity;
                            } else if (filter.field == 'gainLossPercentage') {
                              minValue = -50;
                              maxValue = 50;
                            }
                            
                            return _buildRangeFilter(
                              filter.displayName,
                              filter,
                              minValue,
                              maxValue,
                            );
                          case FilterType.performance:
                            return _buildPerformanceFilter(
                              filter.displayName,
                              filter,
                            );
                        }
                      }).toList(),
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
  
  /// Get a filter by its field name
  FilterCriteria _getFilterByField(String field) {
    return _filters.firstWhere((filter) => filter.field == field);
  }
  
  /// Build a text filter widget
  Widget _buildTextFilter(
    String label,
    FilterCriteria filter,
    {String hintText = 'Enter text...'}
  ) {
    // Create a controller that won't reset cursor position
    final controller = TextEditingController(text: filter.textValue);
    // Set cursor to end of text
    if (filter.textValue != null) {
      controller.selection = TextSelection.fromPosition(
        TextPosition(offset: filter.textValue!.length),
      );
    }
    
    return SizedBox(
      width: 200,
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
              hintText: hintText,
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
            controller: controller,
          ),
        ],
      ),
    );
  }
  
  /// Build a category filter widget
  Widget _buildCategoryFilter(
    String label,
    FilterCriteria filter,
    List<String> options,
  ) {
    return SizedBox(
      width: 200,
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
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: filter.selectedCategories?.isNotEmpty == true
                    ? filter.selectedCategories!.first
                    : null,
                hint: const Text('Select...'),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                borderRadius: BorderRadius.circular(8),
                items: options.map((option) {
                  return DropdownMenuItem<String>(
                    value: option,
                    child: Text(
                      option,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    if (value != null) {
                      filter.selectedCategories = [value];
                    } else {
                      filter.selectedCategories = null;
                    }
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  /// Build a range filter widget
  Widget _buildRangeFilter(
    String label,
    FilterCriteria filter,
    double minValue,
    double maxValue,
  ) {
    // Use local variables to track slider values
    double currentMin = filter.minValue ?? minValue;
    double currentMax = filter.maxValue ?? maxValue;
    
    return SizedBox(
      width: 200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (filter.minValue != null || filter.maxValue != null)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      filter.minValue = null;
                      filter.maxValue = null;
                    });
                  },
                  child: const Icon(Icons.clear, size: 16),
                ),
            ],
          ),
          const SizedBox(height: 4),
          RangeSlider(
            min: minValue,
            max: maxValue,
            values: RangeValues(currentMin, currentMax),
            onChanged: (RangeValues values) {
              setState(() {
                currentMin = values.start;
                currentMax = values.end;
                filter.minValue = values.start;
                filter.maxValue = values.end;
              });
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                currentMin.toStringAsFixed(0),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                currentMax.toStringAsFixed(0),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  /// Build a performance filter widget
  Widget _buildPerformanceFilter(
    String label,
    FilterCriteria filter,
  ) {
    return SizedBox(
      width: 200,
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
          Row(
            children: [
              Expanded(
                child: _buildPerformanceButton(
                  'Profit',
                  Icons.trending_up,
                  Colors.green,
                  filter.isPositive == true,
                  () {
                    setState(() {
                      filter.isPositive = filter.isPositive == true ? null : true;
                    });
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildPerformanceButton(
                  'Loss',
                  Icons.trending_down,
                  Colors.red,
                  filter.isPositive == false,
                  () {
                    setState(() {
                      filter.isPositive = filter.isPositive == false ? null : false;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  /// Build a performance button
  Widget _buildPerformanceButton(
    String label,
    IconData icon,
    Color color,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? color : Theme.of(context).colorScheme.outline.withOpacity(0.5),
          ),
          borderRadius: BorderRadius.circular(8),
          color: isSelected ? color.withOpacity(0.1) : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isSelected ? color : null,
                fontWeight: isSelected ? FontWeight.bold : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Build a category selection chip
  Widget _buildCategoryChip(
    ThemeData theme,
    FilterCategory category,
    String label,
    IconData icon,
  ) {
    final bool isSelected = _selectedCategories.contains(category);
    final Color chipColor = theme.colorScheme.primary;
    
    return FilterChip(
      selected: isSelected,
      showCheckmark: false,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface.withOpacity(0.7),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
      backgroundColor: theme.colorScheme.surface,
      selectedColor: chipColor,
      checkmarkColor: theme.colorScheme.onPrimary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      side: BorderSide(
        color: isSelected ? chipColor : theme.colorScheme.outline.withOpacity(0.5),
      ),
      onSelected: (selected) {
        setState(() {
          if (selected) {
            _selectedCategories.add(category);
          } else {
            // Don't allow removing the last category
            if (_selectedCategories.length > 1) {
              _selectedCategories.remove(category);
            }
          }
        });
      },
    );
  }
  
}
