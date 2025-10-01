import 'package:json_annotation/json_annotation.dart';

part 'portfolio_analytics_request_dto.g.dart';

/// DTO for portfolio analytics request
@JsonSerializable()
class PortfolioAnalyticsRequestDto {
  final CoreIdentifiersDto coreIdentifiers;
  final FeatureTogglesDto featureToggles;
  final FeatureConfigurationDto featureConfiguration;
  final PaginationDto pagination;

  const PortfolioAnalyticsRequestDto({
    required this.coreIdentifiers,
    required this.featureToggles,
    required this.featureConfiguration,
    required this.pagination,
  });

  factory PortfolioAnalyticsRequestDto.fromJson(Map<String, dynamic> json) =>
      _$PortfolioAnalyticsRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => _$PortfolioAnalyticsRequestDtoToJson(this);
}

/// Core identifiers for the analytics request
@JsonSerializable()
class CoreIdentifiersDto {
  final String portfolioId;

  const CoreIdentifiersDto({required this.portfolioId});

  factory CoreIdentifiersDto.fromJson(Map<String, dynamic> json) =>
      _$CoreIdentifiersDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CoreIdentifiersDtoToJson(this);
}

/// Feature toggles to control what analytics are included
@JsonSerializable()
class FeatureTogglesDto {
  final bool includeHeatmap;
  final bool includeMovers;
  final bool includeSectorAllocation;
  final bool includeMarketCapAllocation;

  const FeatureTogglesDto({
    required this.includeHeatmap,
    required this.includeMovers,
    required this.includeSectorAllocation,
    required this.includeMarketCapAllocation,
  });

  factory FeatureTogglesDto.fromJson(Map<String, dynamic> json) =>
      _$FeatureTogglesDtoFromJson(json);

  Map<String, dynamic> toJson() => _$FeatureTogglesDtoToJson(this);
}

/// Configuration for analytics features
@JsonSerializable()
class FeatureConfigurationDto {
  final int moversLimit;

  const FeatureConfigurationDto({required this.moversLimit});

  factory FeatureConfigurationDto.fromJson(Map<String, dynamic> json) =>
      _$FeatureConfigurationDtoFromJson(json);

  Map<String, dynamic> toJson() => _$FeatureConfigurationDtoToJson(this);
}

/// Pagination configuration
@JsonSerializable()
class PaginationDto {
  final int page;
  final int size;
  final String sortBy;
  final String sortDirection;
  final bool returnAllData;

  const PaginationDto({
    required this.page,
    required this.size,
    required this.sortBy,
    required this.sortDirection,
    required this.returnAllData,
  });

  factory PaginationDto.fromJson(Map<String, dynamic> json) =>
      _$PaginationDtoFromJson(json);

  Map<String, dynamic> toJson() => _$PaginationDtoToJson(this);
}
