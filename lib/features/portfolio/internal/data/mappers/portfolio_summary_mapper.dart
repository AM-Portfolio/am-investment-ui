import '../dtos/portfolio_summary_dto.dart';
import '../../domain/entities/portfolio_summary.dart';
import '../../../../../core/utils/logger.dart';

/// Mapper to convert between API models and domain entities for portfolio summary
/// This provides isolation between external API structure and internal business logic
class PortfolioSummaryMapper {
  /// Convert API response to domain entity
  static PortfolioSummary fromApiModel(PortfolioSummaryDto apiModel) {
    try {
      // Map sector allocations
      final sectorAllocations = apiModel.sectorAllocation.entries
          .map((entry) => SectorAllocation(
                sector: entry.key,
                value: 0.0, // Would need actual value from API
                percentage: entry.value,
                holdings: 0, // Would need actual count from API
              ))
          .toList();

      // Map top performers
      final topPerformers = apiModel.topPerformers
          .map((api) => TopPerformer(
                symbol: api.symbol,
                companyName: api.symbol, // Using symbol as company name
                gainLoss: api.gainAmount,
                gainLossPercentage: api.gainPercentage,
                currentValue: 0.0, // Default value, would need from API
              ))
          .toList();

      // Map worst performers (using top losers)
      final worstPerformers = apiModel.topLosers
          .map((api) => TopPerformer(
                symbol: api.symbol,
                companyName: api.symbol, // Using symbol as company name
                gainLoss: -api.lossAmount, // Negative for losses
                gainLossPercentage: -api.lossPercentage, // Negative for losses
                currentValue: 0.0, // Default value, would need from API
              ))
          .toList();

      return PortfolioSummary(
        userId: 'api-user', // Default userId since not provided in DTO
        totalValue: apiModel.totalValue,
        totalInvested: apiModel.investmentValue,
        totalGainLoss: apiModel.totalGain,
        totalGainLossPercentage: apiModel.totalGainPercentage,
        todayChange: apiModel.todaysGain,
        todayChangePercentage: apiModel.todaysGainPercentage,
        totalHoldings: _calculateTotalHoldings(apiModel.marketCapHoldings),
        lastUpdated: DateTime.now(),
        sectorAllocation: sectorAllocations,
        topPerformers: topPerformers,
        worstPerformers: worstPerformers,
      );
    } catch (e) {
      AppLogger.error('Failed to map portfolio summary from API', 
          tag: 'PortfolioSummaryMapper', error: e);
      rethrow;
    }
  }

  /// Convert domain entity to API model (for updates/requests)
  static PortfolioSummaryDto toApiModel(PortfolioSummary domainModel) {
    return PortfolioSummaryDto(
      totalValue: domainModel.totalValue,
      investmentValue: domainModel.totalInvested,
      todaysGain: domainModel.todayChange,
      totalGain: domainModel.totalGainLoss,
      totalGainPercentage: domainModel.totalGainLossPercentage,
      todaysGainPercentage: domainModel.todayChangePercentage,
      marketCapHoldings: const {}, // Empty since not available in simplified model
      sectorAllocation: _mapSectorAllocation(domainModel.sectorAllocation),
      topPerformers: _mapTopPerformers(domainModel.topPerformers),
      topLosers: _mapWorstPerformers(domainModel.worstPerformers),
    );
  }

  /// Calculate total holdings across all market caps
  static int _calculateTotalHoldings(Map<String, List<MarketCapHoldingDto>> marketCapHoldings) {
    return marketCapHoldings.values
        .fold(0, (sum, holdings) => sum + holdings.length);
  }

  /// Map sector allocation from domain to API
  static Map<String, double> _mapSectorAllocation(List<SectorAllocation> sectorAllocation) {
    final Map<String, double> result = {};
    for (final sector in sectorAllocation) {
      result[sector.sector] = sector.percentage;
    }
    return result;
  }

  /// Map top performers from domain to API
  static List<ApiTopPerformer> _mapTopPerformers(List<TopPerformer> topPerformers) {
    return topPerformers
        .map((performer) => ApiTopPerformer(
              symbol: performer.symbol,
              gainPercentage: performer.gainLossPercentage,
              gainAmount: performer.gainLoss,
            ))
        .toList();
  }

  /// Map worst performers from domain to API
  static List<ApiTopLoser> _mapWorstPerformers(List<TopPerformer> worstPerformers) {
    return worstPerformers
        .map((performer) => ApiTopLoser(
              symbol: performer.symbol,
              lossPercentage: -performer.gainLossPercentage, // Convert to positive loss
              lossAmount: -performer.gainLoss, // Convert to positive loss
            ))
        .toList();
  }

  /// Create empty portfolio summary for error states
  static PortfolioSummary createEmpty(String userId) {
    return PortfolioSummary.empty(userId);
  }

  /// Create mock portfolio summary with sample data
  static PortfolioSummary createMock({String userId = 'mock-user'}) {
    return PortfolioSummary(
      userId: userId,
      totalValue: 125000.0,
      totalInvested: 100000.0,
      totalGainLoss: 25000.0,
      totalGainLossPercentage: 25.0,
      todayChange: 1500.0,
      todayChangePercentage: 1.2,
      totalHoldings: 10,
      lastUpdated: DateTime.now(),
    );
  }

  /// Validation helper
  static bool isValidApiResponse(PortfolioSummaryDto? apiModel) {
    return apiModel != null && 
           apiModel.totalValue >= 0 && 
           apiModel.investmentValue >= 0;
  }

  /// Convert domain entity to API model (for updates/requests)
  static PortfolioSummaryDtos toApiModel(PortfolioSummary domainModel) {
    return PortfolioSummaryDtos(
      totalValue: domainModel.totalValue,
      investmentValue: 0.0, // Default value since not available in simplified model
      todaysGain: domainModel.dailyChange,
      totalGain: 0.0, // Default value since not available in simplified model
      totalGainPercentage: 0.0, // Default value since not available in simplified model
      todaysGainPercentage: 0.0, // Default value since not available in simplified model
      marketCapHoldings: const {}, // Empty since not available in simplified model
      sectorAllocation: const {}, // Empty since not available in simplified model
      topPerformers: const [], // Empty since not available in simplified model
      topLosers: const [], // Empty since not available in simplified model
    );
  }

  /// Map market cap breakdown from API to domain
  static Map<MarketCapCategory, List<MarketCapHolding>> _mapMarketCapBreakdown(
      Map<String, List<MarketCapHoldingDto>> apiBreakdown) {
    final Map<MarketCapCategory, List<MarketCapHolding>> result = {};

    for (final entry in apiBreakdown.entries) {
      final category = MarketCapCategory.fromString(entry.key);
      final holdings = entry.value
          .map((apiHolding) => _mapMarketCapHolding(apiHolding))
          .toList();
      result[category] = holdings;
    }

    return result;
  }

  /// Map individual market cap holding from API to domain
  static MarketCapHolding _mapMarketCapHolding(MarketCapHoldingDto apiHolding) {
    // Create identity
    final identity = HoldingIdentity(
      isin: apiHolding.isin,
      symbol: apiHolding.symbol,
      companyName: _extractCompanyName(apiHolding.symbol),
      sector: apiHolding.sector,
      industry: apiHolding.industry,
      marketCap: MarketCapCategory.fromString(apiHolding.marketCap),
    );

    // Map broker allocations with calculated percentages
    final brokerAllocations = apiHolding.brokerPortfolios
        .map((apiBroker) => BrokerAllocation(
              brokerName: _formatBrokerName(apiBroker.brokerType),
              quantity: apiBroker.quantity,
              percentage: apiHolding.quantity > 0 
                  ? (apiBroker.quantity / apiHolding.quantity) * 100 
                  : 0.0,
            ))
        .toList();

    return MarketCapHolding(
      identity: identity,
      quantity: apiHolding.quantity,
      investedAmount: apiHolding.investmentCost,
      brokerAllocations: brokerAllocations,
    );
  }

  /// Map top performer from API to domain
  static TopPerformer _mapTopPerformer(ApiTopPerformer apiPerformer) {
    return TopPerformer(
      symbol: apiPerformer.symbol,
      displayName: _extractCompanyName(apiPerformer.symbol),
      gainPercentage: apiPerformer.gainPercentage,
      gainAmount: apiPerformer.gainAmount,
    );
  }

  /// Map top loser from API to domain
  static TopLoser _mapTopLoser(ApiTopLoser apiLoser) {
    return TopLoser(
      symbol: apiLoser.symbol,
      displayName: _extractCompanyName(apiLoser.symbol),
      lossPercentage: apiLoser.lossPercentage,
      lossAmount: apiLoser.lossAmount,
    );
  }

  /// Generate recommendations based on API data
  static List<String> _generateRecommendations(PortfolioSummaryDtos apiModel) {
    final List<String> recommendations = [];

    // Diversification recommendations
    final dominantSector = _findDominantSector(apiModel.sectorAllocation);
    if (dominantSector != null && dominantSector.value > 40.0) {
      recommendations.add(
        'Consider reducing exposure to ${dominantSector.key} sector (${dominantSector.value.toStringAsFixed(1)}% of portfolio)'
      );
    }

    // Performance recommendations
    if (apiModel.totalGainPercentage < 0) {
      recommendations.add('Review underperforming holdings and consider rebalancing');
    } else if (apiModel.totalGainPercentage > 25) {
      recommendations.add('Excellent performance! Consider taking some profits');
    }

    // Market cap diversity
    if (apiModel.marketCapHoldings.length < 2) {
      recommendations.add('Consider diversifying across different market cap categories');
    }

    return recommendations;
  }

  /// Calculate total holdings across all market caps
  static int _calculateTotalHoldings(Map<String, List<MarketCapHoldingDto>> marketCapHoldings) {
    return marketCapHoldings.values
        .fold(0, (sum, holdings) => sum + holdings.length);
  }

  /// Find the sector with highest allocation
  static MapEntry<String, double>? _findDominantSector(Map<String, double> sectorAllocation) {
    if (sectorAllocation.isEmpty) return null;
    return sectorAllocation.entries
        .reduce((a, b) => a.value > b.value ? a : b);
  }

  /// Convert domain market cap holding back to API model
  static MarketCapHoldingDto _mapToApiMarketCapHolding(MarketCapHolding domainHolding) {
    final apiBrokers = domainHolding.brokerAllocations
        .map((broker) => BrokerHoldingDto(
              brokerType: broker.brokerName,
              quantity: broker.quantity,
            ))
        .toList();

    return MarketCapHoldingDto(
      isin: domainHolding.identity.isin,
      symbol: domainHolding.identity.symbol,
      sector: domainHolding.identity.sector,
      industry: domainHolding.identity.industry,
      marketCap: domainHolding.identity.marketCap.displayName,
      quantity: domainHolding.quantity,
      investmentCost: domainHolding.investedAmount,
      brokerPortfolios: apiBrokers,
    );
  }

  /// Convert domain top performer back to API model
  static ApiTopPerformer _mapToApiTopPerformer(TopPerformer domainPerformer) {
    return ApiTopPerformer(
      symbol: domainPerformer.symbol,
      gainPercentage: domainPerformer.gainPercentage,
      gainAmount: domainPerformer.gainAmount,
    );
  }

  /// Convert domain top loser back to API model
  static ApiTopLoser _mapToApiTopLoser(TopLoser domainLoser) {
    return ApiTopLoser(
      symbol: domainLoser.symbol,
      lossPercentage: domainLoser.lossPercentage,
      lossAmount: domainLoser.lossAmount,
    );
  }

  /// Helper to extract company name from symbol or other sources
  static String _extractCompanyName(String symbol) {
    // This could be enhanced with a mapping service or API call
    // For now, return symbol as placeholder
    return symbol;
  }

  /// Helper to format broker names consistently
  static String _formatBrokerName(String brokerType) {
    // Standardize broker names for UI display
    switch (brokerType.toLowerCase()) {
      case 'zerodha':
      case 'ZERODHA':
        return 'Zerodha';
      case 'upstox':
      case 'UPSTOX':
        return 'Upstox';
      case 'groww':
      case 'GROWW':
        return 'Groww';
      case 'angelone':
      case 'ANGELONE':
      case 'angel one':
        return 'Angel One';
      default:
        return brokerType;
    }
  }

  /// Create empty portfolio summary for error states
  static PortfolioSummary createEmpty() {
    return PortfolioSummary.empty();
  }

  /// Create mock portfolio summary with sample data
  static PortfolioSummary createMock({String userId = 'mock-user'}) {
    return PortfolioSummary(
      userId: userId,
      totalValue: 125000.0,
      dailyChange: 1500.0,
      holdings: const [],
    );
  }

  /// Validation helper
  static bool isValidApiResponse(PortfolioSummaryDtos? apiModel) {
    return apiModel != null && 
           apiModel.totalValue >= 0 && 
           apiModel.investmentValue >= 0;
  }
}