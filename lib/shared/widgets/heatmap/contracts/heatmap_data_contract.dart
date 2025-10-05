import 'package:flutter/foundation.dart';

import '../../../models/heatmap/heatmap_ui_data.dart';

/// Generic contract for providing heatmap data to shared components
///
/// This interface allows any feature to provide heatmap data without the shared
/// layer needing to know about specific implementation details (cubits, services, etc.)
///
/// Implementation Guide:
/// 1. Create a concrete adapter in your feature's adapters/ folder
/// 2. Implement all required methods and streams
/// 3. Connect to your existing state management (cubit, provider, etc.)
/// 4. Pass the adapter to shared heatmap components
///
/// Example usage in feature:
/// ```dart
/// // lib/features/portfolio/presentation/adapters/portfolio_heatmap_data_adapter.dart
/// class PortfolioHeatmapDataAdapter implements HeatmapDataContract {
///   final PortfolioHeatmapCubit _cubit;
///
///   @override
///   HeatmapData? get currentData => _cubit.state.heatmapData;
///
///   @override
///   Stream<HeatmapData?> get dataStream => _cubit.stream.map((state) => state.heatmapData);
/// }
/// ```
abstract class HeatmapDataContract {
  /// Current heatmap data, null if not loaded
  HeatmapData? get currentData;

  /// Stream of heatmap data changes
  /// Emits null when data is not available or loading
  Stream<HeatmapData?> get dataStream;

  /// Current loading state
  bool get isLoading;

  /// Stream of loading state changes
  Stream<bool> get loadingStream;

  /// Current error message, null if no error
  String? get error;

  /// Stream of error state changes
  /// Emits null when no error, error message when error occurs
  Stream<String?> get errorStream;

  /// Load initial heatmap data
  ///
  /// This method should trigger the data loading process in the implementing
  /// feature. The results should be emitted through the streams.
  ///
  /// [portfolioId] - The ID of the portfolio to load data for
  /// [forceRefresh] - Whether to bypass cache and force fresh data
  Future<void> loadData(String portfolioId, {bool forceRefresh = false});

  /// Update filter parameters and reload data
  ///
  /// This method allows the shared component to request data with different
  /// filter parameters. The implementing adapter should update its internal
  /// state and reload data accordingly.
  ///
  /// [filters] - Map of filter parameters (timeframe, sector, metric, etc.)
  Future<void> updateFilters(Map<String, dynamic> filters);

  /// Dispose resources when the contract is no longer needed
  ///
  /// Implementing classes should clean up any streams, listeners, or other
  /// resources to prevent memory leaks.
  @mustCallSuper
  void dispose() {
    // Base implementation - override in implementing classes
  }
}
