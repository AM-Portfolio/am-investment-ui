/// Heatmap configuration model containing layout, styling and behavior settings
class HeatmapConfiguration {
  final HeatmapLayoutType layout;
  final HeatmapColorSchemeType colorScheme;
  final HeatmapSortingType defaultSorting;
  final bool showLabels;
  final bool showTooltips;
  final double tileSpacing;
  final double cornerRadius;

  const HeatmapConfiguration({
    required this.layout,
    required this.colorScheme,
    required this.defaultSorting,
    this.showLabels = true,
    this.showTooltips = true,
    this.tileSpacing = 2.0,
    this.cornerRadius = 8.0,
  });

  /// Create a copy with modified properties
  HeatmapConfiguration copyWith({
    HeatmapLayoutType? layout,
    HeatmapColorSchemeType? colorScheme,
    HeatmapSortingType? defaultSorting,
    bool? showLabels,
    bool? showTooltips,
    double? tileSpacing,
    double? cornerRadius,
  }) {
    return HeatmapConfiguration(
      layout: layout ?? this.layout,
      colorScheme: colorScheme ?? this.colorScheme,
      defaultSorting: defaultSorting ?? this.defaultSorting,
      showLabels: showLabels ?? this.showLabels,
      showTooltips: showTooltips ?? this.showTooltips,
      tileSpacing: tileSpacing ?? this.tileSpacing,
      cornerRadius: cornerRadius ?? this.cornerRadius,
    );
  }

  /// Convert to map for serialization
  Map<String, dynamic> toMap() {
    return {
      'layout': layout.name,
      'colorScheme': colorScheme.name,
      'defaultSorting': defaultSorting.name,
      'showLabels': showLabels,
      'showTooltips': showTooltips,
      'tileSpacing': tileSpacing,
      'cornerRadius': cornerRadius,
    };
  }

  /// Create from map for deserialization
  factory HeatmapConfiguration.fromMap(Map<String, dynamic> map) {
    return HeatmapConfiguration(
      layout: HeatmapLayoutType.values.firstWhere(
        (e) => e.name == map['layout'],
        orElse: () => HeatmapLayoutType.grid,
      ),
      colorScheme: HeatmapColorSchemeType.values.firstWhere(
        (e) => e.name == map['colorScheme'],
        orElse: () => HeatmapColorSchemeType.performance,
      ),
      defaultSorting: HeatmapSortingType.values.firstWhere(
        (e) => e.name == map['defaultSorting'],
        orElse: () => HeatmapSortingType.performance,
      ),
      showLabels: map['showLabels'] ?? true,
      showTooltips: map['showTooltips'] ?? true,
      tileSpacing: map['tileSpacing']?.toDouble() ?? 2.0,
      cornerRadius: map['cornerRadius']?.toDouble() ?? 8.0,
    );
  }

  @override
  String toString() {
    return 'HeatmapConfiguration(layout: $layout, colorScheme: $colorScheme, defaultSorting: $defaultSorting, showLabels: $showLabels, showTooltips: $showTooltips, tileSpacing: $tileSpacing, cornerRadius: $cornerRadius)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HeatmapConfiguration &&
        other.layout == layout &&
        other.colorScheme == colorScheme &&
        other.defaultSorting == defaultSorting &&
        other.showLabels == showLabels &&
        other.showTooltips == showTooltips &&
        other.tileSpacing == tileSpacing &&
        other.cornerRadius == cornerRadius;
  }

  @override
  int get hashCode {
    return layout.hashCode ^
        colorScheme.hashCode ^
        defaultSorting.hashCode ^
        showLabels.hashCode ^
        showTooltips.hashCode ^
        tileSpacing.hashCode ^
        cornerRadius.hashCode;
  }
}

/// Enum for heatmap layout types
enum HeatmapLayoutType {
  grid('Grid Layout'),
  treemap('Treemap Layout'),
  squarified('Squarified Layout');

  const HeatmapLayoutType(this.displayName);
  final String displayName;
}

/// Enum for heatmap color scheme types
enum HeatmapColorSchemeType {
  performance('Performance Colors'),
  sector('Sector Colors'),
  marketCap('Market Cap Colors'),
  custom('Custom Colors');

  const HeatmapColorSchemeType(this.displayName);
  final String displayName;
}

/// Enum for heatmap sorting types
enum HeatmapSortingType {
  performance('Performance'),
  marketValue('Market Value'),
  alphabetical('Alphabetical'),
  sector('Sector'),
  marketCap('Market Cap');

  const HeatmapSortingType(this.displayName);
  final String displayName;
}
