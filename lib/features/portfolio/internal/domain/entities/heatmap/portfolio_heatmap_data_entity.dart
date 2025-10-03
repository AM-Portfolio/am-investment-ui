import '../../../../../../core/app_logic/domain/entities/heatmap/heatmap_entities.dart';
import 'portfolio_heatmap_tile_entity.dart';

/// Portfolio-specific heatmap data entity
/// Contains portfolio-specific metadata and grouping capabilities
class PortfolioHeatmapDataEntity extends HeatmapDataEntity {
  final String portfolioId;
  final String portfolioName;
  final String userId;
  final double totalPortfolioValue;
  final double totalDayChange;
  final double totalDayChangePercent;
  final Map<String, double> sectorAllocations;
  final Map<String, double> marketCapAllocations;
  final String baseCurrency;

  const PortfolioHeatmapDataEntity({
    required super.id,
    required super.title,
    super.subtitle,
    required List<PortfolioHeatmapTileEntity> tiles,
    required super.metadata,
    required this.portfolioId,
    required this.portfolioName,
    required this.userId,
    required this.totalPortfolioValue,
    required this.totalDayChange,
    required this.totalDayChangePercent,
    required this.sectorAllocations,
    required this.marketCapAllocations,
    required this.baseCurrency,
  }) : super(tiles: tiles);

  /// Create from core entity with portfolio-specific data
  factory PortfolioHeatmapDataEntity.fromEntity(
    HeatmapDataEntity entity, {
    required String portfolioId,
    required String portfolioName,
    required String userId,
    required double totalPortfolioValue,
    required double totalDayChange,
    required double totalDayChangePercent,
    required Map<String, double> sectorAllocations,
    required Map<String, double> marketCapAllocations,
    required String baseCurrency,
    required List<PortfolioHeatmapTileEntity> portfolioTiles,
  }) {
    return PortfolioHeatmapDataEntity(
      id: entity.id,
      title: entity.title,
      subtitle: entity.subtitle,
      tiles: portfolioTiles,
      metadata: entity.metadata,
      portfolioId: portfolioId,
      portfolioName: portfolioName,
      userId: userId,
      totalPortfolioValue: totalPortfolioValue,
      totalDayChange: totalDayChange,
      totalDayChangePercent: totalDayChangePercent,
      sectorAllocations: sectorAllocations,
      marketCapAllocations: marketCapAllocations,
      baseCurrency: baseCurrency,
    );
  }

  /// Get tiles as portfolio-specific tiles
  List<PortfolioHeatmapTileEntity> get portfolioTiles =>
      tiles.cast<PortfolioHeatmapTileEntity>();

  /// Get tiles grouped by sector
  Map<String, List<PortfolioHeatmapTileEntity>> get tilesBySector {
    final Map<String, List<PortfolioHeatmapTileEntity>> grouped = {};

    for (final tile in portfolioTiles) {
      final sector = tile.sector ?? 'Other';
      grouped.putIfAbsent(sector, () => []);
      grouped[sector]!.add(tile);
    }

    return grouped;
  }

  /// Get tiles grouped by market cap
  Map<MarketCapCategory, List<PortfolioHeatmapTileEntity>>
  get tilesByMarketCap {
    final Map<MarketCapCategory, List<PortfolioHeatmapTileEntity>> grouped = {};

    for (final tile in portfolioTiles) {
      final marketCap = tile.marketCapCategory;
      grouped.putIfAbsent(marketCap, () => []);
      grouped[marketCap]!.add(tile);
    }

    return grouped;
  }

  /// Get top performers by day change
  List<PortfolioHeatmapTileEntity> getTopDayPerformers(int count) {
    final sorted = List<PortfolioHeatmapTileEntity>.from(portfolioTiles);
    sorted.sort(
      (a, b) => (b.dayChangePercent ?? 0).compareTo(a.dayChangePercent ?? 0),
    );
    return sorted.take(count).toList();
  }

  /// Get worst performers by day change
  List<PortfolioHeatmapTileEntity> getBottomDayPerformers(int count) {
    final sorted = List<PortfolioHeatmapTileEntity>.from(portfolioTiles);
    sorted.sort(
      (a, b) => (a.dayChangePercent ?? 0).compareTo(b.dayChangePercent ?? 0),
    );
    return sorted.take(count).toList();
  }

  /// Get largest holdings by total value
  List<PortfolioHeatmapTileEntity> getLargestHoldings(int count) {
    final sorted = List<PortfolioHeatmapTileEntity>.from(portfolioTiles);
    sorted.sort((a, b) => (b.totalValue ?? 0).compareTo(a.totalValue ?? 0));
    return sorted.take(count).toList();
  }

  /// Filter tiles by sector
  List<PortfolioHeatmapTileEntity> filterBySector(String sector) {
    return portfolioTiles
        .where((tile) => tile.sector?.toLowerCase() == sector.toLowerCase())
        .toList();
  }

  /// Filter tiles by market cap category
  List<PortfolioHeatmapTileEntity> filterByMarketCap(
    MarketCapCategory category,
  ) {
    return portfolioTiles
        .where((tile) => tile.marketCapCategory == category)
        .toList();
  }

  /// Get formatted total portfolio value
  String get formattedTotalValue {
    final currencySymbol = _getCurrencySymbol();
    return '$currencySymbol${totalPortfolioValue.toStringAsFixed(2)}';
  }

  /// Get formatted total day change
  String get formattedTotalDayChange {
    final currencySymbol = _getCurrencySymbol();
    final sign = totalDayChange >= 0 ? '+' : '';
    return '$sign$currencySymbol${totalDayChange.toStringAsFixed(2)}';
  }

  /// Get formatted total day change percentage
  String get formattedTotalDayChangePercent {
    final sign = totalDayChangePercent >= 0 ? '+' : '';
    return '$sign${totalDayChangePercent.toStringAsFixed(2)}%';
  }

  /// Check if portfolio has positive day change
  bool get isDayChangePositive => totalDayChange >= 0;

  /// Check if portfolio has negative day change
  bool get isDayChangeNegative => totalDayChange < 0;

  /// Helper to get currency symbol
  String _getCurrencySymbol() {
    switch (baseCurrency.toUpperCase()) {
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'JPY':
        return '¥';
      default:
        return '$baseCurrency ';
    }
  }

  /// Calculate diversification score (0-1, higher is more diversified)
  double get diversificationScore {
    if (sectorAllocations.isEmpty) return 0.0;

    // Calculate Herfindahl-Hirschman Index (HHI) and convert to diversification score
    double hhi = 0.0;
    for (final allocation in sectorAllocations.values) {
      final marketShare = allocation / 100; // Convert percentage to decimal
      hhi += marketShare * marketShare;
    }

    // Convert HHI to diversification score (1 - normalized HHI)
    final maxHHI = 1.0; // Maximum HHI when fully concentrated
    final normalizedHHI = hhi / maxHHI;
    return 1.0 - normalizedHHI;
  }

  /// Get the dominant sector (highest allocation)
  String get dominantSector {
    if (sectorAllocations.isEmpty) return 'Unknown';

    var maxAllocation = 0.0;
    var dominantSector = 'Unknown';

    sectorAllocations.forEach((sector, allocation) {
      if (allocation > maxAllocation) {
        maxAllocation = allocation;
        dominantSector = sector;
      }
    });

    return dominantSector;
  }

  @override
  PortfolioHeatmapDataEntity copyWith({
    String? id,
    String? title,
    String? subtitle,
    List<PortfolioHeatmapTileEntity>? tiles,
    HeatmapMetadata? metadata,
    String? portfolioId,
    String? portfolioName,
    String? userId,
    double? totalPortfolioValue,
    double? totalDayChange,
    double? totalDayChangePercent,
    Map<String, double>? sectorAllocations,
    Map<String, double>? marketCapAllocations,
    String? baseCurrency,
  }) {
    return PortfolioHeatmapDataEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      tiles: tiles ?? portfolioTiles,
      metadata: metadata ?? this.metadata,
      portfolioId: portfolioId ?? this.portfolioId,
      portfolioName: portfolioName ?? this.portfolioName,
      userId: userId ?? this.userId,
      totalPortfolioValue: totalPortfolioValue ?? this.totalPortfolioValue,
      totalDayChange: totalDayChange ?? this.totalDayChange,
      totalDayChangePercent:
          totalDayChangePercent ?? this.totalDayChangePercent,
      sectorAllocations: sectorAllocations ?? this.sectorAllocations,
      marketCapAllocations: marketCapAllocations ?? this.marketCapAllocations,
      baseCurrency: baseCurrency ?? this.baseCurrency,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map.addAll({
      'portfolioId': portfolioId,
      'portfolioName': portfolioName,
      'userId': userId,
      'totalPortfolioValue': totalPortfolioValue,
      'totalDayChange': totalDayChange,
      'totalDayChangePercent': totalDayChangePercent,
      'sectorAllocations': sectorAllocations,
      'marketCapAllocations': marketCapAllocations,
      'baseCurrency': baseCurrency,
    });
    return map;
  }

  factory PortfolioHeatmapDataEntity.fromMap(Map<String, dynamic> map) {
    final portfolioTiles =
        (map['tiles'] as List<dynamic>?)
            ?.map((tileMap) => PortfolioHeatmapTileEntity.fromMap(tileMap))
            .toList() ??
        <PortfolioHeatmapTileEntity>[];

    return PortfolioHeatmapDataEntity(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      subtitle: map['subtitle'],
      tiles: portfolioTiles,
      metadata: HeatmapMetadata.fromMap(map['metadata'] ?? {}),
      portfolioId: map['portfolioId'] ?? '',
      portfolioName: map['portfolioName'] ?? '',
      userId: map['userId'] ?? '',
      totalPortfolioValue: map['totalPortfolioValue']?.toDouble() ?? 0.0,
      totalDayChange: map['totalDayChange']?.toDouble() ?? 0.0,
      totalDayChangePercent: map['totalDayChangePercent']?.toDouble() ?? 0.0,
      sectorAllocations: Map<String, double>.from(
        map['sectorAllocations'] ?? {},
      ),
      marketCapAllocations: Map<String, double>.from(
        map['marketCapAllocations'] ?? {},
      ),
      baseCurrency: map['baseCurrency'] ?? 'USD',
    );
  }

  @override
  String toString() {
    return 'PortfolioHeatmapDataEntity(portfolioId: $portfolioId, portfolioName: $portfolioName, tiles: ${tiles.length}, totalValue: $formattedTotalValue)';
  }
}
