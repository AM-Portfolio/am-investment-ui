import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../core/app_logic/domain/entities/heatmap/heatmap_entities.dart';
import '../../../../core/utils/logger.dart';
import '../../../models/heatmap/heatmap_tile_data.dart';
import '../../../models/heatmap/heatmap_ui_data.dart';
import '../../selectors/heatmap_layout_selector.dart';
import '../../selectors/sector_selector.dart';
import '../heatmap_config.dart' as ui_config;

/// Core logic for heatmap display functionality
/// Handles state management, data processing, and business logic independent of UI
class HeatmapDisplayCore extends ChangeNotifier {
  HeatmapDisplayCore({
    HeatmapData? initialData,
    bool initialIsLoading = false,
    String? initialError,
    HeatmapLayoutType initialLayout = HeatmapLayoutType.treemap,
    SectorType? initialSelectedSector,
    this.onTilePressed,
    this.onLayoutChanged,
    this.onSectorChanged,
    this.onDataChanged,
    this.onLoadingStateChanged,
    this.onErrorChanged,
  }) {
    _data = initialData ?? _createEmptyHeatmapData();
    _isLoading = initialIsLoading;
    _error = initialError;
    _layout = initialLayout;
    _selectedSector = initialSelectedSector;

    AppLogger.debug(
      'HeatmapDisplayCore: initialized with ${_data.tiles.length} tiles',
      tag: 'Heatmap.Display.Core',
    );
  }

  // Private state
  late HeatmapData _data;
  late bool _isLoading;
  String? _error;
  late HeatmapLayoutType _layout;
  SectorType? _selectedSector;

  // Callbacks
  final VoidCallback? onTilePressed;
  final ValueChanged<HeatmapLayoutType>? onLayoutChanged;
  final ValueChanged<SectorType?>? onSectorChanged;
  final ValueChanged<HeatmapData>? onDataChanged;
  final ValueChanged<bool>? onLoadingStateChanged;
  final ValueChanged<String?>? onErrorChanged;

  // Getters for current state
  HeatmapData get data => _data;
  bool get isLoading => _isLoading;
  String? get error => _error;
  HeatmapLayoutType get layout => _layout;
  SectorType? get selectedSector => _selectedSector;

  // Derived state
  bool get hasData => _data.hasData && !_isLoading && _error == null;
  bool get hasError => _error != null;
  bool get isEmpty => !_data.hasData && !_isLoading && _error == null;

  List<HeatmapTileData> get visibleTiles {
    if (_selectedSector == null || _selectedSector == SectorType.all) {
      return _data.tiles
          .map(
            (tile) => tile is HeatmapTileData
                ? tile
                : HeatmapTileData.fromEntity(tile),
          )
          .toList();
    }

    // Filter tiles by selected sector
    return _data.tiles
        .map(
          (tile) =>
              tile is HeatmapTileData ? tile : HeatmapTileData.fromEntity(tile),
        )
        .where((tile) {
          // Add sector filtering logic here based on your tile structure
          // This is a placeholder - adjust based on your actual tile data structure
          return true; // For now, return all tiles
        })
        .toList();
  }

  int get tileCount => visibleTiles.length;

  // State management methods
  void updateData(HeatmapData newData) {
    if (_data != newData) {
      _data = newData;
      _logTileData();
      onDataChanged?.call(newData);
      notifyListeners();

      AppLogger.debug(
        'HeatmapDisplayCore: data updated with ${newData.tiles.length} tiles',
        tag: 'Heatmap.Display.Core',
      );
    }
  }

  void setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      onLoadingStateChanged?.call(loading);
      notifyListeners();

      AppLogger.debug(
        'HeatmapDisplayCore: loading state changed to $loading',
        tag: 'Heatmap.Display.Core',
      );
    }
  }

  void setError(String? errorMessage) {
    if (_error != errorMessage) {
      _error = errorMessage;
      onErrorChanged?.call(errorMessage);
      notifyListeners();

      if (errorMessage != null) {
        AppLogger.error(
          'HeatmapDisplayCore: error set - $errorMessage',
          tag: 'Heatmap.Display.Core',
        );
      } else {
        AppLogger.debug(
          'HeatmapDisplayCore: error cleared',
          tag: 'Heatmap.Display.Core',
        );
      }
    }
  }

  void setLayout(HeatmapLayoutType newLayout) {
    if (_layout != newLayout) {
      _layout = newLayout;
      onLayoutChanged?.call(newLayout);
      notifyListeners();

      AppLogger.debug(
        'HeatmapDisplayCore: layout changed to $newLayout',
        tag: 'Heatmap.Display.Core',
      );
    }
  }

  void setSelectedSector(SectorType? sector) {
    if (_selectedSector != sector) {
      _selectedSector = sector;
      onSectorChanged?.call(sector);
      notifyListeners();

      AppLogger.debug(
        'HeatmapDisplayCore: selected sector changed to $sector',
        tag: 'Heatmap.Display.Core',
      );
    }
  }

  // Convenience methods
  void refresh() {
    setError(null);
    setLoading(true);
    // Note: Actual data refresh should be handled by the consumer
    // This method just sets the appropriate states
  }

  void reset() {
    _data = _createEmptyHeatmapData();
    _isLoading = false;
    _error = null;
    _selectedSector = null;
    notifyListeners();

    AppLogger.debug(
      'HeatmapDisplayCore: reset to initial state',
      tag: 'Heatmap.Display.Core',
    );
  }

  /// Creates empty heatmap data for null or empty input
  static HeatmapData _createEmptyHeatmapData() => HeatmapData(
    id: 'empty-heatmap',
    title: 'No Data',
    tiles: const [],
    metadata: HeatmapMetadata(
      dataSource: 'heatmap_display_core',
      lastUpdated: DateTime.now(),
      additionalInfo: const {},
    ),
    configuration: const ui_config.HeatmapConfig(),
  );

  // Tile interaction methods
  void handleTilePressed() {
    onTilePressed?.call();

    AppLogger.debug(
      'HeatmapDisplayCore: tile pressed',
      tag: 'Heatmap.Display.Core',
    );
  }

  // Validation methods
  bool isValidTileIndex(int index) => index >= 0 && index < visibleTiles.length;

  HeatmapTileData? getTileAt(int index) {
    if (isValidTileIndex(index)) {
      return visibleTiles[index];
    }
    return null;
  }

  // Logging and debugging
  void _logTileData() {
    if (_data.tiles.isEmpty) {
      AppLogger.debug(
        'No heatmap tiles available',
        tag: 'Heatmap.Display.Core.Tiles',
      );
      return;
    }

    AppLogger.debug(
      'Heatmap has ${_data.tiles.length} tiles',
      tag: 'Heatmap.Display.Core.Tiles',
    );

    // Log each tile with basic info
    for (var i = 0; i < _data.tiles.length; i++) {
      final tile = _data.tiles[i];
      final uiTile = tile is HeatmapTileData
          ? tile
          : HeatmapTileData.fromEntity(tile);

      final childrenCount = uiTile.children?.length ?? 0;

      AppLogger.debug(
        'Tile ${i + 1}: ${uiTile.name} ($childrenCount children)',
        tag: 'Heatmap.Display.Core.Tiles',
      );
    }
  }

  void logCurrentState() {
    AppLogger.debug(
      'HeatmapDisplayCore State - Data: ${_data.tiles.length} tiles, '
      'Loading: $_isLoading, Error: ${_error ?? "none"}, '
      'Layout: $_layout, Sector: ${_selectedSector ?? "all"}',
      tag: 'Heatmap.Display.Core',
    );
  }

  @override
  void dispose() {
    AppLogger.debug(
      'HeatmapDisplayCore: disposed',
      tag: 'Heatmap.Display.Core',
    );
    super.dispose();
  }
}
