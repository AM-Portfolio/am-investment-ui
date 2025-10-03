// Export the new UI-specific models (these supersede the old ones)
export 'heatmap/heatmap_tile_data.dart';
export 'heatmap/heatmap_ui_data.dart';

// Hide the old models that have been replaced
export 'heatmap/heatmap_data.dart'
    hide HeatmapTileData, HeatmapData, HeatmapConfiguration;
