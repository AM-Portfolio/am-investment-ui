import 'package:flutter/material.dart';

import '../../../core/app_logic/domain/entities/heatmap/heatmap_entities.dart';
import '../../../core/utils/logger.dart';
import 'heatmap_tile_data.dart';

/// UI-specific heatmap data that extends the core entity with display configurations
class HeatmapData extends HeatmapDataEntity {
  HeatmapData({
    required super.id,
    required super.title,
    required List<HeatmapTileData> tiles,
    required super.metadata,
    required this.configuration,
    super.subtitle,
    this.customHeader,
    this.customFooter,
    this.onRefresh,
    this.onTileInteraction,
  }) : super(tiles: tiles) {
    AppLogger.debug(
      'HeatmapData created: id=$id, tilesCount=${tiles.length}',
      tag: 'HeatmapData',
    );
  }

  /// Create from core entity
  factory HeatmapData.fromEntity(
    HeatmapDataEntity entity, {
    required HeatmapConfiguration configuration,
    Widget? customHeader,
    Widget? customFooter,
    VoidCallback? onRefresh,
    Function(HeatmapTileData)? onTileInteraction,
  }) {
    AppLogger.debug(
      'Converting HeatmapDataEntity to HeatmapData: ${entity.id}',
      tag: 'HeatmapData',
    );

    final uiTiles = entity.tiles.map(HeatmapTileData.fromEntity).toList();

    AppLogger.debug(
      'Converted ${entity.tiles.length} entity tiles to UI tiles',
      tag: 'HeatmapData',
    );

    return HeatmapData(
      id: entity.id,
      title: entity.title,
      subtitle: entity.subtitle,
      tiles: uiTiles,
      metadata: entity.metadata,
      configuration: configuration,
      customHeader: customHeader,
      customFooter: customFooter,
      onRefresh: onRefresh,
      onTileInteraction: onTileInteraction,
    );
  }
  final HeatmapConfiguration configuration;
  final Widget? customHeader;
  final Widget? customFooter;
  final VoidCallback? onRefresh;
  final Function(HeatmapTileData)? onTileInteraction;

  /// Convert to core entity
  HeatmapDataEntity toEntity() {
    final entityTiles = (tiles as List<HeatmapTileData>)
        .map((tile) => tile.toEntity())
        .toList();

    return HeatmapDataEntity(
      id: id,
      title: title,
      subtitle: subtitle,
      tiles: entityTiles,
      metadata: metadata,
    );
  }

  /// Get tiles as UI-specific data
  List<HeatmapTileData> get uiTiles => tiles.cast<HeatmapTileData>();

  @override
  HeatmapData copyWith({
    String? id,
    String? title,
    String? subtitle,
    List<HeatmapTileEntity>? tiles,
    HeatmapMetadata? metadata,
    HeatmapConfiguration? configuration,
    Widget? customHeader,
    Widget? customFooter,
    VoidCallback? onRefresh,
    Function(HeatmapTileData)? onTileInteraction,
  }) => HeatmapData(
    id: id ?? this.id,
    title: title ?? this.title,
    subtitle: subtitle ?? this.subtitle,
    tiles: tiles?.map(HeatmapTileData.fromEntity).toList() ?? uiTiles,
    metadata: metadata ?? this.metadata,
    configuration: configuration ?? this.configuration,
    customHeader: customHeader ?? this.customHeader,
    customFooter: customFooter ?? this.customFooter,
    onRefresh: onRefresh ?? this.onRefresh,
    onTileInteraction: onTileInteraction ?? this.onTileInteraction,
  );
}

/// UI-specific configuration for heatmap display and behavior
class HeatmapConfiguration extends HeatmapConfigurationEntity {
  const HeatmapConfiguration({
    super.showPerformance,
    super.showWeightage,
    super.showValue,
    super.layout,
    super.colorScheme,
    super.defaultSorting,
    super.enabledFilters,
    super.customSettings,
    this.showSubCards = true,
    this.showLegend = true,
    this.showHeader = true,
    this.showFooter = false,
    this.minTileWidth,
    this.maxTileWidth,
    this.minTileHeight,
    this.maxTileHeight,
    this.tilePadding,
    this.tileMargin,
    this.cardPadding,
    this.tileBorderRadius,
    this.tileElevation,
    this.animationDuration,
  });

  /// Create configuration for mobile view
  factory HeatmapConfiguration.mobile() => const HeatmapConfiguration(
    layout: HeatmapLayoutType.grid,
    showSubCards: false, // Simplified for mobile
    showLegend: false, // Hidden for space
    minTileWidth: 80,
    maxTileWidth: 120,
    minTileHeight: 60,
    maxTileHeight: 80,
    tilePadding: EdgeInsets.all(4),
    tileMargin: EdgeInsets.all(2),
    cardPadding: EdgeInsets.all(8),
    tileBorderRadius: BorderRadius.all(Radius.circular(6)),
    tileElevation: 2,
    animationDuration: Duration(milliseconds: 200),
  );

  /// Create configuration for web view
  factory HeatmapConfiguration.web() => const HeatmapConfiguration(
    showValue: true,
    showFooter: true,
    minTileWidth: 120,
    maxTileWidth: 200,
    minTileHeight: 80,
    maxTileHeight: 120,
    tilePadding: EdgeInsets.all(8),
    tileMargin: EdgeInsets.all(4),
    cardPadding: EdgeInsets.all(16),
    tileBorderRadius: BorderRadius.all(Radius.circular(8)),
    tileElevation: 4,
    animationDuration: Duration(milliseconds: 300),
  );

  /// Create minimal configuration for widgets/previews
  factory HeatmapConfiguration.minimal() => const HeatmapConfiguration(
    showWeightage: false,
    layout: HeatmapLayoutType.grid,
    showSubCards: false,
    showLegend: false,
    showHeader: false,
    minTileWidth: 60,
    maxTileWidth: 80,
    minTileHeight: 40,
    maxTileHeight: 60,
    tilePadding: EdgeInsets.all(2),
    tileMargin: EdgeInsets.all(1),
    cardPadding: EdgeInsets.all(4),
    tileBorderRadius: BorderRadius.all(Radius.circular(4)),
    tileElevation: 1,
    animationDuration: Duration(milliseconds: 150),
  );

  /// Create from core entity configuration
  factory HeatmapConfiguration.fromEntity(
    HeatmapConfigurationEntity entity, {
    bool? showSubCards,
    bool? showLegend,
    bool? showHeader,
    bool? showFooter,
    double? minTileWidth,
    double? maxTileWidth,
    double? minTileHeight,
    double? maxTileHeight,
    EdgeInsets? tilePadding,
    EdgeInsets? tileMargin,
    EdgeInsets? cardPadding,
    BorderRadius? tileBorderRadius,
    double? tileElevation,
    Duration? animationDuration,
  }) => HeatmapConfiguration(
    showPerformance: entity.showPerformance,
    showWeightage: entity.showWeightage,
    showValue: entity.showValue,
    layout: entity.layout,
    colorScheme: entity.colorScheme,
    defaultSorting: entity.defaultSorting,
    enabledFilters: entity.enabledFilters,
    customSettings: entity.customSettings,
    showSubCards: showSubCards ?? true,
    showLegend: showLegend ?? true,
    showHeader: showHeader ?? true,
    showFooter: showFooter ?? false,
    minTileWidth: minTileWidth,
    maxTileWidth: maxTileWidth,
    minTileHeight: minTileHeight,
    maxTileHeight: maxTileHeight,
    tilePadding: tilePadding,
    tileMargin: tileMargin,
    cardPadding: cardPadding,
    tileBorderRadius: tileBorderRadius,
    tileElevation: tileElevation,
    animationDuration: animationDuration,
  );
  final bool showSubCards;
  final bool showLegend;
  final bool showHeader;
  final bool showFooter;
  final double? minTileWidth;
  final double? maxTileWidth;
  final double? minTileHeight;
  final double? maxTileHeight;
  final EdgeInsets? tilePadding;
  final EdgeInsets? tileMargin;
  final EdgeInsets? cardPadding;
  final BorderRadius? tileBorderRadius;
  final double? tileElevation;
  final Duration? animationDuration;

  /// Convert to core entity
  HeatmapConfigurationEntity toEntity() => HeatmapConfigurationEntity(
    showPerformance: showPerformance,
    showWeightage: showWeightage,
    showValue: showValue,
    layout: layout,
    colorScheme: colorScheme,
    defaultSorting: defaultSorting,
    enabledFilters: enabledFilters,
    customSettings: customSettings,
  );

  @override
  HeatmapConfiguration copyWith({
    bool? showPerformance,
    bool? showWeightage,
    bool? showValue,
    HeatmapLayoutType? layout,
    HeatmapColorSchemeType? colorScheme,
    HeatmapSortingType? defaultSorting,
    List<HeatmapFilterType>? enabledFilters,
    Map<String, dynamic>? customSettings,
    bool? showSubCards,
    bool? showLegend,
    bool? showHeader,
    bool? showFooter,
    double? minTileWidth,
    double? maxTileWidth,
    double? minTileHeight,
    double? maxTileHeight,
    EdgeInsets? tilePadding,
    EdgeInsets? tileMargin,
    EdgeInsets? cardPadding,
    BorderRadius? tileBorderRadius,
    double? tileElevation,
    Duration? animationDuration,
  }) => HeatmapConfiguration(
    showPerformance: showPerformance ?? this.showPerformance,
    showWeightage: showWeightage ?? this.showWeightage,
    showValue: showValue ?? this.showValue,
    layout: layout ?? this.layout,
    colorScheme: colorScheme ?? this.colorScheme,
    defaultSorting: defaultSorting ?? this.defaultSorting,
    enabledFilters: enabledFilters ?? this.enabledFilters,
    customSettings: customSettings ?? this.customSettings,
    showSubCards: showSubCards ?? this.showSubCards,
    showLegend: showLegend ?? this.showLegend,
    showHeader: showHeader ?? this.showHeader,
    showFooter: showFooter ?? this.showFooter,
    minTileWidth: minTileWidth ?? this.minTileWidth,
    maxTileWidth: maxTileWidth ?? this.maxTileWidth,
    minTileHeight: minTileHeight ?? this.minTileHeight,
    maxTileHeight: maxTileHeight ?? this.maxTileHeight,
    tilePadding: tilePadding ?? this.tilePadding,
    tileMargin: tileMargin ?? this.tileMargin,
    cardPadding: cardPadding ?? this.cardPadding,
    tileBorderRadius: tileBorderRadius ?? this.tileBorderRadius,
    tileElevation: tileElevation ?? this.tileElevation,
    animationDuration: animationDuration ?? this.animationDuration,
  );
}
