import '../repositories/portfolio_repository.dart';

/// Use case for refreshing portfolio data
class RefreshPortfolioData {
  final PortfolioRepository _repository;

  const RefreshPortfolioData(this._repository);

  /// Refresh all portfolio data for a user
  Future<void> call(String userId) async {
    if (userId.isEmpty) {
      throw ArgumentError('User ID cannot be empty');
    }

    await _repository.refreshPortfolioData(userId);
  }
}