import '../../network/dtos/portfolio/portfolio_holdings_dtos.dart';
import '../../network/dtos/portfolio/broker_holding_dtos.dart';
import '../../domain/entities/portfolio/portfolio_holdings.dart';

/// Mapper to convert between API models and domain entities
/// This provides isolation between external API structure and internal business logic
class PortfolioHoldingsMapper {
  /// Convert API response to domain entity
  static PortfolioHoldings fromApiModel(ApiPortfolioHoldingsResponse apiModel) {
    final holdings = apiModel.equityHoldings
        .map((apiHolding) => _mapEquityHolding(apiHolding))
        .toList();

    final metadata = PortfolioMetadata(
      lastUpdated: DateTime.now(),
      currency: 'USD', // Default currency, could come from API
      totalHoldings: holdings.length,
    );

    return PortfolioHoldings(
      holdings: holdings,
      metadata: metadata,
    );
  }

  /// Convert domain entity to API model (for updates/requests)
  static ApiPortfolioHoldingsResponse toApiModel(PortfolioHoldings domainModel) {
    final apiHoldings = domainModel.holdings
        .map((holding) => _mapToApiEquityHolding(holding))
        .toList();

    return ApiPortfolioHoldingsResponse(
      equityHoldings: apiHoldings,
    );
  }

  /// Map individual equity holding from API to domain
  static EquityHolding _mapEquityHolding(ApiEquityHolding apiHolding) {
    // Create identity value object
    final identity = HoldingIdentity(
      isin: apiHolding.isin,
      symbol: apiHolding.symbol,
      companyName: _extractCompanyName(apiHolding.symbol), // Could be enhanced
      sector: apiHolding.sector,
      industry: apiHolding.industry,
      marketCap: MarketCapCategory.fromString(apiHolding.marketCap),
    );

    // Create investment details value object
    final investment = InvestmentDetails(
      quantity: apiHolding.quantity,
      averageCost: apiHolding.quantity > 0 
          ? apiHolding.investmentCost / apiHolding.quantity 
          : 0.0,
      totalInvested: apiHolding.investmentCost,
      currentPrice: apiHolding.currentPrice,
      currentValue: apiHolding.currentValue,
      portfolioWeight: apiHolding.weightInPortfolio,
    );

    // Create performance metrics value object
    final performance = PerformanceMetrics(
      totalGainLoss: apiHolding.gainLoss,
      totalGainLossPercentage: apiHolding.gainLossPercentage,
      todayGainLoss: apiHolding.todayGainLoss,
      todayGainLossPercentage: apiHolding.todayGainLossPercentage,
      priceChange: apiHolding.percentageChange,
      priceChangePercentage: apiHolding.percentageChange,
    );

    // Map broker holdings with calculated percentages
    final brokerHoldings = apiHolding.brokerPortfolios
        .map((apiBroker) => BrokerHolding(
              brokerName: _formatBrokerName(apiBroker.brokerType),
              quantity: apiBroker.quantity,
              percentage: apiHolding.quantity > 0 
                  ? (apiBroker.quantity / apiHolding.quantity) * 100 
                  : 0.0,
              brokerType: apiBroker.brokerType,
            ))
        .toList();

    return EquityHolding(
      identity: identity,
      investment: investment,
      performance: performance,
      brokerHoldings: brokerHoldings,
    );
  }

  /// Map domain entity back to API model
  static ApiEquityHolding _mapToApiEquityHolding(EquityHolding domainHolding) {
    final apiBrokers = domainHolding.brokerHoldings
        .map((broker) => ApiBrokerHolding(
              brokerType: broker.brokerName,
              quantity: broker.quantity,
            ))
        .toList();

    return ApiEquityHolding(
      isin: domainHolding.identity.isin,
      symbol: domainHolding.identity.symbol,
      sector: domainHolding.identity.sector,
      industry: domainHolding.identity.industry,
      marketCap: domainHolding.identity.marketCap.displayName,
      quantity: domainHolding.investment.quantity,
      investmentCost: domainHolding.investment.totalInvested,
      currentValue: domainHolding.investment.currentValue,
      weightInPortfolio: domainHolding.investment.portfolioWeight,
      gainLoss: domainHolding.performance.totalGainLoss,
      gainLossPercentage: domainHolding.performance.totalGainLossPercentage,
      todayGainLoss: domainHolding.performance.todayGainLoss,
      todayGainLossPercentage: domainHolding.performance.todayGainLossPercentage,
      currentPrice: domainHolding.investment.currentPrice,
      percentageChange: domainHolding.performance.priceChangePercentage,
      brokerPortfolios: apiBrokers,
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

  /// Create empty portfolio for error states
  static PortfolioHoldings createEmpty() {
    return PortfolioHoldings.empty();
  }

  /// Validation helper
  static bool isValidApiResponse(ApiPortfolioHoldingsResponse? apiModel) {
    return apiModel != null && apiModel.equityHoldings.isNotEmpty;
  }
}