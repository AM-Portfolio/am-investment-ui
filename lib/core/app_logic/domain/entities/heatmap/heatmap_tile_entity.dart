/// Core heatmap tile entity - domain model for individual heatmap data points
/// This is platform-agnostic and contains only business logic data
/// Supports hierarchical structure with children tiles
class HeatmapTileEntity {
  const HeatmapTileEntity({
    required this.id,
    required this.name,
    required this.displayName,
    required this.weightage,
    required this.performance,
    this.value,
    this.metadata,
    this.children,
  });

  /// Create from map for deserialization
  factory HeatmapTileEntity.fromMap(Map<String, dynamic> map) =>
      HeatmapTileEntity(
        id: map['id'] ?? '',
        name: map['name'] ?? '',
        displayName: map['displayName'] ?? '',
        weightage: map['weightage']?.toDouble() ?? 0.0,
        performance: map['performance']?.toDouble() ?? 0.0,
        value: map['value']?.toDouble(),
        metadata: map['metadata'],
        children: map['children'] != null
            ? (map['children'] as List)
                  .map((child) => HeatmapTileEntity.fromMap(child))
                  .toList()
            : null,
      );
  final String id;
  final String name;
  final String displayName;
  final double weightage;
  final double performance;
  final double? value;
  final Map<String, dynamic>? metadata;
  final List<HeatmapTileEntity>? children;

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

  /// Helper getter to check if this tile has children
  bool get hasChildren => children != null && children!.isNotEmpty;

  /// Helper getter to get total number of children (recursive)
  int get totalChildrenCount {
    if (!hasChildren) return 0;
    return children!.fold(
      0,
      (sum, child) => sum + 1 + child.totalChildrenCount,
    );
  }

  /// Create a copy with modified properties
  HeatmapTileEntity copyWith({
    String? id,
    String? name,
    String? displayName,
    double? weightage,
    double? performance,
    double? value,
    Map<String, dynamic>? metadata,
    List<HeatmapTileEntity>? children,
  }) => HeatmapTileEntity(
    id: id ?? this.id,
    name: name ?? this.name,
    displayName: displayName ?? this.displayName,
    weightage: weightage ?? this.weightage,
    performance: performance ?? this.performance,
    value: value ?? this.value,
    metadata: metadata ?? this.metadata,
    children: children ?? this.children,
  );

  /// Convert to map for serialization
  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'displayName': displayName,
    'weightage': weightage,
    'performance': performance,
    'value': value,
    'metadata': metadata,
    'children': children?.map((child) => child.toMap()).toList(),
  };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is HeatmapTileEntity &&
        other.id == id &&
        other.name == name &&
        other.displayName == displayName &&
        other.weightage == weightage &&
        other.performance == performance &&
        other.value == value;
  }

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      displayName.hashCode ^
      weightage.hashCode ^
      performance.hashCode ^
      value.hashCode;

  @override
  String toString() =>
      'HeatmapTileEntity(id: $id, name: $name, displayName: $displayName, weightage: $weightage, performance: $performance, value: $value)';
}
