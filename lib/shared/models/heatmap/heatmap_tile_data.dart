import 'package:flutter/material.dart';
import '../../../core/app_logic/domain/entities/heatmap/heatmap_entities.dart';
import '../../../core/utils/logger.dart';

/// UI-specific heatmap tile data that extends the core entity with display properties
class HeatmapTileData extends HeatmapTileEntity {
  final Color? customColor;
  final IconData? icon;
  final String? imageUrl;
  final VoidCallback? onTap;
  final Map<String, Widget>? customWidgets;

  HeatmapTileData({
    required super.id,
    required super.name,
    required super.displayName,
    required super.weightage,
    required super.performance,
    super.value,
    super.metadata,
    this.customColor,
    this.icon,
    this.imageUrl,
    this.onTap,
    this.customWidgets,
  }) {
    AppLogger.debug(
      'HeatmapTileData created: id=$id, name=$name, performance=$performance',
      tag: 'HeatmapTileData',
    );
  }

  /// Create from core entity
  factory HeatmapTileData.fromEntity(
    HeatmapTileEntity entity, {
    Color? customColor,
    IconData? icon,
    String? imageUrl,
    VoidCallback? onTap,
    Map<String, Widget>? customWidgets,
  }) {
    AppLogger.debug(
      'Converting HeatmapTileEntity to HeatmapTileData: ${entity.id}',
      tag: 'HeatmapTileData',
    );

    return HeatmapTileData(
      id: entity.id,
      name: entity.name,
      displayName: entity.displayName,
      weightage: entity.weightage,
      performance: entity.performance,
      value: entity.value,
      metadata: entity.metadata,
      customColor: customColor,
      icon: icon,
      imageUrl: imageUrl,
      onTap: onTap,
      customWidgets: customWidgets,
    );
  }

  /// Convert to core entity
  HeatmapTileEntity toEntity() {
    return HeatmapTileEntity(
      id: id,
      name: name,
      displayName: displayName,
      weightage: weightage,
      performance: performance,
      value: value,
      metadata: metadata,
    );
  }

  /// Get display color based on performance and configuration
  Color getDisplayColor(
    BuildContext context, {
    HeatmapColorSchemeType? scheme,
  }) {
    if (customColor != null) return customColor!;

    switch (scheme ?? HeatmapColorSchemeType.performance) {
      case HeatmapColorSchemeType.performance:
        if (isPositive) {
          return Colors.green.shade400;
        } else if (isNegative) {
          return Colors.red.shade400;
        } else {
          return Colors.grey.shade400;
        }
      case HeatmapColorSchemeType.weightage:
        final intensity = (weightage / 100).clamp(0.0, 1.0);
        return Colors.blue.withOpacity(0.3 + (intensity * 0.7));
      case HeatmapColorSchemeType.neutral:
        return Theme.of(context).primaryColor.withOpacity(0.6);
      case HeatmapColorSchemeType.custom:
        return customColor ?? Colors.grey.shade400;
    }
  }

  /// Get text color for contrast
  Color getTextColor(BuildContext context, {HeatmapColorSchemeType? scheme}) {
    final backgroundColor = getDisplayColor(context, scheme: scheme);
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black87 : Colors.white;
  }

  @override
  HeatmapTileData copyWith({
    String? id,
    String? name,
    String? displayName,
    double? weightage,
    double? performance,
    double? value,
    Map<String, dynamic>? metadata,
    Color? customColor,
    IconData? icon,
    String? imageUrl,
    VoidCallback? onTap,
    Map<String, Widget>? customWidgets,
  }) {
    return HeatmapTileData(
      id: id ?? this.id,
      name: name ?? this.name,
      displayName: displayName ?? this.displayName,
      weightage: weightage ?? this.weightage,
      performance: performance ?? this.performance,
      value: value ?? this.value,
      metadata: metadata ?? this.metadata,
      customColor: customColor ?? this.customColor,
      icon: icon ?? this.icon,
      imageUrl: imageUrl ?? this.imageUrl,
      onTap: onTap ?? this.onTap,
      customWidgets: customWidgets ?? this.customWidgets,
    );
  }
}
