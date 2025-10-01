import 'package:json_annotation/json_annotation.dart';

part 'portfolio_analytics_response_dto.g.dart';

/// DTO for portfolio analytics response
@JsonSerializable()
class PortfolioAnalyticsResponseDto {
  final String portfolioId;
  final String timestamp;
  final AnalyticsDto analytics;

  const PortfolioAnalyticsResponseDto({
    required this.portfolioId,
    required this.timestamp,
    required this.analytics,
  });

  factory PortfolioAnalyticsResponseDto.fromJson(Map<String, dynamic> json) =>
      _$PortfolioAnalyticsResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$PortfolioAnalyticsResponseDtoToJson(this);
}

/// Analytics data container
@JsonSerializable()
class AnalyticsDto {
  final HeatmapDto? heatmap;
  final MoversDto? movers;
  final SectorAllocationDto? sectorAllocation;
  final MarketCapAllocationDto? marketCapAllocation;

  const AnalyticsDto({
    this.heatmap,
    this.movers,
    this.sectorAllocation,
    this.marketCapAllocation,
  });

  factory AnalyticsDto.fromJson(Map<String, dynamic> json) =>
      _$AnalyticsDtoFromJson(json);

  Map<String, dynamic> toJson() => _$AnalyticsDtoToJson(this);
}

/// Heatmap data for sector performance
@JsonSerializable()
class HeatmapDto {
  final List<SectorDto> sectors;

  const HeatmapDto({required this.sectors});

  factory HeatmapDto.fromJson(Map<String, dynamic> json) =>
      _$HeatmapDtoFromJson(json);

  Map<String, dynamic> toJson() => _$HeatmapDtoToJson(this);
}

/// Sector performance data
@JsonSerializable()
class SectorDto {
  final String sectorName;
  final int performanceRank;
  final double performance;
  final double changePercent;
  final double weightage;
  final String color;
  final int stockCount;
  final double totalValue;
  final double totalReturnAmount;
  final List<StockDto> stocks;

  const SectorDto({
    required this.sectorName,
    required this.performanceRank,
    required this.performance,
    required this.changePercent,
    required this.weightage,
    required this.color,
    required this.stockCount,
    required this.totalValue,
    required this.totalReturnAmount,
    required this.stocks,
  });

  factory SectorDto.fromJson(Map<String, dynamic> json) =>
      _$SectorDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SectorDtoToJson(this);
}

/// Stock data in sector
@JsonSerializable()
class StockDto {
  final String symbol;
  final String companyName;
  final double lastPrice;
  final double changeAmount;
  final double changePercent;
  final String sector;
  final double? quantity;
  final double? avgPrice;
  final double? marketValue;
  final double? totalReturn;

  const StockDto({
    required this.symbol,
    required this.companyName,
    required this.lastPrice,
    required this.changeAmount,
    required this.changePercent,
    required this.sector,
    this.quantity,
    this.avgPrice,
    this.marketValue,
    this.totalReturn,
  });

  factory StockDto.fromJson(Map<String, dynamic> json) =>
      _$StockDtoFromJson(json);

  Map<String, dynamic> toJson() => _$StockDtoToJson(this);
}

/// Movers data (top gainers and losers)
@JsonSerializable()
class MoversDto {
  final List<StockDto> topGainers;
  final List<StockDto> topLosers;

  const MoversDto({required this.topGainers, required this.topLosers});

  factory MoversDto.fromJson(Map<String, dynamic> json) =>
      _$MoversDtoFromJson(json);

  Map<String, dynamic> toJson() => _$MoversDtoToJson(this);
}

/// Sector allocation data
@JsonSerializable()
class SectorAllocationDto {
  final List<SectorWeightDto> sectorWeights;
  final List<IndustryWeightDto> industryWeights;

  const SectorAllocationDto({
    required this.sectorWeights,
    required this.industryWeights,
  });

  factory SectorAllocationDto.fromJson(Map<String, dynamic> json) =>
      _$SectorAllocationDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SectorAllocationDtoToJson(this);
}

/// Sector weight data
@JsonSerializable()
class SectorWeightDto {
  final String sectorName;
  final double weightPercentage;
  final double marketCap;
  final List<String> topStocks;

  const SectorWeightDto({
    required this.sectorName,
    required this.weightPercentage,
    required this.marketCap,
    required this.topStocks,
  });

  factory SectorWeightDto.fromJson(Map<String, dynamic> json) =>
      _$SectorWeightDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SectorWeightDtoToJson(this);
}

/// Industry weight data
@JsonSerializable()
class IndustryWeightDto {
  final String industryName;
  final String parentSector;
  final double weightPercentage;
  final double marketCap;
  final List<String> topStocks;

  const IndustryWeightDto({
    required this.industryName,
    required this.parentSector,
    required this.weightPercentage,
    required this.marketCap,
    required this.topStocks,
  });

  factory IndustryWeightDto.fromJson(Map<String, dynamic> json) =>
      _$IndustryWeightDtoFromJson(json);

  Map<String, dynamic> toJson() => _$IndustryWeightDtoToJson(this);
}

/// Market cap allocation data
@JsonSerializable()
class MarketCapAllocationDto {
  final List<MarketCapSegmentDto> segments;

  const MarketCapAllocationDto({required this.segments});

  factory MarketCapAllocationDto.fromJson(Map<String, dynamic> json) =>
      _$MarketCapAllocationDtoFromJson(json);

  Map<String, dynamic> toJson() => _$MarketCapAllocationDtoToJson(this);
}

/// Market cap segment data
@JsonSerializable()
class MarketCapSegmentDto {
  final String segmentName;
  final double weightPercentage;
  final double segmentValue;
  final int numberOfStocks;
  final List<String> topStocks;

  const MarketCapSegmentDto({
    required this.segmentName,
    required this.weightPercentage,
    required this.segmentValue,
    required this.numberOfStocks,
    required this.topStocks,
  });

  factory MarketCapSegmentDto.fromJson(Map<String, dynamic> json) =>
      _$MarketCapSegmentDtoFromJson(json);

  Map<String, dynamic> toJson() => _$MarketCapSegmentDtoToJson(this);
}
