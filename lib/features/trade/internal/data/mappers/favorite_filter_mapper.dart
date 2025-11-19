import '../../domain/entities/favorite_filter.dart';
import '../../domain/entities/filter_criteria.dart';
import '../../domain/entities/metrics_filter_config.dart';
import '../dtos/favorite_filter_dto.dart';
import '../dtos/filter_criteria_dtos.dart';
import '../dtos/metrics_filter_config_dto.dart';

/// Mapper for favorite filter between DTO and domain entity
class FavoriteFilterMapper {
  /// Convert FavoriteFilterResponseDto to FavoriteFilter domain entity
  static FavoriteFilter fromResponseDto(FavoriteFilterResponseDto dto) => FavoriteFilter(
    id: dto.id,
    name: dto.name,
    description: dto.description,
    filterConfig: MetricsFilterConfigMapper.fromDto(dto.filterConfig),
    createdAt: dto.createdAt != null ? DateTime.tryParse(dto.createdAt!) : null,
    updatedAt: dto.updatedAt != null ? DateTime.tryParse(dto.updatedAt!) : null,
    isDefault: dto.isDefault ?? false,
  );

  /// Convert FavoriteFilter entity to FavoriteFilterRequestDto
  static FavoriteFilterRequestDto toRequestDto(FavoriteFilter filter) => FavoriteFilterRequestDto(
    name: filter.name,
    description: filter.description,
    isDefault: filter.isDefault,
    filterConfig: MetricsFilterConfigMapper.toDto(filter.filterConfig),
  );

  /// Convert list of FavoriteFilterResponseDto to FavoriteFilterList entity
  static FavoriteFilterList fromListDto(List<FavoriteFilterResponseDto> dtos, String userId) =>
      FavoriteFilterList(
        userId: userId,
        filters: dtos.map(fromResponseDto).toList(),
        totalCount: dtos.length,
      );

  /// Convert BulkDeleteResponseDto to BulkDeleteResult entity
  static BulkDeleteResult fromBulkDeleteDto(BulkDeleteResponseDto dto) => BulkDeleteResult(
    deletedCount: dto.deletedCount,
    totalRequested: dto.totalRequested,
    message: dto.message,
  );
}

/// Mapper for metrics filter config between DTO and domain entity
class MetricsFilterConfigMapper {
  /// Convert MetricsFilterConfigDto to MetricsFilterConfig domain entity
  static MetricsFilterConfig fromDto(MetricsFilterConfigDto dto) => MetricsFilterConfig(
    portfolioIds: dto.portfolioIds ?? [],
    dateRange: dto.dateRange != null ? _parseDateRange(dto.dateRange!) : null,
    timePeriod: dto.timePeriod?['period'] as String?,
    metricTypes: dto.metricTypes ?? [],
    groupBy: dto.groupBy ?? [],
    instruments: dto.instruments ?? [],
    instrumentFilters: dto.instrumentFilters != null
        ? InstrumentFilterCriteriaMapper.fromMap(dto.instrumentFilters!)
        : null,
    tradeCharacteristics: dto.tradeCharacteristics != null
        ? TradeCharacteristicsFilterMapper.fromMap(dto.tradeCharacteristics!)
        : null,
    profitLossFilters:
        dto.profitLossFilters != null ? ProfitLossFilterMapper.fromMap(dto.profitLossFilters!) : null,
  );

  /// Convert MetricsFilterConfig entity to MetricsFilterConfigDto
  static MetricsFilterConfigDto toDto(MetricsFilterConfig config) => MetricsFilterConfigDto(
    portfolioIds: config.portfolioIds.isNotEmpty ? config.portfolioIds : null,
    dateRange: config.dateRange != null ? _dateRangeToMap(config.dateRange!) : null,
    timePeriod: config.timePeriod != null ? {'period': config.timePeriod} : null,
    metricTypes: config.metricTypes.isNotEmpty ? config.metricTypes : null,
    groupBy: config.groupBy.isNotEmpty ? config.groupBy : null,
    instruments: config.instruments.isNotEmpty ? config.instruments : null,
    instrumentFilters: config.instrumentFilters != null
        ? InstrumentFilterCriteriaMapper.toMap(config.instrumentFilters!)
        : null,
    tradeCharacteristics: config.tradeCharacteristics != null
        ? TradeCharacteristicsFilterMapper.toMap(config.tradeCharacteristics!)
        : null,
    profitLossFilters:
        config.profitLossFilters != null ? ProfitLossFilterMapper.toMap(config.profitLossFilters!) : null,
  );

  static DateRangeFilter? _parseDateRange(Map<String, dynamic> map) {
    final startDateStr = map['startDate'] as String?;
    final endDateStr = map['endDate'] as String?;

    if (startDateStr == null || endDateStr == null) return null;

    final startDate = DateTime.tryParse(startDateStr);
    final endDate = DateTime.tryParse(endDateStr);

    if (startDate == null || endDate == null) return null;

    return DateRangeFilter(startDate: startDate, endDate: endDate);
  }

  static Map<String, dynamic> _dateRangeToMap(DateRangeFilter filter) => {
    'startDate': filter.startDate.toIso8601String().split('T')[0],
    'endDate': filter.endDate.toIso8601String().split('T')[0],
  };
}

/// Mapper for instrument filter criteria
class InstrumentFilterCriteriaMapper {
  /// Convert from Map to InstrumentFilterCriteria entity
  static InstrumentFilterCriteria fromMap(Map<String, dynamic> map) {
    // Since the DTO uses Map<String, dynamic>, we need to handle the raw map
    return InstrumentFilterCriteria(
      marketSegments: map['marketSegments'] != null ? List<String>.from(map['marketSegments'] as List).map((e) {
        // Convert string to enum if needed
        return e;
      }).toList() as List : [],
      baseSymbols: map['baseSymbols'] != null ? List<String>.from(map['baseSymbols'] as List) : [],
      indexTypes: map['indexTypes'] != null ? List<String>.from(map['indexTypes'] as List).map((e) {
        return e;
      }).toList() as List : [],
      derivativeTypes: map['derivativeTypes'] != null ? List<String>.from(map['derivativeTypes'] as List).map((e) {
        return e;
      }).toList() as List : [],
    );
  }

  /// Convert from InstrumentFilterCriteria entity to Map
  static Map<String, dynamic> toMap(InstrumentFilterCriteria criteria) {
    final map = <String, dynamic>{};

    if (criteria.marketSegments.isNotEmpty) {
      map['marketSegments'] = criteria.marketSegments;
    }
    if (criteria.baseSymbols.isNotEmpty) {
      map['baseSymbols'] = criteria.baseSymbols;
    }
    if (criteria.indexTypes.isNotEmpty) {
      map['indexTypes'] = criteria.indexTypes;
    }
    if (criteria.derivativeTypes.isNotEmpty) {
      map['derivativeTypes'] = criteria.derivativeTypes;
    }

    return map;
  }
}

/// Mapper for trade characteristics filter
class TradeCharacteristicsFilterMapper {
  /// Convert from Map to TradeCharacteristicsFilter entity
  static TradeCharacteristicsFilter fromMap(Map<String, dynamic> map) => TradeCharacteristicsFilter(
    strategies: map['strategies'] != null ? List<String>.from(map['strategies'] as List) : [],
    tags: map['tags'] != null ? List<String>.from(map['tags'] as List) : [],
    directions: map['directions'] != null ? List<String>.from(map['directions'] as List).map((e) {
      return e;
    }).toList() as List : [],
    statuses: map['statuses'] != null ? List<String>.from(map['statuses'] as List).map((e) {
      return e;
    }).toList() as List : [],
    minHoldingTimeHours: map['minHoldingTimeHours'] as int?,
    maxHoldingTimeHours: map['maxHoldingTimeHours'] as int?,
  );

  /// Convert from TradeCharacteristicsFilter entity to Map
  static Map<String, dynamic> toMap(TradeCharacteristicsFilter filter) {
    final map = <String, dynamic>{};

    if (filter.strategies.isNotEmpty) map['strategies'] = filter.strategies;
    if (filter.tags.isNotEmpty) map['tags'] = filter.tags;
    if (filter.directions.isNotEmpty) map['directions'] = filter.directions;
    if (filter.statuses.isNotEmpty) map['statuses'] = filter.statuses;
    if (filter.minHoldingTimeHours != null) map['minHoldingTimeHours'] = filter.minHoldingTimeHours;
    if (filter.maxHoldingTimeHours != null) map['maxHoldingTimeHours'] = filter.maxHoldingTimeHours;

    return map;
  }
}

/// Mapper for profit/loss filter
class ProfitLossFilterMapper {
  /// Convert from Map to ProfitLossFilter entity
  static ProfitLossFilter fromMap(Map<String, dynamic> map) => ProfitLossFilter(
    minProfitLoss: map['minProfitLoss'] as double?,
    maxProfitLoss: map['maxProfitLoss'] as double?,
    minPositionSize: map['minPositionSize'] as double?,
    maxPositionSize: map['maxPositionSize'] as double?,
  );

  /// Convert from ProfitLossFilter entity to Map
  static Map<String, dynamic> toMap(ProfitLossFilter filter) {
    final map = <String, dynamic>{};

    if (filter.minProfitLoss != null) map['minProfitLoss'] = filter.minProfitLoss;
    if (filter.maxProfitLoss != null) map['maxProfitLoss'] = filter.maxProfitLoss;
    if (filter.minPositionSize != null) map['minPositionSize'] = filter.minPositionSize;
    if (filter.maxPositionSize != null) map['maxPositionSize'] = filter.maxPositionSize;

    return map;
  }
}
