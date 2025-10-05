import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/heatmap_display_core.dart';

/// Helper class to connect HeatmapDisplayTemplate refresh functionality to existing cubits/providers
class HeatmapRefreshConnector {
  /// Connect HeatmapDisplayCore to a Cubit that has a refresh method
  ///
  /// Usage:
  /// ```dart
  /// final core = HeatmapRefreshConnector.connectToCubit<MyCubit>(
  ///   context: context,
  ///   data: myData,
  ///   refreshMethod: (cubit) => cubit.refreshData(),
  /// );
  ///
  /// HeatmapDisplayTemplate(core: core)
  /// ```
  static HeatmapDisplayCore connectToCubit<T extends BlocBase<dynamic>>({
    required BuildContext context,
    required data,
    required Future<void> Function(T cubit) refreshMethod,
    bool isLoading = false,
    String? error,
    VoidCallback? onTilePressed,
  }) => HeatmapDisplayCore(
    initialData: data,
    initialIsLoading: isLoading,
    initialError: error,
    onTilePressed: onTilePressed,
    onRefreshRequested: () {
      final cubit = context.read<T>();
      refreshMethod(cubit);
    },
  );

  /// Connect HeatmapDisplayCore to a custom refresh function
  ///
  /// Usage:
  /// ```dart
  /// final core = HeatmapRefreshConnector.connectToRefreshFunction(
  ///   data: myData,
  ///   refreshFunction: () async {
  ///     // Your refresh logic here
  ///     await fetchNewData();
  ///   },
  /// );
  /// ```
  static HeatmapDisplayCore connectToRefreshFunction({
    required data,
    required Future<void> Function() refreshFunction,
    bool isLoading = false,
    String? error,
    VoidCallback? onTilePressed,
  }) => HeatmapDisplayCore(
    initialData: data,
    initialIsLoading: isLoading,
    initialError: error,
    onTilePressed: onTilePressed,
    onRefreshRequested: refreshFunction,
  );

  /// Connect HeatmapDisplayTemplate legacy interface to a refresh function
  ///
  /// Usage:
  /// ```dart
  /// HeatmapDisplayTemplate(
  ///   data: myData,
  ///   isLoading: isLoading,
  ///   onRefreshRequested: HeatmapRefreshConnector.createRefreshCallback(
  ///     context: context,
  ///     refreshAction: () => context.read<MyCubit>().refreshData(),
  ///   ),
  /// )
  /// ```
  static VoidCallback createRefreshCallback({
    required BuildContext context,
    required Future<void> Function() refreshAction,
  }) => () {
    refreshAction().catchError((error) {
      // Handle errors gracefully
      debugPrint('Heatmap refresh failed: $error');
    });
  };

  /// Connect to a specific portfolio heatmap cubit (example implementation)
  ///
  /// This is an example of how to connect to your specific cubit
  /// Replace PortfolioHeatmapCubit with your actual cubit type
  ///
  /// ```dart
  /// final core = HeatmapRefreshConnector.connectToPortfolioHeatmapCubit(
  ///   context: context,
  ///   data: heatmapData,
  ///   portfolioId: 'my-portfolio-id',
  /// );
  /// ```
  static HeatmapDisplayCore connectToPortfolioHeatmapCubit({
    required BuildContext context,
    required data,
    required String portfolioId,
    bool isLoading = false,
    String? error,
    VoidCallback? onTilePressed,
  }) => HeatmapDisplayCore(
    initialData: data,
    initialIsLoading: isLoading,
    initialError: error,
    onTilePressed: onTilePressed,
    onRefreshRequested: () {
      // Example implementation - adjust to match your actual cubit
      // final cubit = context.read<PortfolioHeatmapCubit>();
      // cubit.loadHeatmapData(portfolioId: portfolioId);

      debugPrint(
        'Portfolio heatmap refresh requested for portfolio: $portfolioId',
      );
      // You would implement this connection to your actual cubit
    },
  );
}
