// Export all heatmap models - canonical structure
export 'heatmap/heatmap_ui_data.dart' show HeatmapData, HeatmapConfiguration;
export 'heatmap/heatmap_tile_data.dart' show HeatmapTileData;

// Re-export heatmap_data.dart for compatibility (it now forwards to canonical files)
export 'heatmap/heatmap_data.dart';

// Export core entities for direct access
export '../../core/app_logic/domain/entities/heatmap/heatmap_entities.dart';
