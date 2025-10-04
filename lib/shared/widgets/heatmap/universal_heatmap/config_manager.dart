import 'package:flutter/material.dart';

import '../../../../core/utils/logger.dart';
import '../heatmap_config.dart' as ui_config;
import '../../selectors/selectors.dart';
import 'types.dart';

/// Configuration manager for universal heatmap widgets
/// Handles configuration merging, defaults, and effective config calculation
class UniversalHeatmapConfigManager {
  /// Get base configuration for investment type
  static ui_config.HeatmapConfig getBaseConfig(
    InvestmentType investmentType, {
    String? title,
    Color? accentColor,
  }) {
    AppLogger.debug(
      'Creating base config for ${investmentType.name}',
      tag: 'UniversalHeatmapConfigManager',
    );

    // Create base config based on investment type using portfolio defaults
    switch (investmentType) {
      case InvestmentType.portfolio:
        return ui_config.HeatmapConfig.portfolio(
          title: title ?? 'Portfolio Heatmap',
          accentColor: accentColor,
        );
      case InvestmentType.indexFund:
        return ui_config.HeatmapConfig.portfolio(
          title: title ?? 'Index Heatmap',
          accentColor: accentColor,
        );
      case InvestmentType.mutualFunds:
        return ui_config.HeatmapConfig.portfolio(
          title: title ?? 'Mutual Funds Heatmap',
          accentColor: accentColor,
        );
      case InvestmentType.etf:
        return ui_config.HeatmapConfig.portfolio(
          title: title ?? 'ETF Heatmap',
          accentColor: accentColor,
        );
    }
  }

  /// Get effective configuration with user overrides
  static ui_config.HeatmapConfig getEffectiveConfig({
    required InvestmentType investmentType,
    ui_config.HeatmapConfig? userConfig,
    String? title,
    bool? showSelectors,
    bool? compactMode,
    Color? accentColor,
  }) {
    AppLogger.debug(
      'Determining effective config for ${investmentType.name}',
      tag: 'UniversalHeatmapConfigManager.EffectiveConfig',
    );

    final baseConfig = getBaseConfig(
      investmentType,
      title: title,
      accentColor: accentColor,
    );

    AppLogger.debug(
      'Base config selected: layout=${baseConfig.layoutType}, '
      'compact=${baseConfig.compactView}',
      tag: 'UniversalHeatmapConfigManager.EffectiveConfig',
    );

    // Apply user-provided config overrides if available
    if (userConfig != null) {
      AppLogger.debug(
        'Merging user-provided config overrides',
        tag: 'UniversalHeatmapConfigManager.EffectiveConfig',
      );
      final result = mergeConfigs(baseConfig, userConfig);
      AppLogger.info(
        'Final config: layout=${result.layoutType}, compact=${result.compactView}',
        tag: 'UniversalHeatmapConfigManager.EffectiveConfig',
      );
      return result;
    }

    // Apply simple overrides using modifier methods
    if (showSelectors != null || compactMode != null || title != null) {
      AppLogger.debug(
        'Applying simple overrides: showSelectors=$showSelectors, '
        'compactMode=$compactMode, title=$title',
        tag: 'UniversalHeatmapConfigManager.EffectiveConfig',
      );

      var modifiedConfig = baseConfig;

      if (compactMode != null) {
        modifiedConfig = modifiedConfig.withLayout(compact: compactMode);
      }

      if (showSelectors != null) {
        modifiedConfig = modifiedConfig.withSelectors(
          timeFrame: showSelectors,
          metric: showSelectors,
          sector: showSelectors,
          marketCap: showSelectors,
        );
      }

      if (title != null) {
        modifiedConfig = modifiedConfig.withLayout(title: title);
      }

      AppLogger.info(
        'Modified config: layout=${modifiedConfig.layoutType}, '
        'compact=${modifiedConfig.compactView}',
        tag: 'UniversalHeatmapConfigManager.EffectiveConfig',
      );
      return modifiedConfig;
    }

    AppLogger.info(
      'Using base config: layout=${baseConfig.layoutType}, '
      'compact=${baseConfig.compactView}',
      tag: 'UniversalHeatmapConfigManager.EffectiveConfig',
    );
    return baseConfig;
  }

  /// Merge user config with base config
  static ui_config.HeatmapConfig mergeConfigs(
    ui_config.HeatmapConfig baseConfig,
    ui_config.HeatmapConfig userConfig,
  ) {
    AppLogger.debug(
      'Merging configs: base=${baseConfig.layoutType}, user=${userConfig.layoutType}',
      tag: 'UniversalHeatmapConfigManager.ConfigMerge',
    );

    // Use the base config and selectively override with user config parts
    final merged = ui_config.HeatmapConfig(
      selectors: userConfig.selectors ?? baseConfig.selectors,
      display: userConfig.display ?? baseConfig.display,
      layout: userConfig.layout ?? baseConfig.layout,
      interactions: userConfig.interactions ?? baseConfig.interactions,
      visual: userConfig.visual ?? baseConfig.visual,
    );

    AppLogger.debug(
      'Merged config: layout=${merged.layoutType}, compact=${merged.compactView}',
      tag: 'UniversalHeatmapConfigManager.ConfigMerge',
    );

    return merged;
  }

  /// Get initial values for selectors based on investment type
  static TimeFrame getInitialTimeFrame(InvestmentType investmentType) {
    switch (investmentType) {
      case InvestmentType.portfolio:
        return TimeFrame.oneMonth;
      case InvestmentType.indexFund:
        return TimeFrame.oneDay;
      case InvestmentType.mutualFunds:
        return TimeFrame.oneYear;
      case InvestmentType.etf:
        return TimeFrame.oneMonth;
    }
  }

  static MetricType getInitialMetric(InvestmentType investmentType) {
    switch (investmentType) {
      case InvestmentType.portfolio:
      case InvestmentType.etf:
        return MetricType.changePercent;
      case InvestmentType.indexFund:
        return MetricType.changePercent;
      case InvestmentType.mutualFunds:
        return MetricType.returns;
    }
  }

  static SectorType getInitialSector(InvestmentType investmentType) =>
      SectorType.all;

  static MarketCapType getInitialMarketCap(InvestmentType investmentType) =>
      MarketCapType.all;

  /// Get investment-specific icon
  static IconData getInvestmentIcon(InvestmentType investmentType) {
    switch (investmentType) {
      case InvestmentType.portfolio:
        return Icons.pie_chart;
      case InvestmentType.indexFund:
        return Icons.trending_up;
      case InvestmentType.mutualFunds:
        return Icons.account_balance;
      case InvestmentType.etf:
        return Icons.show_chart;
    }
  }

  /// Get investment-specific titles
  static String getDefaultTitle(InvestmentType investmentType) {
    switch (investmentType) {
      case InvestmentType.portfolio:
        return 'Portfolio Heatmap';
      case InvestmentType.indexFund:
        return 'Index Heatmap';
      case InvestmentType.mutualFunds:
        return 'Mutual Funds Heatmap';
      case InvestmentType.etf:
        return 'ETF Heatmap';
    }
  }

  static String getDefaultSubtitle(InvestmentType investmentType) {
    switch (investmentType) {
      case InvestmentType.portfolio:
        return 'Your investment performance overview';
      case InvestmentType.indexFund:
        return 'Index components performance';
      case InvestmentType.mutualFunds:
        return 'Mutual funds performance comparison';
      case InvestmentType.etf:
        return 'ETF performance overview';
    }
  }
}
