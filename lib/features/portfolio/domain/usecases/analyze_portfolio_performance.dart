import '../entities/portfolio_summary.dart';
import '../repositories/portfolio_repository.dart';

/// Use case for analyzing portfolio performance
class AnalyzePortfolioPerformance {
  final PortfolioRepository _repository;

  const AnalyzePortfolioPerformance(this._repository);

  /// Get sector allocation analysis
  Future<List<SectorAllocation>> getSectorAllocation(String userId) async {
    if (userId.isEmpty) {
      throw ArgumentError('User ID cannot be empty');
    }

    return await _repository.getSectorAllocation(userId);
  }

  /// Get top performing holdings
  Future<List<TopPerformer>> getTopPerformers(String userId, {int limit = 5}) async {
    if (userId.isEmpty) {
      throw ArgumentError('User ID cannot be empty');
    }

    if (limit <= 0) {
      throw ArgumentError('Limit must be greater than 0');
    }

    return await _repository.getTopPerformers(userId, limit: limit);
  }

  /// Get worst performing holdings
  Future<List<TopPerformer>> getWorstPerformers(String userId, {int limit = 5}) async {
    if (userId.isEmpty) {
      throw ArgumentError('User ID cannot be empty');
    }

    if (limit <= 0) {
      throw ArgumentError('Limit must be greater than 0');
    }

    return await _repository.getWorstPerformers(userId, limit: limit);
  }
}