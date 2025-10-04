import 'package:flutter/material.dart';

import '../../../../core/utils/logger.dart';
import '../../../models/heatmap.dart';
import '../../selectors/selectors.dart';
import '../heatmap_config.dart' as ui_config;
import 'config_manager.dart';
import 'data_converters.dart';
import 'template_factory.dart';
import 'types.dart';

/// Universal heatmap widget template that orchestrates 3 separate components based on config
/// This is the main widget that should be used for displaying heatmaps across the app
/// Creates: DisplayTemplate + SelectorTemplate + LayoutTemplate based on configuration
class UniversalHeatmapWidget extends StatelessWidget {
  const UniversalHeatmapWidget({
    required this.investmentType,
    required this.rawData,
    required this.title,
    super.key,
    this.config,
    this.onTilePressed,
    this.onFiltersChanged,
    this.showSelectors,
    this.compactMode,
    this.isLoading = false,
    this.error,
    this.templateType = UniversalTemplateType.adaptive,
  });

  /// Investment type (portfolio, index, mutual funds, ETF)
  final InvestmentType investmentType;

  /// Raw data to be converted to heatmap format
  final Map<String, dynamic> rawData;

  /// Configuration overrides (optional, uses basic config if not provided)
  final ui_config.HeatmapConfig? config;

  /// Custom title (required)
  final String title;

  /// Callback when a tile is pressed
  final VoidCallback? onTilePressed;

  /// Callback when filters change
  final Function({
    TimeFrame? timeFrame,
    MetricType? metric,
    SectorType? sector,
    MarketCapType? marketCap,
  })?
  onFiltersChanged;

  /// Whether to show selectors (can override config)
  final bool? showSelectors;

  /// Whether to use compact mode (can override config)
  final bool? compactMode;

  /// Loading state
  final bool isLoading;

  /// Error message
  final String? error;

  /// Template composition type
  final UniversalTemplateType templateType;

  @override
  Widget build(BuildContext context) {
    final buildStartTime = DateTime.now();

    // Log widget initialization
    AppLogger.info(
      'UniversalHeatmapWidget build started for ${investmentType.toString()}',
      tag: 'UniversalHeatmapWidget',
    );

    AppLogger.debug(
      'Widget config: showSelectors=$showSelectors, '
      'title=$title, compactMode=$compactMode, isLoading=$isLoading, '
      'hasError=${error != null}, templateType=${templateType.name}',
      tag: 'UniversalHeatmapWidget',
    );

    // Convert raw data to heatmap data
    final heatmapData =
        UniversalHeatmapDataConverters.convertRawDataToHeatmapData(
          investmentType: investmentType,
          rawData: rawData,
          title: title,
          subtitle: investmentType.name,
          isLoading: isLoading,
          error: error,
        );

    // Get effective config (use provided config or basic fallback)
    final effectiveConfig =
        config ??
        UniversalHeatmapConfigManager.getBasicConfig(
          title: title,
          compactMode: compactMode ?? false,
        );

    // Build the universal template by composing the 3 separate components
    final widget = _buildUniversalTemplate(
      context,
      effectiveConfig,
      heatmapData,
    );

    // Log build completion with performance metrics
    final buildDuration = DateTime.now().difference(buildStartTime);
    AppLogger.info(
      'UniversalHeatmapWidget build completed in ${buildDuration.inMilliseconds}ms - '
      'Investment: ${investmentType.name}, Template: ${templateType.name}, '
      'Tiles: ${heatmapData?.tiles.length ?? 0}, Config: ${effectiveConfig.layoutType}',
      tag: 'UniversalHeatmapWidget.Performance',
    );

    return widget;
  }

  /// Build the universal template by composing the 3 separate components
  Widget _buildUniversalTemplate(
    BuildContext context,
    ui_config.HeatmapConfig effectiveConfig,
    HeatmapData? heatmapData,
  ) {
    AppLogger.debug(
      'Building universal template: layout=${effectiveConfig.layoutType}, '
      'tiles=${heatmapData?.tiles.length ?? 0}, isLoading=$isLoading',
      tag: 'UniversalHeatmapWidget.Template',
    );

    // Log complete effectiveConfig as JSON for debugging
    AppLogger.debug(
      'Complete effectiveConfig: {'
      '"showTimeFrameSelector": ${effectiveConfig.showTimeFrameSelector}, '
      '"showMetricSelector": ${effectiveConfig.showMetricSelector}, '
      '"showSelectorSelector": ${effectiveConfig.showSectorSelector}, '
      '"showMarketCapSelector": ${effectiveConfig.showMarketCapSelector}, '
      '"layoutType": "${effectiveConfig.layoutType}", '
      '"compactView": ${effectiveConfig.compactView}, '
      '"showTitle": ${effectiveConfig.showTitle}, '
      '"customTitle": "${effectiveConfig.customTitle}", '
      '"showLegend": ${effectiveConfig.showLegend}, '
      '"showHeader": ${effectiveConfig.showHeader}'
      '}',
      tag: 'UniversalHeatmapWidget.Config',
    );

    final data =
        heatmapData ??
        UniversalHeatmapDataConverters.getEmptyData(
          investmentType: investmentType,
          title: title,
        );

    // 1. Create Display Template (handles tile rendering)
    final displayTemplate =
        UniversalHeatmapTemplateFactory.createDisplayTemplate(
          heatmapData: data,
          config: effectiveConfig,
          isLoading: isLoading,
          error: error,
          onTilePressed: onTilePressed,
        );

    AppLogger.debug(
      'Display template created with layout=${effectiveConfig.layoutType}',
      tag: 'UniversalHeatmapWidget.Template',
    );

    // 2. Create Selector Template (handles filter UI)
    final selectorTemplate =
        UniversalHeatmapTemplateFactory.createSelectorTemplate(
          config: effectiveConfig,
          investmentType: investmentType,
          onFiltersChanged: onFiltersChanged,
        );

    // 3. Create Layout Template (handles overall structure)
    return UniversalHeatmapTemplateFactory.createLayoutTemplate(
      context: context,
      templateType: templateType,
      config: effectiveConfig,
      data: data,
      investmentType: investmentType,
      displayWidget: displayTemplate,
      selectorWidget: selectorTemplate,
      customTitle: title,
    );
  }
}
