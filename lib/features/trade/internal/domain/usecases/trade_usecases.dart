import '../entities/trade_entities.dart';
import '../repositories/trade_repository.dart';

// Base use case class (same as portfolio)
abstract class UseCase<Type, Params> {
  Future<Type> call(Params params);
}

// No-params use case base class (same as portfolio)
abstract class NoParamsUseCase<Type> {
  Future<Type> call();
}

// Get portfolios by owner use case (same pattern as portfolio)
class GetPortfoliosByOwnerUseCase implements UseCase<List<TradePortfolioSummary>, String> {
  final TradeRepository _repository;

  GetPortfoliosByOwnerUseCase(this._repository);

  @override
  Future<List<TradePortfolioSummary>> call(String ownerId) async {
    if (ownerId.isEmpty) {
      throw ArgumentError('Owner ID cannot be empty');
    }
    return await _repository.getPortfoliosByOwner(ownerId);
  }
}

// Get portfolio summary use case (same pattern as portfolio)
class GetPortfolioSummaryUseCase implements UseCase<TradePortfolioSummary, String> {
  final TradeRepository _repository;

  GetPortfolioSummaryUseCase(this._repository);

  @override
  Future<TradePortfolioSummary> call(String portfolioId) async {
    if (portfolioId.isEmpty) {
      throw ArgumentError('Portfolio ID cannot be empty');
    }
    return await _repository.getPortfolioSummary(portfolioId);
  }
}

// Get trade holdings use case (following portfolio holdings pattern)
class GetTradeHoldingsUseCase implements UseCase<List<TradeHolding>, TradeHoldingsParams> {
  final TradeRepository _repository;

  GetTradeHoldingsUseCase(this._repository);

  @override
  Future<List<TradeHolding>> call(TradeHoldingsParams params) async {
    if (params.portfolioId.isEmpty) {
      throw ArgumentError('Portfolio ID cannot be empty');
    }
    if (params.page < 1) {
      throw ArgumentError('Page must be greater than 0');
    }
    if (params.limit < 1 || params.limit > 100) {
      throw ArgumentError('Limit must be between 1 and 100');
    }

    return await _repository.getTradeHoldings(
      portfolioId: params.portfolioId,
      page: params.page,
      limit: params.limit,
      searchQuery: params.searchQuery,
      statusFilter: params.statusFilter,
    );
  }
}

// Get trade details by IDs use case (trade-specific)
class GetTradeDetailsByIdsUseCase implements UseCase<List<TradeHolding>, List<String>> {
  final TradeRepository _repository;

  GetTradeDetailsByIdsUseCase(this._repository);

  @override
  Future<List<TradeHolding>> call(List<String> tradeIds) async {
    if (tradeIds.isEmpty) {
      throw ArgumentError('Trade IDs list cannot be empty');
    }
    if (tradeIds.length > 50) {
      throw ArgumentError('Cannot fetch more than 50 trades at once');
    }
    return await _repository.getTradeDetailsByIds(tradeIds);
  }
}

// Search trades use case (following portfolio search pattern)
class SearchTradesUseCase implements UseCase<List<TradeHolding>, SearchTradesParams> {
  final TradeRepository _repository;

  SearchTradesUseCase(this._repository);

  @override
  Future<List<TradeHolding>> call(SearchTradesParams params) async {
    if (params.portfolioId.isEmpty) {
      throw ArgumentError('Portfolio ID cannot be empty');
    }
    if (params.query.trim().isEmpty) {
      throw ArgumentError('Search query cannot be empty');
    }
    if (params.query.length < 2) {
      throw ArgumentError('Search query must be at least 2 characters');
    }

    return await _repository.searchTrades(
      portfolioId: params.portfolioId,
      query: params.query.trim(),
      limit: params.limit,
    );
  }
}

// Refresh portfolio data use case (same pattern as portfolio)
class RefreshPortfolioDataUseCase implements UseCase<void, String> {
  final TradeRepository _repository;

  RefreshPortfolioDataUseCase(this._repository);

  @override
  Future<void> call(String portfolioId) async {
    if (portfolioId.isEmpty) {
      throw ArgumentError('Portfolio ID cannot be empty');
    }
    return await _repository.refreshPortfolioData(portfolioId);
  }
}

// Clear cache use case (same pattern as portfolio)
class ClearCacheUseCase implements NoParamsUseCase<void> {
  final TradeRepository _repository;

  ClearCacheUseCase(this._repository);

  @override
  Future<void> call() async {
    return await _repository.clearCache();
  }
}

// Get total trade count use case (following portfolio count pattern)
class GetTotalTradeCountUseCase implements UseCase<int, String> {
  final TradeRepository _repository;

  GetTotalTradeCountUseCase(this._repository);

  @override
  Future<int> call(String portfolioId) async {
    if (portfolioId.isEmpty) {
      throw ArgumentError('Portfolio ID cannot be empty');
    }
    return await _repository.getTotalTradeCount(portfolioId);
  }
}

// Parameter classes (same pattern as portfolio)
class TradeHoldingsParams {
  final String portfolioId;
  final int page;
  final int limit;
  final String? searchQuery;
  final TradeStatus? statusFilter;
  final TradeType? typeFilter;

  const TradeHoldingsParams({
    required this.portfolioId,
    this.page = 1,
    this.limit = 50,
    this.searchQuery,
    this.statusFilter,
    this.typeFilter,
  });

  // Copy with method (same as portfolio params)
  TradeHoldingsParams copyWith({
    String? portfolioId,
    int? page,
    int? limit,
    String? searchQuery,
    TradeStatus? statusFilter,
    TradeType? typeFilter,
  }) {
    return TradeHoldingsParams(
      portfolioId: portfolioId ?? this.portfolioId,
      page: page ?? this.page,
      limit: limit ?? this.limit,
      searchQuery: searchQuery ?? this.searchQuery,
      statusFilter: statusFilter ?? this.statusFilter,
      typeFilter: typeFilter ?? this.typeFilter,
    );
  }
}

class SearchTradesParams {
  final String portfolioId;
  final String query;
  final int limit;

  const SearchTradesParams({
    required this.portfolioId,
    required this.query,
    this.limit = 20,
  });

  // Copy with method (same as portfolio params)
  SearchTradesParams copyWith({
    String? portfolioId,
    String? query,
    int? limit,
  }) {
    return SearchTradesParams(
      portfolioId: portfolioId ?? this.portfolioId,
      query: query ?? this.query,
      limit: limit ?? this.limit,
    );
  }
}
    required this.portfolioId,
    required this.viewType,
    required this.startDate,
    required this.endDate,
  });
  final String portfolioId;
  final CalendarViewType viewType;
  final DateTime startDate;
  final DateTime endDate;
}

class SearchTradesParams {
  const SearchTradesParams({
    required this.portfolioId,
    required this.query,
    this.limit = 20,
  });
  final String portfolioId;
  final String query;
  final int limit;
}

// Performance calculation result
@freezed
class PortfolioPerformance with _$PortfolioPerformance {
  const factory PortfolioPerformance({
    required String portfolioId,
    required double totalInvested,
    required double totalCurrentValue,
    required double totalPnL,
    required double returnPercentage,
    required int winningTrades,
    required int losingTrades,
    required double winRate,
    required int totalTrades,
    required Duration averageHoldingPeriod,
  }) = _PortfolioPerformance;
}
