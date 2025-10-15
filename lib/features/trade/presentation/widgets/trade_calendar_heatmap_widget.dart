import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/logger.dart';
import '../../../../shared/widgets/heatmap/universal_heatmap/types.dart';
import '../../../../shared/widgets/heatmap/universal_heatmap/universal_heatmap_widget.dart';
import '../../../../shared/widgets/selectors/selectors.dart';
import '../converters/trade_heatmap_converter.dart';
import '../cubit/trade_calendar_cubit.dart';
import '../cubit/trade_calendar_state.dart';

/// Trade Calendar Heatmap Widget following the portfolio pattern
/// Integrates with TradeCalendarCubit and uses Universal Heatmap Widget
class TradeCalendarHeatmapWidget extends StatefulWidget {
  const TradeCalendarHeatmapWidget({
    required this.userId,
    required this.portfolioId,
    super.key,
    this.portfolioName,
    this.config,
  });

  final String userId;
  final String portfolioId;
  final String? portfolioName;
  final TradeCalendarHeatmapConfig? config;

  @override
  State<TradeCalendarHeatmapWidget> createState() =>
      _TradeCalendarHeatmapWidgetState();
}

class _TradeCalendarHeatmapWidgetState
    extends State<TradeCalendarHeatmapWidget> {
  // State variables for selectors
  TimeFrame _selectedTimeframe = TimeFrame.oneMonth;
  MetricType _selectedMetric = MetricType.returns;

  late TradeCalendarHeatmapConfig _effectiveConfig;

  @override
  void initState() {
    super.initState();

    // Get effective configuration
    _effectiveConfig =
        widget.config ??
        const TradeCalendarHeatmapConfig(
          title: 'Trade Calendar Heatmap',
          subtitle: 'Trading Performance Analytics',
        );

    // Initialize default selections
    _selectedTimeframe = TimeFrame.oneMonth;
    _selectedMetric = MetricType.returns;

    AppLogger.info(
      'TradeCalendarHeatmapWidget initialized',
      tag: '${_effectiveConfig.logTag}.Init',
    );
    AppLogger.debug(
      'Parameters: userId=${widget.userId}, portfolioId=${widget.portfolioId}, portfolioName=${widget.portfolioName ?? 'null'}',
      tag: '${_effectiveConfig.logTag}.Init',
    );
    _loadHeatmapData();
  }

  void _loadHeatmapData() {
    AppLogger.methodEntry(
      '_loadHeatmapData',
      tag: '${_effectiveConfig.logTag}.Data',
      params: {
        'portfolioId': widget.portfolioId,
        'timeFrame': _selectedTimeframe.name,
        'metric': _selectedMetric.name,
      },
    );

    final tradeCalendarCubit = context.read<TradeCalendarCubit>();

    // Load trade calendar data with current filters
    tradeCalendarCubit.loadTradeCalendar(
      userId: widget.userId,
      portfolioId: widget.portfolioId,
    );
  }

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<TradeCalendarCubit, TradeCalendarState>(
        builder: (context, state) {
          AppLogger.debug(
            'Building UI for state: ${state.runtimeType}',
            tag: '${_effectiveConfig.logTag}.UI',
          );

          return _buildStateWidget(state);
        },
      );

  /// Builds appropriate widget based on current state
  Widget _buildStateWidget(TradeCalendarState state) {
    if (state is TradeCalendarLoading) {
      return _buildLoadingWidget(state);
    }

    if (state is TradeCalendarError) {
      return _buildErrorWidget(state);
    }

    if (state is TradeCalendarLoaded) {
      return _buildLoadedWidget(state);
    }

    return _buildDefaultWidget();
  }

  /// Builds loading state UI
  Widget _buildLoadingWidget(TradeCalendarLoading state) {
    AppLogger.info('Showing loading...', tag: '${_effectiveConfig.logTag}.UI');

    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Loading trade calendar heatmap...',
            style: TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Builds error state UI
  Widget _buildErrorWidget(TradeCalendarError state) {
    AppLogger.warning(
      'Showing error: ${state.message}',
      tag: '${_effectiveConfig.logTag}.UI',
    );

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error loading trade data',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              state.message,
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadHeatmapData,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds loaded state UI with heatmap
  Widget _buildLoadedWidget(TradeCalendarLoaded state) {
    AppLogger.info(
      'Showing loaded state with ${state.viewModel.trades.length} trades',
      tag: '${_effectiveConfig.logTag}.UI',
    );

    // Convert view model to heatmap data using the converter
    final convertedHeatmapData =
        TradeHeatmapConverter.convertViewModelToHeatmap(
          viewModel: state.viewModel,
          title: _effectiveConfig.title,
          subtitle: _effectiveConfig.subtitle,
          accentColor: Theme.of(context).primaryColor,
        );

    AppLogger.debug(
      'Converted heatmap data: ${convertedHeatmapData.tiles.length} tiles',
      tag: '${_effectiveConfig.logTag}.UI',
    );

    // Return UniversalHeatmapWidget with configuration
    return SizedBox(
      width: double.infinity,
      child: UniversalHeatmapWidget(
        investmentType: InvestmentType.portfolio,
        heatmapData: convertedHeatmapData,
        title: _effectiveConfig.title,
        showSelectors: _effectiveConfig.showSelectors,
        compactMode: _effectiveConfig.compactMode,
        onTilePressed: () {
          AppLogger.userAction(
            'Heatmap tile pressed',
            tag: '${_effectiveConfig.logTag}.Action',
          );
        },
        onFiltersChanged: ({timeFrame, metric, sector, marketCap, layout}) {
          _onFiltersChanged(
            timeFrame: timeFrame,
            metric: metric,
            layout: layout,
          );
        },
        templateType: _effectiveConfig.templateType,
      ),
    );
  }

  /// Builds default/fallback state UI
  Widget _buildDefaultWidget() {
    AppLogger.debug(
      'Showing default widget',
      tag: '${_effectiveConfig.logTag}.UI',
    );

    return const Center(
      child: Text(
        'Initializing trade calendar heatmap...',
        style: TextStyle(color: Colors.grey),
      ),
    );
  }

  /// Handles filter changes from selectors
  void _onFiltersChanged({
    TimeFrame? timeFrame,
    MetricType? metric,
    HeatmapLayoutType? layout,
  }) {
    AppLogger.userAction(
      'Filters changed: timeFrame=${timeFrame?.name ?? 'null'}, metric=${metric?.name ?? 'null'}, layout=${layout?.name ?? 'null'}',
      tag: '${_effectiveConfig.logTag}.Action',
    );

    setState(() {
      if (timeFrame != null) {
        _selectedTimeframe = timeFrame;
      }
      if (metric != null) {
        _selectedMetric = metric;
      }
      // Layout changes are handled by the universal widget
      // No need to store layout state locally
    });

    // Reload data with new filters
    _loadHeatmapData();
  }
}

/// Configuration class for Trade Calendar Heatmap Widget
class TradeCalendarHeatmapConfig {
  const TradeCalendarHeatmapConfig({
    required this.title,
    this.subtitle,
    this.showSelectors = true,
    this.compactMode = false,
    this.templateType = UniversalTemplateType.adaptive,
    this.logTag = 'TradeCalendarHeatmap',
    this.defaultLayout = HeatmapLayoutType.treemap,
  });

  final String title;
  final String? subtitle;
  final bool showSelectors;
  final bool compactMode;
  final UniversalTemplateType templateType;
  final String logTag;
  final HeatmapLayoutType defaultLayout;
}
