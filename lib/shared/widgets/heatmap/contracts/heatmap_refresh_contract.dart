/// Generic contract for handling heatmap refresh operations
///
/// This interface allows any feature to provide refresh functionality without the shared
/// layer needing to know about specific implementation details (cubits, services, etc.)
///
/// Implementation Guide:
/// 1. Create a concrete adapter in your feature's adapters/ folder
/// 2. Implement the refresh method to trigger your data reload logic
/// 3. Connect to your existing state management refresh methods
/// 4. Pass the adapter to shared heatmap components
///
/// Example usage in feature:
/// ```dart
/// // lib/features/portfolio/presentation/adapters/portfolio_heatmap_refresh_adapter.dart
/// class PortfolioHeatmapRefreshAdapter implements HeatmapRefreshContract {
///   final PortfolioHeatmapCubit _cubit;
///
///   @override
///   Future<void> refresh() async {
///     await _cubit.refresh();
///   }
/// }
/// ```
abstract class HeatmapRefreshContract {
  /// Trigger a refresh of the heatmap data
  ///
  /// This method should initiate a refresh operation in the implementing
  /// feature. It should reload data from the original source (API, cache, etc.)
  /// and update the corresponding data streams.
  ///
  /// The method should handle its own error states and loading indicators
  /// through the connected data contract streams.
  ///
  /// Returns a Future that completes when the refresh operation is done,
  /// regardless of success or failure. Errors should be communicated through
  /// the data contract's error stream rather than thrown.
  Future<void> refresh();

  /// Whether refresh operation is currently in progress
  ///
  /// This can be used by UI components to show refresh-specific loading
  /// indicators separate from regular loading states.
  bool get isRefreshing;

  /// Stream of refresh state changes
  ///
  /// Emits true when refresh starts, false when refresh completes
  /// (regardless of success or failure).
  Stream<bool> get refreshStream;

  /// Dispose resources when the contract is no longer needed
  ///
  /// Implementing classes should clean up any streams, listeners, or other
  /// resources to prevent memory leaks.
  void dispose() {
    // Base implementation - override in implementing classes
  }
}
