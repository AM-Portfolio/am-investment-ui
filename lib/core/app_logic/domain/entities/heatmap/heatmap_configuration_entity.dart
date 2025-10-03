/// Configuration for heatmap behavior and business rules
/// This contains domain-level configuration without UI-specific details
class HeatmapConfigurationEntity {
  final bool showPerformance;
  final bool showWeightage;
  final bool showValue;
  final HeatmapLayoutType layout;
  final HeatmapColorSchemeType colorScheme;
  final HeatmapSortingType defaultSorting;
  final List<HeatmapFilterType> enabledFilters;
  final Map<String, dynamic>? customSettings;

  const HeatmapConfigurationEntity({
    this.showPerformance = true,
    this.showWeightage = true,
    this.showValue = false,
    this.layout = HeatmapLayoutType.treemap,
    this.colorScheme = HeatmapColorSchemeType.performance,
    this.defaultSorting = HeatmapSortingType.performance,
    this.enabledFilters = const [],
    this.customSettings,
  });

  /// Create configuration for mobile view
  factory HeatmapConfigurationEntity.mobile() {
    return const HeatmapConfigurationEntity(
      showPerformance: true,
      showWeightage: true,
      showValue: false, // Hidden on mobile for space
      layout: HeatmapLayoutType.grid,
      colorScheme: HeatmapColorSchemeType.performance,
      defaultSorting: HeatmapSortingType.performance,
      enabledFilters: [
        HeatmapFilterType.performance,
        HeatmapFilterType.weightage,
      ],
    );
  }

  /// Create configuration for web view
  factory HeatmapConfigurationEntity.web() {
    return const HeatmapConfigurationEntity(
      showPerformance: true,
      showWeightage: true,
      showValue: true,
      layout: HeatmapLayoutType.treemap,
      colorScheme: HeatmapColorSchemeType.performance,
      defaultSorting: HeatmapSortingType.performance,
      enabledFilters: [
        HeatmapFilterType.performance,
        HeatmapFilterType.weightage,
        HeatmapFilterType.value,
        HeatmapFilterType.name,
      ],
    );
  }

  /// Create minimal configuration for widgets/previews
  factory HeatmapConfigurationEntity.minimal() {
    return const HeatmapConfigurationEntity(
      showPerformance: true,
      showWeightage: false,
      showValue: false,
      layout: HeatmapLayoutType.grid,
      colorScheme: HeatmapColorSchemeType.performance,
      defaultSorting: HeatmapSortingType.performance,
      enabledFilters: [],
    );
  }

  /// Create a copy with modified properties
  HeatmapConfigurationEntity copyWith({
    bool? showPerformance,
    bool? showWeightage,
    bool? showValue,
    HeatmapLayoutType? layout,
    HeatmapColorSchemeType? colorScheme,
    HeatmapSortingType? defaultSorting,
    List<HeatmapFilterType>? enabledFilters,
    Map<String, dynamic>? customSettings,
  }) {
    return HeatmapConfigurationEntity(
      showPerformance: showPerformance ?? this.showPerformance,
      showWeightage: showWeightage ?? this.showWeightage,
      showValue: showValue ?? this.showValue,
      layout: layout ?? this.layout,
      colorScheme: colorScheme ?? this.colorScheme,
      defaultSorting: defaultSorting ?? this.defaultSorting,
      enabledFilters: enabledFilters ?? this.enabledFilters,
      customSettings: customSettings ?? this.customSettings,
    );
  }

  /// Convert to map for serialization
  Map<String, dynamic> toMap() {
    return {
      'showPerformance': showPerformance,
      'showWeightage': showWeightage,
      'showValue': showValue,
      'layout': layout.name,
      'colorScheme': colorScheme.name,
      'defaultSorting': defaultSorting.name,
      'enabledFilters': enabledFilters.map((f) => f.name).toList(),
      'customSettings': customSettings,
    };
  }

  /// Create from map for deserialization
  factory HeatmapConfigurationEntity.fromMap(Map<String, dynamic> map) {
    return HeatmapConfigurationEntity(
      showPerformance: map['showPerformance'] ?? true,
      showWeightage: map['showWeightage'] ?? true,
      showValue: map['showValue'] ?? false,
      layout: HeatmapLayoutType.values.firstWhere(
        (e) => e.name == map['layout'],
        orElse: () => HeatmapLayoutType.treemap,
      ),
      colorScheme: HeatmapColorSchemeType.values.firstWhere(
        (e) => e.name == map['colorScheme'],
        orElse: () => HeatmapColorSchemeType.performance,
      ),
      defaultSorting: HeatmapSortingType.values.firstWhere(
        (e) => e.name == map['defaultSorting'],
        orElse: () => HeatmapSortingType.performance,
      ),
      enabledFilters:
          (map['enabledFilters'] as List<dynamic>?)
              ?.map(
                (name) => HeatmapFilterType.values.firstWhere(
                  (e) => e.name == name,
                  orElse: () => HeatmapFilterType.performance,
                ),
              )
              .toList() ??
          [],
      customSettings: map['customSettings'],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is HeatmapConfigurationEntity &&
        other.showPerformance == showPerformance &&
        other.showWeightage == showWeightage &&
        other.showValue == showValue &&
        other.layout == layout &&
        other.colorScheme == colorScheme &&
        other.defaultSorting == defaultSorting;
  }

  @override
  int get hashCode {
    return showPerformance.hashCode ^
        showWeightage.hashCode ^
        showValue.hashCode ^
        layout.hashCode ^
        colorScheme.hashCode ^
        defaultSorting.hashCode;
  }

  @override
  String toString() {
    return 'HeatmapConfigurationEntity(layout: $layout, colorScheme: $colorScheme, defaultSorting: $defaultSorting)';
  }
}

/// Layout types for heatmap display
enum HeatmapLayoutType {
  treemap, // Proportional rectangular layout
  grid, // Fixed grid layout
  list, // Linear list layout
}

/// Color scheme options for heatmap
enum HeatmapColorSchemeType {
  performance, // Color based on performance (red/green)
  custom, // Use custom colors from tile data
  weightage, // Color based on weightage intensity
  neutral, // Single neutral color
}

/// Sorting options for heatmap tiles
enum HeatmapSortingType {
  performance, // Sort by performance
  weightage, // Sort by weightage
  value, // Sort by value
  name, // Sort by name alphabetically
  custom, // Custom sorting logic
}

/// Filter options for heatmap tiles
enum HeatmapFilterType {
  performance, // Filter by performance range
  weightage, // Filter by weightage range
  value, // Filter by value range
  name, // Filter by name/text search
  custom, // Custom filter logic
}
