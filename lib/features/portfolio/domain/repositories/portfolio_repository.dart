import '../entities/portfolio_holding.dart';
import '../entities/portfolio_summary.dart';

/// Repository interface for portfolio data operations
abstract class PortfolioRepository {
  /// Get portfolio holdings for a user
  Future<PortfolioHoldings> getPortfolioHoldings(String userId);
  
  /// Get portfolio summary for a user
  Future<PortfolioSummary> getPortfolioSummary(String userId);
  
  /// Get holdings stream for real-time updates
  Stream<PortfolioHoldings> watchPortfolioHoldings(String userId);
  
  /// Get summary stream for real-time updates
  Stream<PortfolioSummary> watchPortfolioSummary(String userId);
  
  /// Refresh portfolio data
  Future<void> refreshPortfolioData(String userId);
  
  /// Get holding details by symbol
  Future<PortfolioHolding?> getHoldingDetails(String userId, String symbol);
  
  /// Get sector allocation
  Future<List<SectorAllocation>> getSectorAllocation(String userId);
  
  /// Get top performers
  Future<List<TopPerformer>> getTopPerformers(String userId, {int limit = 5});
  
  /// Get worst performers
  Future<List<TopPerformer>> getWorstPerformers(String userId, {int limit = 5});
  
  /// Search holdings by symbol or company name
  Future<List<PortfolioHolding>> searchHoldings(String userId, String query);
}