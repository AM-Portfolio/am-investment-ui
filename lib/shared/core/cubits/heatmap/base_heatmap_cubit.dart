import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/heatmap.dart';
import 'heatmap_state.dart';

/// Base cubit for heatmap functionality
/// Provides common heatmap operations that can be extended by feature-specific cubits
abstract class BaseHeatmapCubit extends Cubit<HeatmapState> {
  BaseHeatmapCubit() : super(const HeatmapInitial());

  /// Load heatmap data - to be implemented by subclasses
  Future<void> loadData();

  /// Refresh heatmap data
  Future<void> refreshData() async {
    final currentState = state;
    if (currentState is HeatmapLoaded) {
      emit(
        HeatmapRefreshing(
          currentData: currentState.data,
          message: 'Refreshing data...',
        ),
      );
    } else {
      emit(const HeatmapLoading(message: 'Loading data...'));
    }

    try {
      await loadData();
    } catch (error, stackTrace) {
      emit(
        HeatmapError(
          message: 'Failed to refresh data: ${error.toString()}',
          error: error,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  /// Clear current data
  void clearData() {
    emit(const HeatmapInitial());
  }

  /// Handle successful data loading
  void emitSuccess(HeatmapData data) {
    emit(HeatmapLoaded(data: data, lastUpdated: DateTime.now()));
  }

  /// Handle data loading error
  void emitError(String message, [Object? error, StackTrace? stackTrace]) {
    emit(HeatmapError(message: message, error: error, stackTrace: stackTrace));
  }

  /// Handle empty data scenario
  void emitEmpty([String? message]) {
    emit(HeatmapEmpty(message: message ?? 'No data available'));
  }

  /// Check if currently loading
  bool get isLoading => state is HeatmapLoading || state is HeatmapRefreshing;

  /// Check if has data
  bool get hasData => state is HeatmapLoaded;

  /// Check if has error
  bool get hasError => state is HeatmapError;

  /// Get current data if available
  HeatmapData? get currentData {
    final currentState = state;
    if (currentState is HeatmapLoaded) {
      return currentState.data;
    } else if (currentState is HeatmapRefreshing) {
      return currentState.currentData;
    }
    return null;
  }

  /// Update configuration for current data
  void updateConfiguration(HeatmapConfiguration newConfiguration) {
    final data = currentData;
    if (data != null) {
      final updatedData = data.copyWith(configuration: newConfiguration);
      emitSuccess(updatedData);
    }
  }

  /// Sort tiles by specified criteria
  void sortTiles(HeatmapSortingType sortingType, {bool ascending = false}) {
    final data = currentData;
    if (data == null) return;

    List<HeatmapTileData> sortedTiles = List.from(data.uiTiles);

    switch (sortingType) {
      case HeatmapSortingType.performance:
        sortedTiles.sort(
          (a, b) => ascending
              ? a.performance.compareTo(b.performance)
              : b.performance.compareTo(a.performance),
        );
        break;
      case HeatmapSortingType.weightage:
        sortedTiles.sort(
          (a, b) => ascending
              ? a.weightage.compareTo(b.weightage)
              : b.weightage.compareTo(a.weightage),
        );
        break;
      case HeatmapSortingType.value:
        sortedTiles.sort((a, b) {
          final aValue = a.value ?? 0;
          final bValue = b.value ?? 0;
          return ascending
              ? aValue.compareTo(bValue)
              : bValue.compareTo(aValue);
        });
        break;
      case HeatmapSortingType.name:
        sortedTiles.sort(
          (a, b) => ascending
              ? a.displayName.compareTo(b.displayName)
              : b.displayName.compareTo(a.displayName),
        );
        break;
      case HeatmapSortingType.custom:
        // Custom sorting should be implemented by subclasses
        break;
    }

    final updatedConfiguration = data.configuration.copyWith(
      defaultSorting: sortingType,
    );

    final updatedData = data.copyWith(
      tiles: sortedTiles,
      configuration: updatedConfiguration,
    );

    emitSuccess(updatedData);
  }

  /// Filter tiles by performance range
  void filterByPerformance({double? minPerformance, double? maxPerformance}) {
    final data = currentData;
    if (data == null) return;

    final filteredTiles = data.uiTiles.where((tile) {
      if (minPerformance != null && tile.performance < minPerformance) {
        return false;
      }
      if (maxPerformance != null && tile.performance > maxPerformance) {
        return false;
      }
      return true;
    }).toList();

    final updatedData = data.copyWith(tiles: filteredTiles);

    if (filteredTiles.isEmpty) {
      emitEmpty('No tiles match the selected criteria');
    } else {
      emitSuccess(updatedData);
    }
  }

  /// Filter tiles by weightage range
  void filterByWeightage({double? minWeightage, double? maxWeightage}) {
    final data = currentData;
    if (data == null) return;

    final filteredTiles = data.uiTiles.where((tile) {
      if (minWeightage != null && tile.weightage < minWeightage) {
        return false;
      }
      if (maxWeightage != null && tile.weightage > maxWeightage) {
        return false;
      }
      return true;
    }).toList();

    final updatedData = data.copyWith(tiles: filteredTiles);

    if (filteredTiles.isEmpty) {
      emitEmpty('No tiles match the selected criteria');
    } else {
      emitSuccess(updatedData);
    }
  }

  /// Search tiles by name/display name
  void searchTiles(String query) {
    final data = currentData;
    if (data == null) return;

    if (query.isEmpty) {
      // Reset to original data - subclasses should implement this
      loadData();
      return;
    }

    final searchQuery = query.toLowerCase();
    final filteredTiles = data.uiTiles.where((tile) {
      return tile.name.toLowerCase().contains(searchQuery) ||
          tile.displayName.toLowerCase().contains(searchQuery);
    }).toList();

    final updatedData = data.copyWith(tiles: filteredTiles);

    if (filteredTiles.isEmpty) {
      emitEmpty('No tiles match "$query"');
    } else {
      emitSuccess(updatedData);
    }
  }

  /// Reset all filters and sorting
  void resetFilters() {
    loadData();
  }
}
