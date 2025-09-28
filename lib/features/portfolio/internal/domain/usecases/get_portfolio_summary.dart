import '../entities/portfolio_summary.dart';
import '../repositories/portfolio_repository.dart';

/// Use case for getting portfolio summary
class GetPortfolioSummary {
  final PortfolioRepository _repository;

  const GetPortfolioSummary(this._repository);

  /// Execute the use case
  Future<PortfolioSummary> call(String userId) async {
    if (userId.isEmpty) {
      throw ArgumentError('User ID cannot be empty');
    }

    return await _repository.getPortfolioSummary(userId);
  }

  /// Execute with stream for real-time updates
  Stream<PortfolioSummary> watchSummary(String userId) {
    if (userId.isEmpty) {
      throw ArgumentError('User ID cannot be empty');
    }

    return _repository.watchPortfolioSummary(userId);
  }
}