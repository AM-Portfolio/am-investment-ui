import 'heatmap_tile_entity.dart';

/// Core heatmap data entity - domain model for complete heatmap data
/// This is platform-agnostic and contains only business logic
class HeatmapDataEntity {
  const HeatmapDataEntity({
    required this.id,
    required this.title,
    required this.tiles,
    required this.metadata,
    this.subtitle,
  });

  /// Create from map for deserialization
  factory HeatmapDataEntity.fromMap(Map<String, dynamic> map) =>
      HeatmapDataEntity(
        id: map['id'] ?? '',
        title: map['title'] ?? '',
        subtitle: map['subtitle'],
        tiles:
            (map['tiles'] as List<dynamic>?)
                ?.map((tileMap) => HeatmapTileEntity.fromMap(tileMap))
                .toList() ??
            [],
        metadata: HeatmapMetadata.fromMap(map['metadata'] ?? {}),
      );
  final String id;
  final String title;
  final String? subtitle;
  final List<HeatmapTileEntity> tiles;
  final HeatmapMetadata metadata;

  /// Helper getter to check if heatmap has data
  bool get hasData => tiles.isNotEmpty;

  /// Helper getter to get total count of tiles
  int get tileCount => tiles.length;

  /// Get tiles sorted by performance (descending)
  List<HeatmapTileEntity> get tilesByPerformance {
    final sorted = List<HeatmapTileEntity>.from(tiles);
    sorted.sort((a, b) => b.performance.compareTo(a.performance));
    return sorted;
  }

  /// Get tiles sorted by weightage (descending)
  List<HeatmapTileEntity> get tilesByWeightage {
    final sorted = List<HeatmapTileEntity>.from(tiles);
    sorted.sort((a, b) => b.weightage.compareTo(a.weightage));
    return sorted;
  }

  /// Get top performing tiles
  List<HeatmapTileEntity> getTopPerformers(int count) =>
      tilesByPerformance.take(count).toList();

  /// Get worst performing tiles
  List<HeatmapTileEntity> getBottomPerformers(int count) =>
      tilesByPerformance.reversed.take(count).toList();

  /// Filter tiles by performance threshold
  List<HeatmapTileEntity> filterByPerformance({
    double? minPerformance,
    double? maxPerformance,
  }) => tiles.where((tile) {
    if (minPerformance != null && tile.performance < minPerformance) {
      return false;
    }
    if (maxPerformance != null && tile.performance > maxPerformance) {
      return false;
    }
    return true;
  }).toList();

  /// Calculate total weightage of all tiles
  double get totalWeightage =>
      tiles.fold(0.0, (sum, tile) => sum + tile.weightage);

  /// Calculate average performance of all tiles
  double get averagePerformance {
    if (tiles.isEmpty) return 0.0;
    return tiles.fold(0.0, (sum, tile) => sum + tile.performance) /
        tiles.length;
  }

  /// Calculate weighted average performance
  double get weightedAveragePerformance {
    if (tiles.isEmpty) return 0.0;
    final totalWeight = totalWeightage;
    if (totalWeight == 0) return averagePerformance;

    return tiles.fold(
      0.0,
      (sum, tile) => sum + (tile.performance * tile.weightage / totalWeight),
    );
  }

  /// Create a copy with modified properties
  HeatmapDataEntity copyWith({
    String? id,
    String? title,
    String? subtitle,
    List<HeatmapTileEntity>? tiles,
    HeatmapMetadata? metadata,
  }) => HeatmapDataEntity(
    id: id ?? this.id,
    title: title ?? this.title,
    subtitle: subtitle ?? this.subtitle,
    tiles: tiles ?? this.tiles,
    metadata: metadata ?? this.metadata,
  );

  /// Convert to map for serialization
  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'subtitle': subtitle,
    'tiles': tiles.map((tile) => tile.toMap()).toList(),
    'metadata': metadata.toMap(),
  };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is HeatmapDataEntity &&
        other.id == id &&
        other.title == title &&
        other.subtitle == subtitle &&
        other.tiles.length == tiles.length &&
        other.metadata == metadata;
  }

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      subtitle.hashCode ^
      tiles.length.hashCode ^
      metadata.hashCode;

  @override
  String toString() =>
      'HeatmapDataEntity(id: $id, title: $title, tiles: ${tiles.length}, metadata: $metadata)';
}

/// Metadata for heatmap data - contains additional context information
class HeatmapMetadata {
  const HeatmapMetadata({
    required this.lastUpdated,
    required this.dataSource,
    this.additionalInfo,
    this.tags,
  });

  /// Create from map for deserialization
  factory HeatmapMetadata.fromMap(Map<String, dynamic> map) => HeatmapMetadata(
    lastUpdated: DateTime.fromMillisecondsSinceEpoch(
      map['lastUpdated'] ?? DateTime.now().millisecondsSinceEpoch,
    ),
    dataSource: map['dataSource'] ?? '',
    additionalInfo: map['additionalInfo'],
    tags: map['tags']?.cast<String>(),
  );
  final DateTime lastUpdated;
  final String dataSource;
  final Map<String, dynamic>? additionalInfo;
  final List<String>? tags;

  /// Create a copy with modified properties
  HeatmapMetadata copyWith({
    DateTime? lastUpdated,
    String? dataSource,
    Map<String, dynamic>? additionalInfo,
    List<String>? tags,
  }) => HeatmapMetadata(
    lastUpdated: lastUpdated ?? this.lastUpdated,
    dataSource: dataSource ?? this.dataSource,
    additionalInfo: additionalInfo ?? this.additionalInfo,
    tags: tags ?? this.tags,
  );

  /// Convert to map for serialization
  Map<String, dynamic> toMap() => {
    'lastUpdated': lastUpdated.millisecondsSinceEpoch,
    'dataSource': dataSource,
    'additionalInfo': additionalInfo,
    'tags': tags,
  };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is HeatmapMetadata &&
        other.lastUpdated == lastUpdated &&
        other.dataSource == dataSource;
  }

  @override
  int get hashCode => lastUpdated.hashCode ^ dataSource.hashCode;

  @override
  String toString() =>
      'HeatmapMetadata(lastUpdated: $lastUpdated, dataSource: $dataSource, tags: $tags)';
}
