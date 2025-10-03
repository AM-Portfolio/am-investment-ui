import '../../../../../core/app_logic/domain/entities/heatmap/heatmap_entities.dart';
import '../../../../../shared/models/heatmap.dart';
import '../../domain/entities/heatmap/portfolio_heatmap_entities.dart';
import '../../../../../shared/widgets/selectors/selectors.dart';

/// Converter class to transform portfolio data to heatmap entities
/// Handles the conversion from portfolio holdings to heatmap-compatible data structures
class PortfolioToHeatmapConverter {
  /// Convert portfolio holdings to portfolio heatmap data entity
  static PortfolioHeatmapDataEntity convertHoldingsToHeatmapData({
    required String portfolioId,
    required String portfolioName,
    required String userId,
    required dynamic holdings, // Raw holdings data
    required MetricType metricType,
    required TimeFrame timeFrame,
    SectorType sectorFilter = SectorType.all,
    MarketCapType marketCapFilter = MarketCapType.all,
  }) {
    // Extract tiles from holdings
    final tiles = _extractTilesFromHoldings(
      holdings,
      metricType,
      timeFrame,
      sectorFilter,
      marketCapFilter,
    );

    // Calculate portfolio-level metrics
    final portfolioMetrics = _calculatePortfolioMetrics(tiles);

    // Calculate sector allocations
    final sectorAllocations = _calculateSectorAllocations(tiles);

    // Calculate market cap allocations
    final marketCapAllocations = _calculateMarketCapAllocations(tiles);

    // Create metadata
    final metadata = HeatmapMetadata(
      lastUpdated: DateTime.now(),
      dataSource: 'portfolio_holdings',
      additionalInfo: {
        'metricType': metricType.name,
        'timeFrame': timeFrame.code,
        'sectorFilter': sectorFilter.name,
        'marketCapFilter': marketCapFilter.name,
      },
      tags: ['portfolio', 'holdings', portfolioId],
    );

    return PortfolioHeatmapDataEntity(
      id: '${portfolioId}_heatmap_${metricType.name}_${timeFrame.code}',
      title: _generateTitle(portfolioName, metricType, timeFrame),
      subtitle: _generateSubtitle(tiles.length, portfolioMetrics),
      tiles: tiles,
      metadata: metadata,
      portfolioId: portfolioId,
      portfolioName: portfolioName,
      userId: userId,
      totalPortfolioValue: portfolioMetrics['totalValue'] ?? 0.0,
      totalDayChange: portfolioMetrics['totalDayChange'] ?? 0.0,
      totalDayChangePercent: portfolioMetrics['totalDayChangePercent'] ?? 0.0,
      sectorAllocations: sectorAllocations,
      marketCapAllocations: marketCapAllocations,
      baseCurrency: portfolioMetrics['baseCurrency'] ?? 'USD',
    );
  }

  /// Convert portfolio heatmap data entity to UI heatmap data
  static HeatmapData convertToUIHeatmapData(
    PortfolioHeatmapDataEntity entity, {
    HeatmapConfiguration? configuration,
    Function(HeatmapTileData)? onTileInteraction,
    VoidCallback? onRefresh,
  }) {
    // Convert portfolio tiles to UI tiles
    final uiTiles = entity.portfolioTiles
        .map((tile) => _convertPortfolioTileToUITile(tile))
        .toList();

    // Use provided configuration or create default
    final config = configuration ?? HeatmapConfiguration.web();

    return HeatmapData(
      id: entity.id,
      title: entity.title,
      subtitle: entity.subtitle,
      tiles: uiTiles,
      metadata: entity.metadata,
      configuration: config,
      onTileInteraction: onTileInteraction,
      onRefresh: onRefresh,
    );
  }

  /// Extract tiles from raw holdings data
  static List<PortfolioHeatmapTileEntity> _extractTilesFromHoldings(
    dynamic holdings,
    MetricType metricType,
    TimeFrame timeFrame,
    SectorType sectorFilter,
    MarketCapType marketCapFilter,
  ) {
    final List<PortfolioHeatmapTileEntity> tiles = [];

    // Handle different holdings data structures
    if (holdings is List) {
      for (int i = 0; i < holdings.length; i++) {
        final holding = holdings[i];
        final tile = _createTileFromHolding(holding, metricType, timeFrame);

        // Apply filters
        if (_shouldIncludeTile(tile, sectorFilter, marketCapFilter)) {
          tiles.add(tile);
        }
      }
    } else if (holdings is Map) {
      // Handle map-based holdings data
      holdings.forEach((key, holding) {
        final tile = _createTileFromHolding(holding, metricType, timeFrame);

        if (_shouldIncludeTile(tile, sectorFilter, marketCapFilter)) {
          tiles.add(tile);
        }
      });
    }

    return tiles;
  }

  /// Create a portfolio heatmap tile from holding data
  static PortfolioHeatmapTileEntity _createTileFromHolding(
    dynamic holding,
    MetricType metricType,
    TimeFrame timeFrame,
  ) {
    // Extract basic information
    final symbol = holding['symbol'] ?? holding['ticker'] ?? 'UNKNOWN';
    final name = holding['name'] ?? holding['companyName'] ?? symbol;
    final displayName = holding['displayName'] ?? name;

    // Extract financial data
    final currentPrice = _parseDouble(
      holding['currentPrice'] ?? holding['price'],
    );
    final quantity = _parseDouble(holding['quantity'] ?? holding['shares']);
    final totalValue = currentPrice != null && quantity != null
        ? currentPrice * quantity
        : _parseDouble(holding['marketValue'] ?? holding['totalValue']);

    // Extract performance data based on metric type and time frame
    final performance = _calculatePerformance(holding, metricType, timeFrame);
    final dayChange = _parseDouble(holding['dayChange']);
    final dayChangePercent = _parseDouble(holding['dayChangePercent']);

    // Calculate weightage (will be set later when we have total portfolio value)
    final weightage = 0.0; // Placeholder, calculated in portfolio metrics

    return PortfolioHeatmapTileEntity(
      id: symbol,
      name: name,
      displayName: displayName,
      weightage: weightage,
      performance: performance,
      value: totalValue,
      metadata: {
        'originalHolding': holding,
        'metricType': metricType.name,
        'timeFrame': timeFrame.code,
      },
      symbol: symbol,
      sector: holding['sector'],
      industry: holding['industry'],
      marketCap: holding['marketCap'] ?? holding['marketCapCategory'],
      currentPrice: currentPrice,
      quantity: quantity,
      totalValue: totalValue,
      dayChange: dayChange,
      dayChangePercent: dayChangePercent,
      currency: holding['currency'] ?? 'USD',
      exchange: holding['exchange'],
    );
  }

  /// Calculate performance based on metric type and time frame
  static double _calculatePerformance(
    dynamic holding,
    MetricType metricType,
    TimeFrame timeFrame,
  ) {
    switch (metricType) {
      case MetricType.changePercent:
        return _getChangePercent(holding, timeFrame);
      case MetricType.changeAmount:
        return _getChangeAmount(holding, timeFrame);
      case MetricType.totalReturn:
        return _parseDouble(holding['totalReturn']) ?? 0.0;
      case MetricType.dividendYield:
        return _parseDouble(holding['dividendYield']) ?? 0.0;
      case MetricType.marketValue:
        return _parseDouble(holding['marketValue'] ?? holding['totalValue']) ??
            0.0;
      case MetricType.unrealizedGain:
        return _parseDouble(holding['unrealizedGain']) ?? 0.0;
      case MetricType.realizedGain:
        return _parseDouble(holding['realizedGain']) ?? 0.0;
      case MetricType.beta:
        return _parseDouble(holding['beta']) ?? 1.0;
      case MetricType.peRatio:
        return _parseDouble(holding['peRatio']) ?? 0.0;
      case MetricType.volume:
        return _parseDouble(holding['volume']) ?? 0.0;
      case MetricType.marketCap:
        return _parseDouble(holding['marketCapValue']) ?? 0.0;
      default:
        return _getChangePercent(holding, timeFrame);
    }
  }

  /// Get change percentage for specific time frame
  static double _getChangePercent(dynamic holding, TimeFrame timeFrame) {
    switch (timeFrame) {
      case TimeFrame.oneDay:
        return _parseDouble(holding['dayChangePercent']) ?? 0.0;
      case TimeFrame.oneWeek:
        return _parseDouble(holding['weekChangePercent']) ?? 0.0;
      case TimeFrame.oneMonth:
        return _parseDouble(holding['monthChangePercent']) ?? 0.0;
      case TimeFrame.threeMonths:
        return _parseDouble(holding['quarterChangePercent']) ?? 0.0;
      case TimeFrame.sixMonths:
        return _parseDouble(holding['halfYearChangePercent']) ?? 0.0;
      case TimeFrame.oneYear:
        return _parseDouble(holding['yearChangePercent']) ?? 0.0;
      case TimeFrame.ytd:
        return _parseDouble(holding['ytdChangePercent']) ?? 0.0;
      default:
        return _parseDouble(holding['dayChangePercent']) ?? 0.0;
    }
  }

  /// Get change amount for specific time frame
  static double _getChangeAmount(dynamic holding, TimeFrame timeFrame) {
    switch (timeFrame) {
      case TimeFrame.oneDay:
        return _parseDouble(holding['dayChange']) ?? 0.0;
      case TimeFrame.oneWeek:
        return _parseDouble(holding['weekChange']) ?? 0.0;
      case TimeFrame.oneMonth:
        return _parseDouble(holding['monthChange']) ?? 0.0;
      case TimeFrame.threeMonths:
        return _parseDouble(holding['quarterChange']) ?? 0.0;
      case TimeFrame.sixMonths:
        return _parseDouble(holding['halfYearChange']) ?? 0.0;
      case TimeFrame.oneYear:
        return _parseDouble(holding['yearChange']) ?? 0.0;
      case TimeFrame.ytd:
        return _parseDouble(holding['ytdChange']) ?? 0.0;
      default:
        return _parseDouble(holding['dayChange']) ?? 0.0;
    }
  }

  /// Check if tile should be included based on filters
  static bool _shouldIncludeTile(
    PortfolioHeatmapTileEntity tile,
    SectorType sectorFilter,
    MarketCapType marketCapFilter,
  ) {
    // Check sector filter
    if (sectorFilter != SectorType.all) {
      final tileSector = tile.sector?.toLowerCase() ?? 'other';
      final filterSector = sectorFilter.displayName.toLowerCase();
      if (tileSector != filterSector && filterSector != 'all') {
        return false;
      }
    }

    // Check market cap filter
    if (marketCapFilter != MarketCapType.all) {
      final tileMarketCap = tile.marketCapCategory;
      final filterMarketCap = _mapMarketCapTypeToCategory(marketCapFilter);
      if (tileMarketCap != filterMarketCap &&
          filterMarketCap != MarketCapCategory.unknown) {
        return false;
      }
    }

    return true;
  }

  /// Map MarketCapType to MarketCapCategory
  static MarketCapCategory _mapMarketCapTypeToCategory(MarketCapType type) {
    switch (type) {
      case MarketCapType.largeCap:
        return MarketCapCategory.largeCap;
      case MarketCapType.midCap:
        return MarketCapCategory.midCap;
      case MarketCapType.smallCap:
        return MarketCapCategory.smallCap;
      default:
        return MarketCapCategory.unknown;
    }
  }

  /// Calculate portfolio-level metrics
  static Map<String, dynamic> _calculatePortfolioMetrics(
    List<PortfolioHeatmapTileEntity> tiles,
  ) {
    if (tiles.isEmpty) {
      return {
        'totalValue': 0.0,
        'totalDayChange': 0.0,
        'totalDayChangePercent': 0.0,
        'baseCurrency': 'USD',
      };
    }

    double totalValue = 0.0;
    double totalDayChange = 0.0;
    String baseCurrency = tiles.first.currency ?? 'USD';

    for (final tile in tiles) {
      totalValue += tile.totalValue ?? 0.0;
      totalDayChange += tile.dayChange ?? 0.0;
    }

    final totalDayChangePercent = totalValue > 0
        ? (totalDayChange / (totalValue - totalDayChange)) * 100
        : 0.0;

    // Update tile weightages now that we have total value
    for (final tile in tiles) {
      final tileValue = tile.totalValue ?? 0.0;
      final weightage = totalValue > 0 ? (tileValue / totalValue) * 100 : 0.0;
      // Note: This is a simplification - in a real implementation,
      // you'd create new tiles with updated weightages
    }

    return {
      'totalValue': totalValue,
      'totalDayChange': totalDayChange,
      'totalDayChangePercent': totalDayChangePercent,
      'baseCurrency': baseCurrency,
    };
  }

  /// Calculate sector allocations
  static Map<String, double> _calculateSectorAllocations(
    List<PortfolioHeatmapTileEntity> tiles,
  ) {
    final Map<String, double> sectorValues = {};
    double totalValue = 0.0;

    // Calculate total value per sector
    for (final tile in tiles) {
      final sector = tile.sector ?? 'Other';
      final value = tile.totalValue ?? 0.0;
      sectorValues[sector] = (sectorValues[sector] ?? 0.0) + value;
      totalValue += value;
    }

    // Convert to percentages
    final Map<String, double> sectorAllocations = {};
    sectorValues.forEach((sector, value) {
      sectorAllocations[sector] = totalValue > 0
          ? (value / totalValue) * 100
          : 0.0;
    });

    return sectorAllocations;
  }

  /// Calculate market cap allocations
  static Map<String, double> _calculateMarketCapAllocations(
    List<PortfolioHeatmapTileEntity> tiles,
  ) {
    final Map<String, double> marketCapValues = {};
    double totalValue = 0.0;

    // Calculate total value per market cap category
    for (final tile in tiles) {
      final marketCap = tile.marketCapCategory.name;
      final value = tile.totalValue ?? 0.0;
      marketCapValues[marketCap] = (marketCapValues[marketCap] ?? 0.0) + value;
      totalValue += value;
    }

    // Convert to percentages
    final Map<String, double> marketCapAllocations = {};
    marketCapValues.forEach((marketCap, value) {
      marketCapAllocations[marketCap] = totalValue > 0
          ? (value / totalValue) * 100
          : 0.0;
    });

    return marketCapAllocations;
  }

  /// Convert portfolio tile to UI tile
  static HeatmapTileData _convertPortfolioTileToUITile(
    PortfolioHeatmapTileEntity portfolioTile,
  ) {
    return HeatmapTileData.fromEntity(
      portfolioTile.toEntity(),
      customColor: _getColorForPerformance(portfolioTile.performance),
      icon: _getIconForSector(portfolioTile.sector),
      onTap: () {
        // Handle tile tap - could navigate to holding details
      },
      customWidgets: {
        'symbol': Text(portfolioTile.symbol),
        'sector': Text(portfolioTile.sector ?? 'N/A'),
        'price': Text(portfolioTile.formattedCurrentPrice),
        'change': Text(portfolioTile.formattedDayChangePercent),
      },
    );
  }

  /// Generate title for heatmap
  static String _generateTitle(
    String portfolioName,
    MetricType metricType,
    TimeFrame timeFrame,
  ) {
    return '$portfolioName - ${metricType.displayName} (${timeFrame.displayName})';
  }

  /// Generate subtitle for heatmap
  static String _generateSubtitle(
    int tileCount,
    Map<String, dynamic> portfolioMetrics,
  ) {
    final totalValue = portfolioMetrics['totalValue'] ?? 0.0;
    final dayChangePercent = portfolioMetrics['totalDayChangePercent'] ?? 0.0;
    final currency = portfolioMetrics['baseCurrency'] ?? 'USD';

    final sign = dayChangePercent >= 0 ? '+' : '';
    return '$tileCount holdings • $currency${totalValue.toStringAsFixed(2)} • $sign${dayChangePercent.toStringAsFixed(2)}%';
  }

  /// Get color for performance value
  static Color? _getColorForPerformance(double performance) {
    if (performance > 5) return Colors.green.shade600;
    if (performance > 0) return Colors.green.shade400;
    if (performance > -5) return Colors.red.shade400;
    return Colors.red.shade600;
  }

  /// Get icon for sector
  static IconData? _getIconForSector(String? sector) {
    if (sector == null) return null;

    switch (sector.toLowerCase()) {
      case 'technology':
        return Icons.computer;
      case 'healthcare':
        return Icons.medical_services;
      case 'finance':
      case 'financial':
        return Icons.account_balance;
      case 'energy':
        return Icons.electric_bolt;
      case 'consumer':
        return Icons.shopping_cart;
      case 'industrial':
        return Icons.factory;
      case 'real estate':
        return Icons.home;
      case 'utilities':
        return Icons.power;
      case 'materials':
        return Icons.construction;
      case 'telecommunications':
        return Icons.phone;
      default:
        return Icons.business;
    }
  }

  /// Safely parse double from dynamic value
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }
}
