import 'package:flutter/material.dart';
import '../../../shared/widgets/filters/generic_filter_widget.dart';
import 'watchlist_filter_provider.dart';

/// Watchlist-specific filter widget that uses the generic filter architecture
/// This demonstrates how the same filter structure can be reused across features
class WatchlistFilterWidget extends StatelessWidget {
  /// The list of watchlist items to filter
  final List<dynamic> watchlistItems;
  
  /// Callback when filters are applied
  final Function(List<dynamic>) onFiltersApplied;
  
  /// Callback when filters are reset
  final VoidCallback? onFiltersReset;
  
  /// Whether to show the filter panel initially
  final bool initiallyExpanded;
  
  /// Constructor
  const WatchlistFilterWidget({
    super.key,
    required this.watchlistItems,
    required this.onFiltersApplied,
    this.onFiltersReset,
    this.initiallyExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    return GenericFilterWidget<dynamic>(
      items: watchlistItems,
      filterProvider: WatchlistFilterProvider(),
      onFiltersApplied: onFiltersApplied,
      onFiltersReset: onFiltersReset,
      initiallyExpanded: initiallyExpanded,
      title: 'Watchlist Filters',
      icon: Icons.visibility_outlined,
    );
  }
}