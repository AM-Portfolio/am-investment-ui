import 'dart:convert';

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

  /// Convert current HeatmapData object to JSON string
  String toJsonString() {
    try {
      final jsonData = {
        'id': id,
        'title': title,
        'subtitle': subtitle,
        'tilesCount': tiles.length,
        'timestamp': DateTime.now().toIso8601String(),
        'tiles': uiTiles
            .map(
              (tile) => {
                'id': tile.id,
                'name': tile.name,
                'displayName': tile.displayName,
                'weightage': double.parse(tile.weightage.toStringAsFixed(4)),
                'performance': double.parse(
                  tile.performance.toStringAsFixed(4),
                ),
                'value': tile.value != null
                    ? double.parse(tile.value!.toStringAsFixed(2))
                    : null,
                'hasChildren': tile.hasChildren,
                'childrenCount': tile.children?.length ?? 0,
                'children': tile.children
                    ?.map(
                      (child) => {
                        'id': child.id,
                        'name': child.name,
                        'displayName': child.displayName,
                        'weightage': double.parse(
                          child.weightage.toStringAsFixed(4),
                        ),
                        'performance': double.parse(
                          child.performance.toStringAsFixed(4),
                        ),
                        'value': child.value != null
                            ? double.parse(child.value!.toStringAsFixed(2))
                            : null,
                        'parentId': tile.id,
                        'metadata': child.metadata ?? {},
                      },
                    )
                    .toList(),
                'metadata': tile.metadata ?? {},
              },
            )
            .toList(),
        'metadata': {
          'dataSource': metadata.dataSource,
          'lastUpdated': metadata.lastUpdated.toIso8601String(),
          'additionalInfo': metadata.additionalInfo ?? {},
          'tags': metadata.tags ?? [],
        },
        'configuration': {
          'layoutType': configuration.layoutType.toString(),
          'showSubCards': configuration.showSubCards,
          'showLegend': configuration.showLegend,
          'compactView': configuration.compactView,
          'showTitle': configuration.showTitle,
          'enableTileInteraction': configuration.enableTileInteraction,
          'enableSelectorInteraction': configuration.enableSelectorInteraction,
          'showTimeFrameSelector': configuration.showTimeFrameSelector,
          'showMetricSelector': configuration.showMetricSelector,
          'showSectorSelector': configuration.showSectorSelector,
          'showMarketCapSelector': configuration.showMarketCapSelector,
          'accentColor': configuration.accentColor?.toString(),
          'customTitle': configuration.customTitle,
        },
        'statistics': {
          'totalTiles': tiles.length,
          'totalChildren': uiTiles.fold<int>(
            0,
            (sum, tile) => sum + (tile.children?.length ?? 0),
          ),
          'hierarchicalTiles': uiTiles.where((tile) => tile.hasChildren).length,
          'averageWeightage': uiTiles.isNotEmpty
              ? double.parse(
                  (uiTiles.fold(0.0, (sum, tile) => sum + tile.weightage) /
                          uiTiles.length)
                      .toStringAsFixed(4),
                )
              : 0.0,
          'averagePerformance': uiTiles.isNotEmpty
              ? double.parse(
                  (uiTiles.fold(0.0, (sum, tile) => sum + tile.performance) /
                          uiTiles.length)
                      .toStringAsFixed(4),
                )
              : 0.0,
          'bestPerformer': uiTiles.isNotEmpty
              ? uiTiles
                    .reduce((a, b) => a.performance > b.performance ? a : b)
                    .name
              : null,
          'worstPerformer': uiTiles.isNotEmpty
              ? uiTiles
                    .reduce((a, b) => a.performance < b.performance ? a : b)
                    .name
              : null,
          'totalValue': uiTiles.fold(
            0.0,
            (sum, tile) => sum + (tile.value ?? 0.0),
          ),
          'positivePerformers': uiTiles
              .where((tile) => tile.performance > 0)
              .length,
          'negativePerformers': uiTiles
              .where((tile) => tile.performance < 0)
              .length,
          'neutralPerformers': uiTiles
              .where((tile) => tile.performance == 0)
              .length,
        },
        'ui': {
          'hasCustomHeader': customHeader != null,
          'hasCustomFooter': customFooter != null,
          'hasRefreshCallback': onRefresh != null,
          'hasTileInteractionCallback': onTileInteraction != null,
        },
      };

      final jsonString = jsonEncode(jsonData);

      AppLogger.debug(
        'HeatmapData converted to JSON string (${jsonString.length} characters)',
        tag: 'HeatmapData.JSON',
      );

      return jsonString;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Error converting HeatmapData to JSON string: $e',
        tag: 'HeatmapData.JSON.Error',
        error: e,
        stackTrace: stackTrace,
      );

      // Return minimal JSON with error info
      return jsonEncode({
        'error': 'Failed to serialize HeatmapData',
        'errorMessage': e.toString(),
        'id': id,
        'title': title,
        'tilesCount': tiles.length,
        'timestamp': DateTime.now().toIso8601String(),
      });
    }
  }

  /// Convert current HeatmapData object to a pretty-formatted JSON string
  String toPrettyJsonString() {
    try {
      final jsonString = toJsonString();
      final jsonData = jsonDecode(jsonString);
      const encoder = JsonEncoder.withIndent('  ');
      final prettyString = encoder.convert(jsonData);

      AppLogger.debug(
        'HeatmapData converted to pretty JSON string (${prettyString.length} characters)',
        tag: 'HeatmapData.PrettyJSON',
      );

      return prettyString;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Error converting HeatmapData to pretty JSON string: $e',
        tag: 'HeatmapData.PrettyJSON.Error',
        error: e,
        stackTrace: stackTrace,
      );

      // Fallback to regular JSON string
      return toJsonString();
    }
  }

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
