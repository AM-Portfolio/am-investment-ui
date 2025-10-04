import 'package:flutter/material.dart';

import '../../../core/app_logic/domain/entities/heatmap/heatmap_entities.dart';
import '../../../core/utils/logger.dart';
import '../../widgets/heatmap/heatmap_config.dart' as ui_config;
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
    required ui_config.HeatmapConfig configuration,
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
  final ui_config.HeatmapConfig configuration;
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
    ui_config.HeatmapConfig? configuration,
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
