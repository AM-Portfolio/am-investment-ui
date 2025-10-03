/// Core heatmap tile entity - domain model for individual heatmap data points
/// This is platform-agnostic and contains only business logic data
class HeatmapTileEntity {
  final String id;
  final String name;
  final String displayName;
  final double weightage;
  final double performance;
  final double? value;
  final Map<String, dynamic>? metadata;

  const HeatmapTileEntity({
    required this.id,
    required this.name,
    required this.displayName,
    required this.weightage,
    required this.performance,
    this.value,
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

  /// Create a copy with modified properties
  HeatmapTileEntity copyWith({
    String? id,
    String? name,
    String? displayName,
    double? weightage,
    double? performance,
    double? value,
    Map<String, dynamic>? metadata,
  }) {
    return HeatmapTileEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      displayName: displayName ?? this.displayName,
      weightage: weightage ?? this.weightage,
      performance: performance ?? this.performance,
      value: value ?? this.value,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Convert to map for serialization
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'displayName': displayName,
      'weightage': weightage,
      'performance': performance,
      'value': value,
      'metadata': metadata,
    };
  }

  /// Create from map for deserialization
  factory HeatmapTileEntity.fromMap(Map<String, dynamic> map) {
    return HeatmapTileEntity(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      displayName: map['displayName'] ?? '',
      weightage: map['weightage']?.toDouble() ?? 0.0,
      performance: map['performance']?.toDouble() ?? 0.0,
      value: map['value']?.toDouble(),
      metadata: map['metadata'],
    );
  }

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
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        displayName.hashCode ^
        weightage.hashCode ^
        performance.hashCode ^
        value.hashCode;
  }

  @override
  String toString() {
    return 'HeatmapTileEntity(id: $id, name: $name, displayName: $displayName, weightage: $weightage, performance: $performance, value: $value)';
  }
}
