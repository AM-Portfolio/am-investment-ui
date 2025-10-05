import 'dart:async';

import '../../../../core/utils/logger.dart';
import '../../../../shared/models/heatmap/heatmap_ui_data.dart';
import '../../../../shared/widgets/heatmap/contracts/heatmap_contracts.dart';
import '../cubit/portfolio_heatmap_cubit.dart';
import '../cubit/portfolio_heatmap_state.dart';

/// Portfolio-specific implementation of HeatmapDataContract
///
/// This adapter connects the shared heatmap components to the portfolio feature's
/// PortfolioHeatmapCubit, following the established architectural patterns.
///
/// Usage:
/// ```dart
/// final adapter = PortfolioHeatmapDataAdapter(portfolioHeatmapCubit);
/// final core = HeatmapDisplayCore.withContracts(
///   dataContract: adapter,
///   refreshContract: refreshAdapter,
/// );
/// ```
class PortfolioHeatmapDataAdapter implements HeatmapDataContract {
  PortfolioHeatmapDataAdapter(this._cubit) {
    // Subscribe to cubit state changes and transform them to contract streams
    _dataStreamController = StreamController<HeatmapData?>.broadcast();
    _loadingStreamController = StreamController<bool>.broadcast();
    _errorStreamController = StreamController<String?>.broadcast();

    // Listen to cubit state changes and transform them
    _cubitSubscription = _cubit.stream.listen(_handleStateChange);

    // Emit initial state
    _handleStateChange(_cubit.state);
  }

  final PortfolioHeatmapCubit _cubit;

  // Stream controllers for contract compliance
  late final StreamController<HeatmapData?> _dataStreamController;
  late final StreamController<bool> _loadingStreamController;
  late final StreamController<String?> _errorStreamController;

  // Subscription to cubit state changes
  late final StreamSubscription<PortfolioHeatmapState> _cubitSubscription;

  @override
  HeatmapData? get currentData {
    final state = _cubit.state;
    if (state is PortfolioHeatmapLoaded) {
      return state.heatmapData;
    }
    return null;
  }

  @override
  Stream<HeatmapData?> get dataStream => _dataStreamController.stream;

  @override
  bool get isLoading => _cubit.state is PortfolioHeatmapLoading;

  @override
  Stream<bool> get loadingStream => _loadingStreamController.stream;

  @override
  String? get error {
    final state = _cubit.state;
    if (state is PortfolioHeatmapError) {
      return state.message;
    }
    return null;
  }

  @override
  Stream<String?> get errorStream => _errorStreamController.stream;

  @override
  Future<void> loadData(String portfolioId, {bool forceRefresh = false}) async {
    AppLogger.info(
      'PortfolioHeatmapDataAdapter: loadData called for portfolio $portfolioId (forceRefresh: $forceRefresh)',
      tag: 'Portfolio.Heatmap.Data.Adapter',
    );

    try {
      // Delegate to the cubit's loadHeatmapData method
      await _cubit.loadHeatmapData(portfolioId: portfolioId);
      AppLogger.debug(
        'PortfolioHeatmapDataAdapter: loadHeatmapData completed',
        tag: 'Portfolio.Heatmap.Data.Adapter',
      );
    } catch (error) {
      AppLogger.error(
        'PortfolioHeatmapDataAdapter: loadData failed - $error',
        tag: 'Portfolio.Heatmap.Data.Adapter',
        error: error,
      );
      rethrow;
    }
  }

  @override
  Future<void> updateFilters(Map<String, dynamic> filters) async {
    // Extract filter parameters and delegate to appropriate cubit methods
    final timeFrame = filters['timeFrame'];
    final metric = filters['metric'];
    final sector = filters['sector'];
    final marketCap = filters['marketCap'];

    // Update filters using cubit's existing methods
    if (timeFrame != null) {
      await _cubit.updateTimeFrame(timeFrame);
    }
    if (metric != null) {
      await _cubit.updateMetric(metric);
    }
    if (sector != null) {
      await _cubit.updateSector(sector);
    }
    if (marketCap != null) {
      await _cubit.updateMarketCap(marketCap);
    }
  }

  /// Handle state changes from the cubit and emit to contract streams
  void _handleStateChange(PortfolioHeatmapState state) {
    AppLogger.debug(
      'PortfolioHeatmapDataAdapter: handling state change - ${state.runtimeType}',
      tag: 'Portfolio.Heatmap.Data.Adapter',
    );

    // Handle data stream
    if (state is PortfolioHeatmapLoaded) {
      AppLogger.info(
        'PortfolioHeatmapDataAdapter: emitting loaded data with ${state.heatmapData.tiles.length} tiles',
        tag: 'Portfolio.Heatmap.Data.Adapter',
      );
      _dataStreamController.add(state.heatmapData);
    } else {
      AppLogger.debug(
        'PortfolioHeatmapDataAdapter: emitting null data for state ${state.runtimeType}',
        tag: 'Portfolio.Heatmap.Data.Adapter',
      );
      _dataStreamController.add(null);
    }

    // Handle loading stream
    final isLoading = state is PortfolioHeatmapLoading;
    AppLogger.debug(
      'PortfolioHeatmapDataAdapter: emitting loading state - $isLoading',
      tag: 'Portfolio.Heatmap.Data.Adapter',
    );
    _loadingStreamController.add(isLoading);

    // Handle error stream
    if (state is PortfolioHeatmapError) {
      AppLogger.warning(
        'PortfolioHeatmapDataAdapter: emitting error - ${state.message}',
        tag: 'Portfolio.Heatmap.Data.Adapter',
      );
      _errorStreamController.add(state.message);
    } else {
      AppLogger.debug(
        'PortfolioHeatmapDataAdapter: emitting null error',
        tag: 'Portfolio.Heatmap.Data.Adapter',
      );
      _errorStreamController.add(null);
    }
  }

  @override
  void dispose() {
    // Clean up resources
    _cubitSubscription.cancel();
    _dataStreamController.close();
    _loadingStreamController.close();
    _errorStreamController.close();
  }
}
