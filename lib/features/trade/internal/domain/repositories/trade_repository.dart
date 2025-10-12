import '../entities/trade_entities.dart';
import '../usecases/trade_usecases.dart';

abstract class TradeRepository {
  // Portfolio Discovery (Step 1) - same pattern as portfolio
  Future<List<TradePortfolioSummary>> getPortfoliosByOwner(String ownerId);
  
  // Portfolio Analysis (Step 2) - following portfolio patterns
  Future<TradePortfolioSummary> getPortfolioSummary(String portfolioId);
  Future<List<TradeHolding>> getTradeHoldings({
    required String portfolioId,
    int page = 1,
    int limit = 50,
    String? searchQuery,
    TradeStatus? statusFilter,
    TradeType? typeFilter,
  });
  
  // Trade Details (Step 3) - trade-specific
  Future<List<TradeHolding>> getTradeDetailsByIds(List<String> tradeIds);
  
  // Search functionality (following portfolio search pattern)
  Future<List<TradeHolding>> searchTrades({
    required String portfolioId,
    required String query,
    int limit = 20,
  });
  
  // Utility methods (same pattern as portfolio)
  Future<int> getTotalTradeCount(String portfolioId);
  Future<void> clearCache();
  Future<void> refreshPortfolioData(String portfolioId);
}
    required String portfolioId,
    required String query,
    int limit = 20,
  });

  // Cache management
  Future<void> clearCache();
  Future<void> refreshPortfolioData(String portfolioId);
}
