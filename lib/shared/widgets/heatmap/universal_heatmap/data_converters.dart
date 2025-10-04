import '../../../../core/app_logic/domain/entities/heatmap/heatmap_entities.dart'
    as core_entities;
import '../../../../core/utils/logger.dart';
import '../../../models/heatmap.dart';
import 'config_manager.dart';
import 'types.dart';

/// Investment-type specific data converters for universal heatmap
class UniversalHeatmapDataConverters {
  /// Convert raw data to heatmap data format based on investment type
  static HeatmapData? convertRawDataToHeatmapData({
    required InvestmentType investmentType,
    required Map<String, dynamic> rawData,
    required String title,
    String? subtitle,
    bool isLoading = false,
    String? error,
  }) {
    if (isLoading || error != null) {
      return null;
    }

    try {
      AppLogger.info(
        'Converting raw data to heatmap format: ${rawData.length} items',
        tag: 'UniversalHeatmapDataConverters',
      );

      final tiles = _convertRawDataToTiles(investmentType, rawData);

      final heatmapData = HeatmapData(
        id: 'universal-heatmap-${investmentType.name}',
        title: title,
        subtitle: subtitle,
        tiles: tiles,
        metadata: core_entities.HeatmapMetadata(
          lastUpdated: DateTime.now(),
          dataSource: 'universal_widget',
          additionalInfo: {
            'investmentType': investmentType.name,
            'tilesCount': tiles.length,
          },
        ),
        configuration: UniversalHeatmapConfigManager.getBasicConfig(
          title: title,
        ),
      );

      AppLogger.info(
        'Successfully converted ${tiles.length} tiles for ${investmentType.name} heatmap',
        tag: 'UniversalHeatmapDataConverters',
      );

      return heatmapData;
    } catch (error, stackTrace) {
      AppLogger.error(
        'Failed to convert raw data to heatmap format',
        tag: 'UniversalHeatmapDataConverters',
        error: error,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  /// Get empty heatmap data for loading/error states
  static HeatmapData getEmptyData({
    required InvestmentType investmentType,
    required String title,
  }) => HeatmapData(
    id: 'empty-heatmap',
    title: title,
    subtitle: 'No data available',
    tiles: [],
    metadata: core_entities.HeatmapMetadata(
      lastUpdated: DateTime.now(),
      dataSource: 'universal_widget',
      additionalInfo: const {'status': 'empty'},
    ),
    configuration: UniversalHeatmapConfigManager.getBasicConfig(title: title),
  );

  /// Convert raw data to heatmap tiles based on investment type
  static List<HeatmapTileData> _convertRawDataToTiles(
    InvestmentType investmentType,
    Map<String, dynamic> rawData,
  ) {
    AppLogger.debug(
      'Converting raw data to tiles for ${investmentType.name}',
      tag: 'UniversalHeatmapDataConverters.TileConversion',
    );

    final tiles = <HeatmapTileData>[];

    switch (investmentType) {
      case InvestmentType.portfolio:
        tiles.addAll(_convertPortfolioData(rawData));
        break;
      case InvestmentType.indexFund:
        tiles.addAll(_convertIndexData(rawData));
        break;
      case InvestmentType.mutualFunds:
        tiles.addAll(_convertMutualFundsData(rawData));
        break;
      case InvestmentType.etf:
        tiles.addAll(_convertETFData(rawData));
        break;
    }

    AppLogger.debug(
      'Converted ${tiles.length} tiles for ${investmentType.name}',
      tag: 'UniversalHeatmapDataConverters.TileConversion',
    );
    return tiles;
  }

  /// Convert portfolio specific data
  static List<HeatmapTileData> _convertPortfolioData(
    Map<String, dynamic> rawData,
  ) {
    AppLogger.debug(
      'Converting portfolio data from ${rawData.containsKey('holdings') ? (rawData['holdings'] as List).length : 0} holdings',
      tag: 'UniversalHeatmapDataConverters.Portfolio',
    );

    final tiles = <HeatmapTileData>[];

    if (rawData.containsKey('holdings')) {
      final holdings = rawData['holdings'] as List<dynamic>? ?? [];

      for (final holding in holdings) {
        if (holding is Map<String, dynamic>) {
          tiles.add(
            HeatmapTileData(
              id: holding['id']?.toString() ?? '',
              name: holding['name']?.toString() ?? 'Unknown',
              displayName:
                  holding['displayName']?.toString() ??
                  holding['name']?.toString() ??
                  'Unknown',
              performance: (holding['performance'] as num?)?.toDouble() ?? 0.0,
              weightage: (holding['weightage'] as num?)?.toDouble() ?? 0.0,
              value: (holding['value'] as num?)?.toDouble(),
            ),
          );
        }
      }
    }

    AppLogger.debug(
      'Successfully converted ${tiles.length} portfolio holdings to tiles',
      tag: 'UniversalHeatmapDataConverters.Portfolio',
    );
    return tiles;
  }

  /// Convert index specific data
  static List<HeatmapTileData> _convertIndexData(Map<String, dynamic> rawData) {
    AppLogger.debug(
      'Converting index data from ${rawData.containsKey('components') ? (rawData['components'] as List).length : 0} components',
      tag: 'UniversalHeatmapDataConverters.Index',
    );

    final tiles = <HeatmapTileData>[];

    if (rawData.containsKey('components')) {
      final components = rawData['components'] as List<dynamic>? ?? [];

      for (final component in components) {
        if (component is Map<String, dynamic>) {
          tiles.add(
            HeatmapTileData(
              id: component['id']?.toString() ?? '',
              name: component['name']?.toString() ?? 'Unknown',
              displayName:
                  component['displayName']?.toString() ??
                  component['name']?.toString() ??
                  'Unknown',
              performance: (component['change'] as num?)?.toDouble() ?? 0.0,
              weightage: (component['weight'] as num?)?.toDouble() ?? 0.0,
              value: (component['marketValue'] as num?)?.toDouble(),
            ),
          );
        }
      }
    }

    AppLogger.debug(
      'Successfully converted ${tiles.length} index components to tiles',
      tag: 'UniversalHeatmapDataConverters.Index',
    );
    return tiles;
  }

  /// Convert mutual funds specific data
  static List<HeatmapTileData> _convertMutualFundsData(
    Map<String, dynamic> rawData,
  ) {
    AppLogger.debug(
      'Converting mutual funds data from ${rawData.containsKey('funds') ? (rawData['funds'] as List).length : 0} funds',
      tag: 'UniversalHeatmapDataConverters.MutualFunds',
    );

    final tiles = <HeatmapTileData>[];

    if (rawData.containsKey('funds')) {
      final funds = rawData['funds'] as List<dynamic>? ?? [];

      for (final fund in funds) {
        if (fund is Map<String, dynamic>) {
          tiles.add(
            HeatmapTileData(
              id: fund['id']?.toString() ?? '',
              name: fund['fundName']?.toString() ?? 'Unknown',
              displayName:
                  fund['displayName']?.toString() ??
                  fund['fundName']?.toString() ??
                  'Unknown',
              performance: (fund['returns'] as num?)?.toDouble() ?? 0.0,
              weightage: (fund['allocation'] as num?)?.toDouble() ?? 0.0,
              value: (fund['nav'] as num?)?.toDouble(),
            ),
          );
        }
      }
    }

    AppLogger.debug(
      'Successfully converted ${tiles.length} mutual funds to tiles',
      tag: 'UniversalHeatmapDataConverters.MutualFunds',
    );
    return tiles;
  }

  /// Convert ETF specific data
  static List<HeatmapTileData> _convertETFData(Map<String, dynamic> rawData) {
    AppLogger.debug(
      'Converting ETF data from ${rawData.containsKey('etfs') ? (rawData['etfs'] as List).length : 0} ETFs',
      tag: 'UniversalHeatmapDataConverters.ETF',
    );

    final tiles = <HeatmapTileData>[];

    if (rawData.containsKey('etfs')) {
      final etfs = rawData['etfs'] as List<dynamic>? ?? [];

      for (final etf in etfs) {
        if (etf is Map<String, dynamic>) {
          tiles.add(
            HeatmapTileData(
              id: etf['id']?.toString() ?? '',
              name: etf['name']?.toString() ?? 'Unknown',
              displayName:
                  etf['displayName']?.toString() ??
                  etf['name']?.toString() ??
                  'Unknown',
              performance: (etf['performance'] as num?)?.toDouble() ?? 0.0,
              weightage: (etf['weight'] as num?)?.toDouble() ?? 0.0,
              value: (etf['price'] as num?)?.toDouble(),
            ),
          );
        }
      }
    }

    AppLogger.debug(
      'Successfully converted ${tiles.length} ETFs to tiles',
      tag: 'UniversalHeatmapDataConverters.ETF',
    );
    return tiles;
  }
}
