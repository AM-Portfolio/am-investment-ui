import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../models/heatmap/heatmap_ui_data.dart';
import '../../../models/heatmap/heatmap_tile_data.dart';
import '../../../../core/app_logic/domain/entities/heatmap/heatmap_entities.dart';
import '../../../widgets/selectors/selectors.dart';
import '../../../extensions/investment_extensions.dart';

/// States for the heatmap display cubit
abstract class HeatmapDisplayState extends Equatable {
  const HeatmapDisplayState();

  @override
  List<Object?> get props => [];
}

class HeatmapDisplayInitial extends HeatmapDisplayState {
  const HeatmapDisplayInitial();
}

class HeatmapDisplayLoading extends HeatmapDisplayState {
  const HeatmapDisplayLoading();
}

class HeatmapDisplayLoaded extends HeatmapDisplayState {
  final HeatmapData data;
  final HeatmapDisplayConfig config;
  final HeatmapFilters filters;

  const HeatmapDisplayLoaded({
    required this.data,
    required this.config,
    required this.filters,
  });

  @override
  List<Object?> get props => [data, config, filters];

  HeatmapDisplayLoaded copyWith({
    HeatmapData? data,
    HeatmapDisplayConfig? config,
    HeatmapFilters? filters,
  }) {
    return HeatmapDisplayLoaded(
      data: data ?? this.data,
      config: config ?? this.config,
      filters: filters ?? this.filters,
    );
  }
}

class HeatmapDisplayError extends HeatmapDisplayState {
  final String message;
  final dynamic error;

  const HeatmapDisplayError({required this.message, this.error});

  @override
  List<Object?> get props => [message, error];
}

/// Configuration for heatmap display behavior
class HeatmapDisplayConfig extends Equatable {
  final InvestmentType type;
  final bool showSelectors;
  final bool enableInteraction;
  final bool compactMode;
  final String? title;
  final String? subtitle;
  final HeatmapLayoutType layout;
  final HeatmapColorSchemeType colorScheme;
  final List<TimeFrame> availableTimeFrames;
  final List<MetricType> availableMetrics;
  final List<SectorType> availableSectors;
  final List<MarketCapType> availableMarketCaps;

  const HeatmapDisplayConfig({
    required this.type,
    this.showSelectors = true,
    this.enableInteraction = true,
    this.compactMode = false,
    this.title,
    this.subtitle,
    this.layout = HeatmapLayoutType.treemap,
    this.colorScheme = HeatmapColorSchemeType.performance,
    this.availableTimeFrames = const [],
    this.availableMetrics = const [],
    this.availableSectors = const [],
    this.availableMarketCaps = const [],
  });

  /// Create configuration for portfolio type
  factory HeatmapDisplayConfig.portfolio({
    String? title,
    bool compactMode = false,
  }) {
    return HeatmapDisplayConfig(
      type: InvestmentType.portfolio,
      title: title ?? 'Portfolio Heatmap',
      subtitle: 'Sector Performance Overview',
      showSelectors: true,
      enableInteraction: true,
      compactMode: compactMode,
      layout: compactMode ? HeatmapLayoutType.grid : HeatmapLayoutType.treemap,
      colorScheme: HeatmapColorSchemeType.performance,
      availableTimeFrames: TimeFrameInvestmentTypes.portfolioTimeFrames,
      availableMetrics: MetricTypeInvestmentTypes.portfolioMetrics,
      availableSectors: SectorTypeInvestmentTypes.allSectors,
      availableMarketCaps: MarketCapTypeInvestmentTypes.allMarketCaps,
    );
  }

  /// Create configuration for index type
  factory HeatmapDisplayConfig.index({
    String? title,
    bool compactMode = false,
  }) {
    return HeatmapDisplayConfig(
      type: InvestmentType.indexFund,
      title: title ?? 'Index Heatmap',
      subtitle: 'Index Components Performance',
      showSelectors: true,
      enableInteraction: true,
      compactMode: compactMode,
      layout: HeatmapLayoutType.treemap,
      colorScheme: HeatmapColorSchemeType.performance,
      availableTimeFrames: TimeFrameInvestmentTypes.indexTimeFrames,
      availableMetrics: MetricTypeInvestmentTypes.indexMetrics,
      availableSectors: SectorTypeInvestmentTypes.allSectors,
      availableMarketCaps: MarketCapTypeInvestmentTypes.allMarketCaps,
    );
  }

  /// Create configuration for mutual funds type
  factory HeatmapDisplayConfig.mutualFunds({
    String? title,
    bool compactMode = false,
  }) {
    return HeatmapDisplayConfig(
      type: InvestmentType.mutualFunds,
      title: title ?? 'Mutual Funds Heatmap',
      subtitle: 'Fund Performance Overview',
      showSelectors: true,
      enableInteraction: true,
      compactMode: compactMode,
      layout: HeatmapLayoutType.grid,
      colorScheme: HeatmapColorSchemeType.performance,
      availableTimeFrames: TimeFrameInvestmentTypes.fundTimeFrames,
      availableMetrics: MetricTypeInvestmentTypes.fundMetrics,
      availableSectors: SectorTypeInvestmentTypes.fundSectors,
      availableMarketCaps: MarketCapTypeInvestmentTypes.fundMarketCaps,
    );
  }

  /// Create configuration for ETF type
  factory HeatmapDisplayConfig.etf({String? title, bool compactMode = false}) {
    return HeatmapDisplayConfig(
      type: InvestmentType.etf,
      title: title ?? 'ETF Heatmap',
      subtitle: 'ETF Performance Overview',
      showSelectors: true,
      enableInteraction: true,
      compactMode: compactMode,
      layout: HeatmapLayoutType.treemap,
      colorScheme: HeatmapColorSchemeType.performance,
      availableTimeFrames: TimeFrameInvestmentTypes.etfTimeFrames,
      availableMetrics: MetricTypeInvestmentTypes.etfMetrics,
      availableSectors: SectorTypeInvestmentTypes.etfSectors,
      availableMarketCaps: MarketCapTypeInvestmentTypes.etfMarketCaps,
    );
  }

  @override
  List<Object?> get props => [
    type,
    showSelectors,
    enableInteraction,
    compactMode,
    title,
    subtitle,
    layout,
    colorScheme,
    availableTimeFrames,
    availableMetrics,
    availableSectors,
    availableMarketCaps,
  ];

  HeatmapDisplayConfig copyWith({
    InvestmentType? type,
    bool? showSelectors,
    bool? enableInteraction,
    bool? compactMode,
    String? title,
    String? subtitle,
    HeatmapLayoutType? layout,
    HeatmapColorSchemeType? colorScheme,
    List<TimeFrame>? availableTimeFrames,
    List<MetricType>? availableMetrics,
    List<SectorType>? availableSectors,
    List<MarketCapType>? availableMarketCaps,
  }) {
    return HeatmapDisplayConfig(
      type: type ?? this.type,
      showSelectors: showSelectors ?? this.showSelectors,
      enableInteraction: enableInteraction ?? this.enableInteraction,
      compactMode: compactMode ?? this.compactMode,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      layout: layout ?? this.layout,
      colorScheme: colorScheme ?? this.colorScheme,
      availableTimeFrames: availableTimeFrames ?? this.availableTimeFrames,
      availableMetrics: availableMetrics ?? this.availableMetrics,
      availableSectors: availableSectors ?? this.availableSectors,
      availableMarketCaps: availableMarketCaps ?? this.availableMarketCaps,
    );
  }
}

/// Current filter state for the heatmap
class HeatmapFilters extends Equatable {
  final TimeFrame timeFrame;
  final MetricType metric;
  final SectorType sector;
  final MarketCapType marketCap;
  final String? searchQuery;
  final double? minPerformance;
  final double? maxPerformance;

  const HeatmapFilters({
    this.timeFrame = TimeFrame.oneMonth,
    this.metric = MetricType.changePercent,
    this.sector = SectorType.all,
    this.marketCap = MarketCapType.all,
    this.searchQuery,
    this.minPerformance,
    this.maxPerformance,
  });

  @override
  List<Object?> get props => [
    timeFrame,
    metric,
    sector,
    marketCap,
    searchQuery,
    minPerformance,
    maxPerformance,
  ];

  HeatmapFilters copyWith({
    TimeFrame? timeFrame,
    MetricType? metric,
    SectorType? sector,
    MarketCapType? marketCap,
    String? searchQuery,
    double? minPerformance,
    double? maxPerformance,
  }) {
    return HeatmapFilters(
      timeFrame: timeFrame ?? this.timeFrame,
      metric: metric ?? this.metric,
      sector: sector ?? this.sector,
      marketCap: marketCap ?? this.marketCap,
      searchQuery: searchQuery ?? this.searchQuery,
      minPerformance: minPerformance ?? this.minPerformance,
      maxPerformance: maxPerformance ?? this.maxPerformance,
    );
  }
}

/// Investment types supported by the heatmap
enum InvestmentType { portfolio, indexFund, mutualFunds, etf }

/// Extension methods for InvestmentType
extension InvestmentTypeExtension on InvestmentType {
  String get displayName {
    switch (this) {
      case InvestmentType.portfolio:
        return 'Portfolio';
      case InvestmentType.indexFund:
        return 'Index';
      case InvestmentType.mutualFunds:
        return 'Mutual Funds';
      case InvestmentType.etf:
        return 'ETF';
    }
  }

  String get description {
    switch (this) {
      case InvestmentType.portfolio:
        return 'Portfolio sector allocation and performance';
      case InvestmentType.indexFund:
        return 'Index components and weightings';
      case InvestmentType.mutualFunds:
        return 'Mutual fund holdings and performance';
      case InvestmentType.etf:
        return 'ETF holdings and sector allocation';
    }
  }
}

/// Main cubit for managing heatmap display state and interactions
class HeatmapDisplayCubit extends Cubit<HeatmapDisplayState> {
  HeatmapDisplayCubit() : super(const HeatmapDisplayInitial());

  /// Initialize heatmap with configuration and raw data
  Future<void> initialize({
    required HeatmapDisplayConfig config,
    required Map<String, dynamic> rawData,
    HeatmapFilters? initialFilters,
  }) async {
    try {
      emit(const HeatmapDisplayLoading());

      // Convert raw data to heatmap data based on investment type
      final heatmapData = await _convertRawDataToHeatmap(
        rawData: rawData,
        config: config,
      );

      final filters = initialFilters ?? const HeatmapFilters();

      // Apply initial filters
      final filteredData = _applyFilters(heatmapData, filters);

      emit(
        HeatmapDisplayLoaded(
          data: filteredData,
          config: config,
          filters: filters,
        ),
      );
    } catch (error) {
      emit(
        HeatmapDisplayError(
          message: 'Failed to initialize heatmap: ${error.toString()}',
          error: error,
        ),
      );
    }
  }

  /// Update filters and refresh the heatmap
  Future<void> updateFilters(HeatmapFilters newFilters) async {
    final currentState = state;
    if (currentState is! HeatmapDisplayLoaded) return;

    try {
      emit(const HeatmapDisplayLoading());

      // Get the original unfiltered data
      final originalData = currentState.data;

      // Apply new filters
      final filteredData = _applyFilters(originalData, newFilters);

      emit(currentState.copyWith(data: filteredData, filters: newFilters));
    } catch (error) {
      emit(
        HeatmapDisplayError(
          message: 'Failed to update filters: ${error.toString()}',
          error: error,
        ),
      );
    }
  }

  /// Update individual filter values
  void updateTimeFrame(TimeFrame timeFrame) {
    final currentState = state;
    if (currentState is HeatmapDisplayLoaded) {
      final newFilters = currentState.filters.copyWith(timeFrame: timeFrame);
      updateFilters(newFilters);
    }
  }

  void updateMetric(MetricType metric) {
    final currentState = state;
    if (currentState is HeatmapDisplayLoaded) {
      final newFilters = currentState.filters.copyWith(metric: metric);
      updateFilters(newFilters);
    }
  }

  void updateSector(SectorType sector) {
    final currentState = state;
    if (currentState is HeatmapDisplayLoaded) {
      final newFilters = currentState.filters.copyWith(sector: sector);
      updateFilters(newFilters);
    }
  }

  void updateMarketCap(MarketCapType marketCap) {
    final currentState = state;
    if (currentState is HeatmapDisplayLoaded) {
      final newFilters = currentState.filters.copyWith(marketCap: marketCap);
      updateFilters(newFilters);
    }
  }

  void updateSearchQuery(String? query) {
    final currentState = state;
    if (currentState is HeatmapDisplayLoaded) {
      final newFilters = currentState.filters.copyWith(searchQuery: query);
      updateFilters(newFilters);
    }
  }

  /// Refresh the heatmap data
  Future<void> refresh() async {
    final currentState = state;
    if (currentState is HeatmapDisplayLoaded) {
      // Re-emit loading and reload with current config
      emit(const HeatmapDisplayLoading());
      // You would typically reload from your data source here
      emit(currentState);
    }
  }

  /// Convert raw data to HeatmapData based on investment type
  Future<HeatmapData> _convertRawDataToHeatmap({
    required Map<String, dynamic> rawData,
    required HeatmapDisplayConfig config,
  }) async {
    List<HeatmapTileData> tiles = [];

    switch (config.type) {
      case InvestmentType.portfolio:
        tiles = _convertPortfolioData(rawData);
        break;
      case InvestmentType.indexFund:
        tiles = _convertIndexData(rawData);
        break;
      case InvestmentType.mutualFunds:
        tiles = _convertMutualFundsData(rawData);
        break;
      case InvestmentType.etf:
        tiles = _convertETFData(rawData);
        break;
    }

    return HeatmapData(
      id: '${config.type.name}-heatmap-${DateTime.now().millisecondsSinceEpoch}',
      title: config.title ?? config.type.displayName,
      subtitle: config.subtitle ?? config.type.description,
      tiles: tiles,
      metadata: HeatmapMetadata(
        lastUpdated: DateTime.now(),
        dataSource: 'heatmap_display_cubit',
        additionalInfo: {
          'type': config.type.name,
          'timestamp': DateTime.now().toIso8601String(),
        },
      ),
      configuration: HeatmapConfiguration(
        showPerformance: true,
        showWeightage: true,
        showValue: !config.compactMode,
        layout: config.layout,
        colorScheme: config.colorScheme,
      ),
    );
  }

  /// Convert portfolio raw data to tiles
  List<HeatmapTileData> _convertPortfolioData(Map<String, dynamic> rawData) {
    final sectors =
        rawData['analytics']?['heatmap']?['sectors'] as List<dynamic>? ?? [];

    return sectors.map((sectorData) {
      final sector = sectorData as Map<String, dynamic>;
      return HeatmapTileData(
        id:
            sector['sectorName']?.toString().toLowerCase().replaceAll(
              ' ',
              '_',
            ) ??
            '',
        name: sector['sectorName']?.toString() ?? '',
        displayName: sector['sectorName']?.toString() ?? '',
        weightage: (sector['weightage'] as num?)?.toDouble() ?? 0.0,
        performance: (sector['changePercent'] as num?)?.toDouble() ?? 0.0,
        value: (sector['totalValue'] as num?)?.toDouble(),
        metadata: {'sector': sector['sectorName'], 'count': sector['count']},
      );
    }).toList();
  }

  /// Convert index raw data to tiles
  List<HeatmapTileData> _convertIndexData(Map<String, dynamic> rawData) {
    final components = rawData['components'] as List<dynamic>? ?? [];

    return components.map((componentData) {
      final component = componentData as Map<String, dynamic>;
      return HeatmapTileData(
        id: component['symbol']?.toString() ?? '',
        name: component['symbol']?.toString() ?? '',
        displayName:
            component['name']?.toString() ??
            component['symbol']?.toString() ??
            '',
        weightage: (component['weight'] as num?)?.toDouble() ?? 0.0,
        performance: (component['changePercent'] as num?)?.toDouble() ?? 0.0,
        value: (component['marketCap'] as num?)?.toDouble(),
        metadata: {
          'symbol': component['symbol'],
          'sector': component['sector'],
        },
      );
    }).toList();
  }

  /// Convert mutual funds raw data to tiles
  List<HeatmapTileData> _convertMutualFundsData(Map<String, dynamic> rawData) {
    final funds = rawData['funds'] as List<dynamic>? ?? [];

    return funds.map((fundData) {
      final fund = fundData as Map<String, dynamic>;
      return HeatmapTileData(
        id: fund['fundId']?.toString() ?? '',
        name: fund['shortName']?.toString() ?? '',
        displayName:
            fund['fullName']?.toString() ?? fund['shortName']?.toString() ?? '',
        weightage: (fund['allocation'] as num?)?.toDouble() ?? 0.0,
        performance: (fund['returns'] as num?)?.toDouble() ?? 0.0,
        value: (fund['nav'] as num?)?.toDouble(),
        metadata: {
          'fundId': fund['fundId'],
          'category': fund['category'],
          'risk': fund['riskLevel'],
        },
      );
    }).toList();
  }

  /// Convert ETF raw data to tiles
  List<HeatmapTileData> _convertETFData(Map<String, dynamic> rawData) {
    final holdings = rawData['holdings'] as List<dynamic>? ?? [];

    return holdings.map((holdingData) {
      final holding = holdingData as Map<String, dynamic>;
      return HeatmapTileData(
        id: holding['symbol']?.toString() ?? '',
        name: holding['symbol']?.toString() ?? '',
        displayName:
            holding['name']?.toString() ?? holding['symbol']?.toString() ?? '',
        weightage: (holding['weight'] as num?)?.toDouble() ?? 0.0,
        performance: (holding['changePercent'] as num?)?.toDouble() ?? 0.0,
        value: (holding['marketValue'] as num?)?.toDouble(),
        metadata: {
          'symbol': holding['symbol'],
          'sector': holding['sector'],
          'country': holding['country'],
        },
      );
    }).toList();
  }

  /// Apply filters to heatmap data
  HeatmapData _applyFilters(HeatmapData data, HeatmapFilters filters) {
    var filteredTiles = data.tiles.toList();

    // Apply sector filter
    if (filters.sector != SectorType.all) {
      filteredTiles = filteredTiles.where((tile) {
        final tileSector = tile.metadata?['sector']?.toString() ?? '';
        return tileSector.toLowerCase().contains(
          filters.sector.name.toLowerCase(),
        );
      }).toList();
    }

    // Apply performance filter
    if (filters.minPerformance != null) {
      filteredTiles = filteredTiles
          .where((tile) => tile.performance >= filters.minPerformance!)
          .toList();
    }
    if (filters.maxPerformance != null) {
      filteredTiles = filteredTiles
          .where((tile) => tile.performance <= filters.maxPerformance!)
          .toList();
    }

    // Apply search query
    if (filters.searchQuery != null && filters.searchQuery!.isNotEmpty) {
      final query = filters.searchQuery!.toLowerCase();
      filteredTiles = filteredTiles
          .where(
            (tile) =>
                tile.displayName.toLowerCase().contains(query) ||
                tile.name.toLowerCase().contains(query),
          )
          .toList();
    }

    return data.copyWith(tiles: filteredTiles.cast<HeatmapTileData>());
  }
}
