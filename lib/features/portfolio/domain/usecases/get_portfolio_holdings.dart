import '../entities/portfolio_holding.dart';
import '../repositories/portfolio_repository.dart';

/// Use case for getting portfolio holdings
class GetPortfolioHoldings {
  final PortfolioRepository _repository;

  const GetPortfolioHoldings(this._repository);

  /// Execute the use case
  Future<PortfolioHoldings> call(String userId) async {
    if (userId.isEmpty) {
      throw ArgumentError('User ID cannot be empty');
    }

    return await _repository.getPortfolioHoldings(userId);
  }

  /// Execute with stream for real-time updates
  Stream<PortfolioHoldings> watchHoldings(String userId) {
    if (userId.isEmpty) {
      throw ArgumentError('User ID cannot be empty');
    }

    return _repository.watchPortfolioHoldings(userId);
  }
}