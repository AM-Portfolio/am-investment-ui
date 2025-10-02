import 'dart:ui';
import 'package:flutter/material.dart';

/// Generic heatmap tile data that can be used across features
class HeatmapTileData {
  final String id;
  final String name;
  final String displayName;
  final double weightage;
  final double performance;
  final double? value;
  final Color? customColor;
  final Map<String, dynamic>? metadata;

  const HeatmapTileData({
    required this.id,
    required this.name,
    required this.displayName,
    required this.weightage,
    required this.performance,
    this.value,
    this.customColor,
    this.metadata,
  });

  /// Helper getter for formatted performance with sign
  String get formattedPerformance =>
      '${performance >= 0 ? '+' : ''}${performance.toStringAsFixed(2)}%';

  /// Helper getter for formatted weightage
  String get formattedWeightage => '${weightage.toStringAsFixed(1)}%';

  /// Helper getter for formatted value
  String get formattedValue => value?.toStringAsFixed(2) ?? '';

  /// Helper getter to check if performance is positive
  bool get isPositive => performance >= 0;

  /// Helper getter to check if performance is negative
  bool get isNegative => performance < 0;

  /// Helper getter to check if performance is neutral
  bool get isNeutral => performance == 0;
}

/// Generic heatmap data container
class HeatmapData {
  final String title;
  final String? subtitle;
  final List<HeatmapTileData> tiles;
  final HeatmapConfiguration configuration;

  const HeatmapData({
    required this.title,
    this.subtitle,
    required this.tiles,
    required this.configuration,
  });

  /// Helper getter to check if heatmap has data
  bool get hasData => tiles.isNotEmpty;

  /// Helper getter to get total count of tiles
  int get tileCount => tiles.length;
}

/// Configuration for heatmap display and behavior
class HeatmapConfiguration {
  final bool showSubCards;
  final bool showPerformance;
  final bool showWeightage;
  final bool showValue;
  final HeatmapLayout layout;
  final HeatmapColorScheme colorScheme;
  final double? minTileWidth;
  final double? maxTileWidth;
  final double? minTileHeight;
  final double? maxTileHeight;
  final EdgeInsets? tilePadding;
  final EdgeInsets? tileMargin;

  const HeatmapConfiguration({
    this.showSubCards = true,
    this.showPerformance = true,
    this.showWeightage = true,
    this.showValue = false,
    this.layout = HeatmapLayout.treemap,
    this.colorScheme = HeatmapColorScheme.performance,
    this.minTileWidth,
    this.maxTileWidth,
    this.minTileHeight,
    this.maxTileHeight,
    this.tilePadding,
    this.tileMargin,
  });

  /// Create configuration for mobile view
  factory HeatmapConfiguration.mobile() {
    return const HeatmapConfiguration(
      showSubCards: false,
      showPerformance: true,
      showWeightage: true,
      showValue: false,
      layout: HeatmapLayout.grid,
      minTileWidth: 80,
      maxTileWidth: 120,
      minTileHeight: 60,
      maxTileHeight: 80,
    );
  }

  /// Create configuration for web view
  factory HeatmapConfiguration.web() {
    return const HeatmapConfiguration(
      showSubCards: true,
      showPerformance: true,
      showWeightage: true,
      showValue: true,
      layout: HeatmapLayout.treemap,
      minTileWidth: 120,
      maxTileWidth: 200,
      minTileHeight: 80,
      maxTileHeight: 120,
    );
  }
}

/// Layout types for heatmap display
enum HeatmapLayout { treemap, grid, list }

/// Color scheme options for heatmap
enum HeatmapColorScheme {
  performance, // Color based on performance (red/green)
  custom, // Use custom colors from tile data
  weightage, // Color based on weightage intensity
  neutral, // Single neutral color
}
