import '../domain/entities/portfolio/portfolio_holdings.dart';
import '../domain/entities/portfolio/portfolio_summary.dart';

/// Client for portfolio operations
class PortfolioClient {
  final String baseUrl;

  PortfolioClient({required this.baseUrl});

  /// Get portfolio holdings
  Future<PortfolioHoldings> getHoldings() async {
    // Mock implementation - replace with actual API call
    await Future.delayed(const Duration(seconds: 1));
    return PortfolioHoldings.empty();
  }

  /// Get portfolio summary
  Future<PortfolioSummary> getSummary() async {
    // Mock implementation - replace with actual API call
    await Future.delayed(const Duration(seconds: 1));
    return PortfolioSummary.empty();
  }
}