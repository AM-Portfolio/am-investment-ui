import '../models/portfolio_dto.dart';

/// Abstract data source for portfolio data
abstract class PortfolioRemoteDataSource {
  /// Get portfolio holdings from remote API
  Future<PortfolioHoldingsDto> getPortfolioHoldings(String userId);
  
  /// Get portfolio summary from remote API
  Future<PortfolioSummaryDto> getPortfolioSummary(String userId);
}

/// Concrete implementation of portfolio remote data source
class PortfolioRemoteDataSourceImpl implements PortfolioRemoteDataSource {
  // We'll use the existing API client from core
  // final PortfolioClient _apiClient;
  
  // For now, we'll use mock data until API client is properly integrated
  // const PortfolioRemoteDataSourceImpl(this._apiClient);

  @override
  Future<PortfolioHoldingsDto> getPortfolioHoldings(String userId) async {
    // TODO: Replace with actual API call
    // return await _apiClient.getPortfolioHoldings(userId);
    
    // For now, return mock data
    await Future.delayed(const Duration(milliseconds: 500));
    
    return PortfolioHoldingsDto(
      userId: userId,
      holdings: [],
      lastUpdated: DateTime.now(),
    );
  }

  @override
  Future<PortfolioSummaryDto> getPortfolioSummary(String userId) async {
    // TODO: Replace with actual API call
    // return await _apiClient.getPortfolioSummary(userId);
    
    // For now, return mock data
    await Future.delayed(const Duration(milliseconds: 300));
    
    return PortfolioSummaryDto(
      userId: userId,
      totalValue: 0.0,
      totalInvested: 0.0,
      totalGainLoss: 0.0,
      totalGainLossPercentage: 0.0,
      todayChange: 0.0,
      todayChangePercentage: 0.0,
      totalHoldings: 0,
      lastUpdated: DateTime.now(),
    );
  }
}