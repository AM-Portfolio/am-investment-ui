import '../dtos/portfolio_analytics_request_dto.dart';
import '../dtos/portfolio_analytics_response_dto.dart';
import '../../domain/entities/portfolio_analytics_request.dart';
import '../../domain/entities/portfolio_analytics.dart';

/// Mapper for portfolio analytics data conversion between DTOs and entities
class PortfolioAnalyticsMapper {
  // Request mapping methods

  /// Convert analytics request entity to DTO
  static PortfolioAnalyticsRequestDto requestToDto(
    PortfolioAnalyticsRequest request,
  ) {
    return PortfolioAnalyticsRequestDto(
      coreIdentifiers: CoreIdentifiersDto(
        portfolioId: request.coreIdentifiers.portfolioId,
      ),
      featureToggles: FeatureTogglesDto(
        includeHeatmap: request.featureToggles.includeHeatmap,
        includeMovers: request.featureToggles.includeMovers,
        includeSectorAllocation: request.featureToggles.includeSectorAllocation,
        includeMarketCapAllocation:
            request.featureToggles.includeMarketCapAllocation,
      ),
      featureConfiguration: FeatureConfigurationDto(
        moversLimit: request.featureConfiguration.moversLimit,
      ),
      pagination: PaginationDto(
        page: request.pagination.page,
        size: request.pagination.size,
        sortBy: request.pagination.sortBy,
        sortDirection: request.pagination.sortDirection,
        returnAllData: request.pagination.returnAllData,
      ),
    );
  }

  /// Convert analytics request DTO to entity
  static PortfolioAnalyticsRequest requestFromDto(
    PortfolioAnalyticsRequestDto dto,
  ) {
    return PortfolioAnalyticsRequest(
      coreIdentifiers: CoreIdentifiers(
        portfolioId: dto.coreIdentifiers.portfolioId,
      ),
      featureToggles: FeatureToggles(
        includeHeatmap: dto.featureToggles.includeHeatmap,
        includeMovers: dto.featureToggles.includeMovers,
        includeSectorAllocation: dto.featureToggles.includeSectorAllocation,
        includeMarketCapAllocation:
            dto.featureToggles.includeMarketCapAllocation,
      ),
      featureConfiguration: FeatureConfiguration(
        moversLimit: dto.featureConfiguration.moversLimit,
      ),
      pagination: Pagination(
        page: dto.pagination.page,
        size: dto.pagination.size,
        sortBy: dto.pagination.sortBy,
        sortDirection: dto.pagination.sortDirection,
        returnAllData: dto.pagination.returnAllData,
      ),
    );
  }

  // Response mapping methods

  /// Convert JSON to analytics response DTO
  static PortfolioAnalyticsResponseDto responseFromJson(
    Map<String, dynamic> json,
  ) {
    return PortfolioAnalyticsResponseDto.fromJson(json);
  }

  /// Convert analytics response DTO to entity
  static PortfolioAnalytics responseFromDto(PortfolioAnalyticsResponseDto dto) {
    return PortfolioAnalytics(
      portfolioId: dto.portfolioId,
      timestamp: DateTime.parse(dto.timestamp),
      analytics: _analyticsFromDto(dto.analytics),
    );
  }

  /// Convert analytics DTO to entity
  static Analytics _analyticsFromDto(AnalyticsDto dto) {
    return Analytics(
      heatmap: dto.heatmap != null ? _heatmapFromDto(dto.heatmap!) : null,
      movers: dto.movers != null ? _moversFromDto(dto.movers!) : null,
      sectorAllocation: dto.sectorAllocation != null
          ? _sectorAllocationFromDto(dto.sectorAllocation!)
          : null,
      marketCapAllocation: dto.marketCapAllocation != null
          ? _marketCapAllocationFromDto(dto.marketCapAllocation!)
          : null,
    );
  }

  /// Convert heatmap DTO to entity
  static Heatmap _heatmapFromDto(HeatmapDto dto) {
    return Heatmap(sectors: dto.sectors.map(_sectorFromDto).toList());
  }

  /// Convert sector DTO to entity
  static Sector _sectorFromDto(SectorDto dto) {
    return Sector(
      sectorName: dto.sectorName,
      performanceRank: dto.performanceRank,
      performance: dto.performance,
      changePercent: dto.changePercent,
      weightage: dto.weightage,
      color: dto.color,
      stockCount: dto.stockCount,
      totalValue: dto.totalValue,
      totalReturnAmount: dto.totalReturnAmount,
      stocks: dto.stocks.map(_stockFromDto).toList(),
    );
  }

  /// Convert stock DTO to entity
  static Stock _stockFromDto(StockDto dto) {
    return Stock(
      symbol: dto.symbol,
      companyName: dto.companyName,
      lastPrice: dto.lastPrice,
      changeAmount: dto.changeAmount,
      changePercent: dto.changePercent,
      sector: dto.sector,
      quantity: dto.quantity,
      avgPrice: dto.avgPrice,
      marketValue: dto.marketValue,
      totalReturn: dto.totalReturn,
    );
  }

  /// Convert movers DTO to entity
  static Movers _moversFromDto(MoversDto dto) {
    return Movers(
      topGainers: dto.topGainers.map(_stockFromDto).toList(),
      topLosers: dto.topLosers.map(_stockFromDto).toList(),
    );
  }

  /// Convert sector allocation DTO to entity
  static SectorAllocation _sectorAllocationFromDto(SectorAllocationDto dto) {
    return SectorAllocation(
      sectorWeights: dto.sectorWeights.map(_sectorWeightFromDto).toList(),
      industryWeights: dto.industryWeights.map(_industryWeightFromDto).toList(),
    );
  }

  /// Convert sector weight DTO to entity
  static SectorWeight _sectorWeightFromDto(SectorWeightDto dto) {
    return SectorWeight(
      sectorName: dto.sectorName,
      weightPercentage: dto.weightPercentage,
      marketCap: dto.marketCap,
      topStocks: dto.topStocks,
    );
  }

  /// Convert industry weight DTO to entity
  static IndustryWeight _industryWeightFromDto(IndustryWeightDto dto) {
    return IndustryWeight(
      industryName: dto.industryName,
      parentSector: dto.parentSector,
      weightPercentage: dto.weightPercentage,
      marketCap: dto.marketCap,
      topStocks: dto.topStocks,
    );
  }

  /// Convert market cap allocation DTO to entity
  static MarketCapAllocation _marketCapAllocationFromDto(
    MarketCapAllocationDto dto,
  ) {
    return MarketCapAllocation(
      segments: dto.segments.map(_marketCapSegmentFromDto).toList(),
    );
  }

  /// Convert market cap segment DTO to entity
  static MarketCapSegment _marketCapSegmentFromDto(MarketCapSegmentDto dto) {
    return MarketCapSegment(
      segmentName: dto.segmentName,
      weightPercentage: dto.weightPercentage,
      segmentValue: dto.segmentValue,
      numberOfStocks: dto.numberOfStocks,
      topStocks: dto.topStocks,
    );
  }

  // Helper method to create default analytics request

  /// Create a default analytics request for a portfolio
  static PortfolioAnalyticsRequest createDefaultRequest(String portfolioId) {
    return PortfolioAnalyticsRequest(
      coreIdentifiers: CoreIdentifiers(portfolioId: portfolioId),
      featureToggles: const FeatureToggles(
        includeHeatmap: true,
        includeMovers: true,
        includeSectorAllocation: true,
        includeMarketCapAllocation: true,
      ),
      featureConfiguration: const FeatureConfiguration(moversLimit: 10),
      pagination: const Pagination(
        page: 0,
        size: 20,
        sortBy: 'performance',
        sortDirection: 'DESC',
        returnAllData: false,
      ),
    );
  }
}
