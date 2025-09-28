import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../shared/core/filters/filter_models.dart';
import 'portfolio_filter_provider.dart';

/// State for portfolio filter functionality
abstract class PortfolioFilterState extends Equatable {
  const PortfolioFilterState();
}

/// Initial state for portfolio filters
class PortfolioFilterInitial extends PortfolioFilterState {
  @override
  List<Object> get props => [];
}

/// Loading state while applying filters
class PortfolioFilterLoading extends PortfolioFilterState {
  @override
  List<Object> get props => [];
}

/// Success state with filtered results
class PortfolioFilterSuccess extends PortfolioFilterState {
  /// The original unfiltered items
  final List<dynamic> originalItems;
  
  /// The filtered items
  final List<dynamic> filteredItems;
  
  /// The active filter criteria
  final List<FilterCriteria> activeFilters;
  
  /// Number of active filters
  final int activeFilterCount;
  
  /// Available filter options
  final FilterOptions filterOptions;
  
  const PortfolioFilterSuccess({
    required this.originalItems,
    required this.filteredItems,
    required this.activeFilters,
    required this.activeFilterCount,
    required this.filterOptions,
  });
  
  @override
  List<Object> get props => [
    originalItems,
    filteredItems,
    activeFilters,
    activeFilterCount,
    filterOptions,
  ];
  
  /// Create a copy with updated values
  PortfolioFilterSuccess copyWith({
    List<dynamic>? originalItems,
    List<dynamic>? filteredItems,
    List<FilterCriteria>? activeFilters,
    int? activeFilterCount,
    FilterOptions? filterOptions,
  }) {
    return PortfolioFilterSuccess(
      originalItems: originalItems ?? this.originalItems,
      filteredItems: filteredItems ?? this.filteredItems,
      activeFilters: activeFilters ?? this.activeFilters,
      activeFilterCount: activeFilterCount ?? this.activeFilterCount,
      filterOptions: filterOptions ?? this.filterOptions,
    );
  }
}

/// Error state for portfolio filters
class PortfolioFilterError extends PortfolioFilterState {
  final String message;
  
  const PortfolioFilterError({required this.message});
  
  @override
  List<Object> get props => [message];
}

/// Cubit for managing portfolio filter state
class PortfolioFilterCubit extends Cubit<PortfolioFilterState> {
  final PortfolioFilterProvider _filterProvider;
  
  PortfolioFilterCubit({
    PortfolioFilterProvider? filterProvider,
  }) : _filterProvider = filterProvider ?? PortfolioFilterProvider(),
       super(PortfolioFilterInitial());
  
  /// Initialize filters with portfolio items
  void initializeFilters(List<dynamic> items) {
    try {
      emit(PortfolioFilterLoading());
      
      final filterCriteria = _filterProvider.getFilterCriteria();
      final filterOptions = _filterProvider.extractFilterOptions(items);
      
      emit(PortfolioFilterSuccess(
        originalItems: items,
        filteredItems: items,
        activeFilters: filterCriteria,
        activeFilterCount: 0,
        filterOptions: filterOptions,
      ));
    } catch (e) {
      emit(PortfolioFilterError(message: 'Failed to initialize filters: $e'));
    }
  }
  
  /// Apply filters to the portfolio items
  void applyFilters(List<FilterCriteria> filters) {
    final currentState = state;
    if (currentState is! PortfolioFilterSuccess) return;
    
    try {
      emit(PortfolioFilterLoading());
      
      final filteredItems = _filterProvider.applyFilters(
        currentState.originalItems,
        filters,
      );
      
      final activeFilterCount = filters.where((f) => f.isActive).length;
      
      emit(currentState.copyWith(
        filteredItems: filteredItems,
        activeFilters: filters,
        activeFilterCount: activeFilterCount,
      ));
    } catch (e) {
      emit(PortfolioFilterError(message: 'Failed to apply filters: $e'));
    }
  }
  
  /// Reset all filters
  void resetFilters() {
    final currentState = state;
    if (currentState is! PortfolioFilterSuccess) return;
    
    try {
      final resetFilters = _filterProvider.getFilterCriteria();
      
      emit(currentState.copyWith(
        filteredItems: currentState.originalItems,
        activeFilters: resetFilters,
        activeFilterCount: 0,
      ));
    } catch (e) {
      emit(PortfolioFilterError(message: 'Failed to reset filters: $e'));
    }
  }
  
  /// Update specific filter criteria
  void updateFilter(String field, FilterCriteria updatedFilter) {
    final currentState = state;
    if (currentState is! PortfolioFilterSuccess) return;
    
    try {
      final updatedFilters = currentState.activeFilters.map((filter) {
        if (filter.field == field) {
          return updatedFilter;
        }
        return filter;
      }).toList();
      
      applyFilters(updatedFilters);
    } catch (e) {
      emit(PortfolioFilterError(message: 'Failed to update filter: $e'));
    }
  }
  
  /// Update items (when portfolio data changes)
  void updateItems(List<dynamic> newItems) {
    try {
      emit(PortfolioFilterLoading());
      
      final filterCriteria = _filterProvider.getFilterCriteria();
      final filterOptions = _filterProvider.extractFilterOptions(newItems);
      
      // Re-apply any existing filters to the new data
      final currentState = state;
      List<FilterCriteria> existingFilters = [];
      
      if (currentState is PortfolioFilterSuccess) {
        existingFilters = currentState.activeFilters;
      }
      
      final filteredItems = existingFilters.isNotEmpty
          ? _filterProvider.applyFilters(newItems, existingFilters)
          : newItems;
      
      final activeFilterCount = existingFilters.where((f) => f.isActive).length;
      
      emit(PortfolioFilterSuccess(
        originalItems: newItems,
        filteredItems: filteredItems,
        activeFilters: existingFilters.isNotEmpty ? existingFilters : filterCriteria,
        activeFilterCount: activeFilterCount,
        filterOptions: filterOptions,
      ));
    } catch (e) {
      emit(PortfolioFilterError(message: 'Failed to update items: $e'));
    }
  }
}