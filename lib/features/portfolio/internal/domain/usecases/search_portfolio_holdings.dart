import '../entities/portfolio_holding.dart';
import '../repositories/portfolio_repository.dart';

/// Use case for searching portfolio holdings
class SearchPortfolioHoldings {
  final PortfolioRepository _repository;

  const SearchPortfolioHoldings(this._repository);

  /// Search holdings by symbol or company name
  Future<List<PortfolioHolding>> call(String userId, String query) async {
    if (userId.isEmpty) {
      throw ArgumentError('User ID cannot be empty');
    }

    if (query.isEmpty) {
      // Return empty list for empty query
      return [];
    }

    return await _repository.searchHoldings(userId, query);
  }

  /// Get holding details by symbol
  Future<PortfolioHolding?> getHoldingDetails(String userId, String symbol) async {
    if (userId.isEmpty) {
      throw ArgumentError('User ID cannot be empty');
    }

    if (symbol.isEmpty) {
      throw ArgumentError('Symbol cannot be empty');
    }

    return await _repository.getHoldingDetails(userId, symbol);
  }
}