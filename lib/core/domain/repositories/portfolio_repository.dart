import '../../domain/entities/portfolio/portfolio_holdings.dart';
import '../../domain/entities/portfolio/portfolio_summary.dart';

/// Repository interface for portfolio data
/// Defines the contract for portfolio data access
abstract class PortfolioRepository {
  /// Get portfolio holdings for a user
  Future<PortfolioHoldings> getPortfolioHoldings(String userId);
  
  /// Get portfolio summary for a user
  Future<PortfolioSummary> getPortfolioSummary(String userId);
  
  /// Refresh portfolio holdings data
  Future<PortfolioHoldings> refreshPortfolioHoldings(String userId);
  
  /// Refresh portfolio summary data
  Future<PortfolioSummary> refreshPortfolioSummary(String userId);
  
  /// Stream of portfolio holdings updates (for real-time data)
  Stream<PortfolioHoldings> portfolioHoldingsUpdatesStream(String userId);
  
  /// Stream of portfolio summary updates (for real-time data)
  Stream<PortfolioSummary> portfolioSummaryUpdatesStream(String userId);
  
  /// Check if holdings data is cached and fresh
  bool isHoldingsCachedDataFresh(String userId);
  
  /// Check if summary data is cached and fresh
  bool isSummaryCachedDataFresh(String userId);
  
  /// Clear cached holdings data
  Future<void> clearHoldingsCache(String userId);
  
  /// Clear cached summary data
  Future<void> clearSummaryCache(String userId);
  
  /// Clear all cached data
  Future<void> clearAllCache(String userId);
}