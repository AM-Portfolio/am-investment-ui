import 'package:flutter/material.dart';
import 'generic_filter_widget.dart';
import '../../../features/portfolio/filters/portfolio_filter_provider.dart';

/// Portfolio-specific filter widget that uses the generic filter architecture
/// This provides portfolio-specific filtering with reusable components
class PortfolioFilterWidget extends StatelessWidget {
  /// The list of portfolio holdings to filter
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
  Widget build(BuildContext context) {
    return GenericFilterWidget<dynamic>(
      items: holdings,
      filterProvider: PortfolioFilterProvider(),
      onFiltersApplied: onFiltersApplied,
      onFiltersReset: onFiltersReset,
      initiallyExpanded: initiallyExpanded,
      title: 'Portfolio Filters',
      icon: Icons.business_center_outlined,
    );
  }
}
