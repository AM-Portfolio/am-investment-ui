import 'dart:async';

import '../../../../core/utils/logger.dart';
import '../../../../shared/widgets/heatmap/contracts/heatmap_contracts.dart';
import '../cubit/portfolio_heatmap_cubit.dart';

/// Portfolio-specific implementation of HeatmapRefreshContract
///
/// This adapter connects the shared heatmap components' refresh functionality
/// to the portfolio feature's PortfolioHeatmapCubit, following the established
/// architectural patterns.
///
/// Usage:
/// ```dart
/// final refreshAdapter = PortfolioHeatmapRefreshAdapter(portfolioHeatmapCubit);
/// final core = HeatmapDisplayCore.withContracts(
///   dataContract: dataAdapter,
///   refreshContract: refreshAdapter,
/// );
/// ```
class PortfolioHeatmapRefreshAdapter implements HeatmapRefreshContract {
  PortfolioHeatmapRefreshAdapter(this._cubit) {
    _refreshStreamController = StreamController<bool>.broadcast();
  }

  final PortfolioHeatmapCubit _cubit;

  // Stream controller for refresh state
  late final StreamController<bool> _refreshStreamController;

  // Track refresh state
  bool _isRefreshing = false;

  @override
  Future<void> refresh() async {
    AppLogger.info(
      'PortfolioHeatmapRefreshAdapter: refresh requested',
      tag: 'Portfolio.Heatmap.Refresh.Adapter',
    );

    if (_isRefreshing) {
      // Prevent multiple simultaneous refresh operations
      AppLogger.warning(
        'PortfolioHeatmapRefreshAdapter: refresh already in progress, skipping',
        tag: 'Portfolio.Heatmap.Refresh.Adapter',
      );
      return;
    }

    try {
      _setRefreshing(true);
      AppLogger.debug(
        'PortfolioHeatmapRefreshAdapter: refresh state set to true',
        tag: 'Portfolio.Heatmap.Refresh.Adapter',
      );

      // Log current cubit state before refresh
      AppLogger.debug(
        'PortfolioHeatmapRefreshAdapter: pre-refresh cubit state - ${_cubit.state.runtimeType}',
        tag: 'Portfolio.Heatmap.Refresh.Adapter',
      );

      // Delegate to the cubit's refresh method
      AppLogger.info(
        'PortfolioHeatmapRefreshAdapter: calling cubit.refresh()',
        tag: 'Portfolio.Heatmap.Refresh.Adapter',
      );
      await _cubit.refresh();

      // Log post-refresh cubit state
      AppLogger.debug(
        'PortfolioHeatmapRefreshAdapter: post-refresh cubit state - ${_cubit.state.runtimeType}',
        tag: 'Portfolio.Heatmap.Refresh.Adapter',
      );

      AppLogger.info(
        'PortfolioHeatmapRefreshAdapter: refresh completed successfully',
        tag: 'Portfolio.Heatmap.Refresh.Adapter',
      );
    } catch (error) {
      AppLogger.error(
        'PortfolioHeatmapRefreshAdapter: refresh failed - $error',
        tag: 'Portfolio.Heatmap.Refresh.Adapter',
        error: error,
      );
      rethrow;
    } finally {
      _setRefreshing(false);
      AppLogger.debug(
        'PortfolioHeatmapRefreshAdapter: refresh state set to false',
        tag: 'Portfolio.Heatmap.Refresh.Adapter',
      );
    }
  }

  @override
  bool get isRefreshing => _isRefreshing;

  @override
  Stream<bool> get refreshStream => _refreshStreamController.stream;

  /// Update refresh state and emit to stream
  void _setRefreshing(bool isRefreshing) {
    if (_isRefreshing != isRefreshing) {
      _isRefreshing = isRefreshing;
      _refreshStreamController.add(_isRefreshing);
    }
  }

  @override
  void dispose() {
    // Clean up resources
    _refreshStreamController.close();
  }
}
