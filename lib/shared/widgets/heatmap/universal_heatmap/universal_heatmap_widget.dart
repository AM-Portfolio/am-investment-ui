import 'package:flutter/material.dart';

import '../../../../core/utils/logger.dart';
import '../../../models/heatmap.dart';
import '../heatmap_config.dart' as ui_config;
import '../../selectors/selectors.dart';
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
    super.key,
    this.config,
    this.onTilePressed,
    this.onFiltersChanged,
    this.showSelectors,
    this.title,
    this.compactMode,
    this.isLoading = false,
    this.error,
    this.templateType = UniversalTemplateType.adaptive,
  });

  /// Investment type (portfolio, index, mutual funds, ETF)
  final InvestmentType investmentType;

  /// Raw data to be converted to heatmap format
  final Map<String, dynamic> rawData;

  /// Optional configuration overrides
  final ui_config.HeatmapConfig? config;

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

  /// Custom title (can override config)
  final String? title;

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
      'Widget config: hasConfig=${config != null}, showSelectors=$showSelectors, '
      'title=$title, compactMode=$compactMode, isLoading=$isLoading, '
      'hasError=${error != null}, templateType=${templateType.name}',
      tag: 'UniversalHeatmapWidget',
    );

    // Get effective configuration based on investment type
    final effectiveConfig = UniversalHeatmapConfigManager.getEffectiveConfig(
      investmentType: investmentType,
      userConfig: config,
      title: title,
      showSelectors: showSelectors,
      compactMode: compactMode,
    );

    // Convert raw data to heatmap data
    final heatmapData =
        UniversalHeatmapDataConverters.convertRawDataToHeatmapData(
          investmentType: investmentType,
          rawData: rawData,
          title:
              title ??
              UniversalHeatmapConfigManager.getDefaultTitle(investmentType),
          subtitle: UniversalHeatmapConfigManager.getDefaultSubtitle(
            investmentType,
          ),
          isLoading: isLoading,
          error: error,
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

    final data =
        heatmapData ??
        UniversalHeatmapDataConverters.getEmptyData(
          investmentType: investmentType,
          title:
              title ??
              UniversalHeatmapConfigManager.getDefaultTitle(investmentType),
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
