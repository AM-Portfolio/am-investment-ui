import '../entities/trade_portfolio.dart';
import '../entities/trade_holding.dart';
import '../entities/trade_summary.dart';
import '../entities/trade_calendar.dart';

/// Repository interface for trade data operations
abstract class TradeRepository {
  /// Get list of portfolios for trading
  Future<TradePortfolioList> getTradePortfolios(String userId);

  /// Get holdings for a specific trade portfolio
  Future<TradeHoldings> getTradeHoldings(String userId, String portfolioId);

  /// Get summary/analysis for a specific trade portfolio
  Future<TradeSummary> getTradeSummary(String userId, String portfolioId);

  /// Get calendar analytics for a specific trade portfolio
  Future<TradeCalendar> getTradeCalendar(String userId, String portfolioId);

  /// Get holdings stream for real-time updates
  Stream<TradeHoldings> watchTradeHoldings(String userId, String portfolioId);

  /// Get summary stream for real-time updates
  Stream<TradeSummary> watchTradeSummary(String userId, String portfolioId);
}
