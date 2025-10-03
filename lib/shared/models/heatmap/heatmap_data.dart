// This file now serves as a compatibility layer for legacy imports
// All classes have been moved to their canonical locations:
// - HeatmapData -> heatmap_ui_data.dart
// - HeatmapTileData -> heatmap_tile_data.dart
// - HeatmapConfiguration -> heatmap_ui_data.dart (extends core entity)

// Re-export the canonical classes
export 'heatmap_ui_data.dart' show HeatmapData, HeatmapConfiguration;
export 'heatmap_tile_data.dart' show HeatmapTileData;

// Export core entities for convenience
export '../../../core/app_logic/domain/entities/heatmap/heatmap_entities.dart'
    show HeatmapDataEntity, HeatmapTileEntity, HeatmapConfigurationEntity;
