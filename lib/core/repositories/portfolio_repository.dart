import '../models/portfolio/portfolio_models.dart';

abstract class PortfolioRepository {
  Future<PortfolioHoldings> getHoldings(String userId);
  Future<PortfolioSummary> getSummary(String userId);
}

class PortfolioRepositoryImpl implements PortfolioRepository {
  @override
  Future<PortfolioHoldings> getHoldings(String userId) async {
    // TODO: Implement API call
    throw UnimplementedError();
  }

  @override
  Future<PortfolioSummary> getSummary(String userId) async {
    // TODO: Implement API call
    throw UnimplementedError();
  }
}