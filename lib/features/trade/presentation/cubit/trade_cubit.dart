import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../internal/domain/entities/trade_entities.dart';
import '../../internal/domain/usecases/trade_usecases.dart';

part 'trade_cubit.freezed.dart';
part 'trade_state.dart';

class TradeCubit extends Cubit<TradeState> {
  final GetPortfoliosByOwnerUseCase _getPortfoliosByOwner;
  final GetPortfolioSummaryUseCase _getPortfolioSummary;
  final GetTradeHoldingsUseCase _getTradeHoldings;
  final GetTradeDetailsByIdsUseCase _getTradeDetails;
  final SearchTradesUseCase _searchTrades;
  final RefreshPortfolioDataUseCase _refreshPortfolioData;
  final ClearCacheUseCase _clearCache;
  final GetTotalTradeCountUseCase _getTotalTradeCount;

  TradeCubit({
    required GetPortfoliosByOwnerUseCase getPortfoliosByOwner,
    required GetPortfolioSummaryUseCase getPortfolioSummary,
    required GetTradeHoldingsUseCase getTradeHoldings,
    required GetTradeDetailsByIdsUseCase getTradeDetails,
    required SearchTradesUseCase searchTrades,
    required RefreshPortfolioDataUseCase refreshPortfolioData,
    required ClearCacheUseCase clearCache,
    required GetTotalTradeCountUseCase getTotalTradeCount,
  }) : _getPortfoliosByOwner = getPortfoliosByOwner,
       _getPortfolioSummary = getPortfolioSummary,
       _getTradeHoldings = getTradeHoldings,
       _getTradeDetails = getTradeDetails,
       _searchTrades = searchTrades,
       _refreshPortfolioData = refreshPortfolioData,
       _clearCache = clearCache,
       _getTotalTradeCount = getTotalTradeCount,
       super(const TradeState.initial());

  // Step 1: Load portfolios (same pattern as portfolio cubit)
  Future<void> loadPortfolios(String ownerId) async {
    try {
      emit(const TradeState.loading());
      
      final portfolios = await _getPortfoliosByOwner(ownerId);
      
      emit(TradeState.loaded(
        portfolios: portfolios,
        holdings: const [],
        currentPage: 1,
        hasMore: false,
      ));
    } catch (error, stackTrace) {
      emit(TradeState.error(
        message: _getErrorMessage(error),
        error: error,
        stackTrace: stackTrace,
      ));
    }
  }

  // Step 2: Load portfolio summary and holdings (same pattern as portfolio cubit)
  Future<void> loadPortfolioDetails(String portfolioId) async {
    try {
      emit(const TradeState.loading());
      
      // Load summary and holdings in parallel (like portfolio feature)
      final results = await Future.wait([
        _getPortfolioSummary(portfolioId),
        _getTradeHoldings(TradeHoldingsParams(portfolioId: portfolioId)),
        _getTotalTradeCount(portfolioId),
      ]);
      
      final summary = results[0] as TradePortfolioSummary;
      final holdings = results[1] as List<TradeHolding>;
      final totalCount = results[2] as int;
      
      emit(TradeState.loaded(
        portfolios: state.maybeWhen(
          loaded: (portfolios, _, __, ___, ____, _____, ______, _______) => portfolios,
          orElse: () => [],
        ),
        selectedPortfolioSummary: summary,
        holdings: holdings,
        totalCount: totalCount,
        currentPage: 1,
        hasMore: holdings.length >= 50,
      ));
    } catch (error, stackTrace) {
      emit(TradeState.error(
        message: _getErrorMessage(error),
        error: error,
        stackTrace: stackTrace,
      ));
    }
  }

  // Load more holdings (pagination - same pattern as portfolio cubit)
  Future<void> loadMoreHoldings(String portfolioId) async {
    final currentState = state;
    if (currentState is! TradeLoaded || !currentState.hasMore) return;

    try {
      final nextPage = currentState.currentPage + 1;
      final moreHoldings = await _getTradeHoldings(
        TradeHoldingsParams(
          portfolioId: portfolioId,
          page: nextPage,
        ),
      );

      emit(currentState.copyWith(
        holdings: [...currentState.holdings, ...moreHoldings],
        currentPage: nextPage,
        hasMore: moreHoldings.length >= 50,
      ));
    } catch (error, stackTrace) {
      emit(TradeState.error(
        message: _getErrorMessage(error),
        error: error,
        stackTrace: stackTrace,
      ));
    }
  }

  // Search trades (same pattern as portfolio cubit)
  Future<void> searchTrades({
    required String portfolioId,
    required String query,
  }) async {
    if (query.trim().isEmpty) {
      await loadPortfolioDetails(portfolioId);
      return;
    }

    try {
      emit(const TradeState.loading());
      
      final searchResults = await _searchTrades(
        SearchTradesParams(
          portfolioId: portfolioId,
          query: query,
        ),
      );
      
      emit(TradeState.loaded(
        portfolios: state.maybeWhen(
          loaded: (portfolios, _, __, ___, ____, _____, ______, _______) => portfolios,
          orElse: () => [],
        ),
        selectedPortfolioSummary: state.maybeWhen(
          loaded: (_, summary, __, ___, ____, _____, ______, _______) => summary,
          orElse: () => null,
        ),
        holdings: searchResults,
        currentPage: 1,
        hasMore: false,
        searchQuery: query,
      ));
    } catch (error, stackTrace) {
      emit(TradeState.error(
        message: _getErrorMessage(error),
        error: error,
        stackTrace: stackTrace,
      ));
    }
  }

  // Filter holdings (same pattern as portfolio cubit)
  Future<void> filterHoldings({
    required String portfolioId,
    TradeStatus? statusFilter,
    TradeType? typeFilter,
  }) async {
    try {
      emit(const TradeState.loading());
      
      final filteredHoldings = await _getTradeHoldings(
        TradeHoldingsParams(
          portfolioId: portfolioId,
          statusFilter: statusFilter,
          typeFilter: typeFilter,
        ),
      );
      
      emit(TradeState.loaded(
        portfolios: state.maybeWhen(
          loaded: (portfolios, _, __, ___, ____, _____, ______, _______) => portfolios,
          orElse: () => [],
        ),
        selectedPortfolioSummary: state.maybeWhen(
          loaded: (_, summary, __, ___, ____, _____, ______, _______) => summary,
          orElse: () => null,
        ),
        holdings: filteredHoldings,
        currentPage: 1,
        hasMore: filteredHoldings.length >= 50,
        statusFilter: statusFilter,
        typeFilter: typeFilter,
      ));
    } catch (error, stackTrace) {
      emit(TradeState.error(
        message: _getErrorMessage(error),
        error: error,
        stackTrace: stackTrace,
      ));
    }
  }

  // View trade details (same pattern as portfolio cubit)
  Future<void> viewTradeDetails(List<String> tradeIds) async {
    try {
      final currentState = state;
      if (currentState is TradeLoaded) {
        emit(currentState.copyWith(isLoadingDetails: true));
      }
      
      final tradeDetails = await _getTradeDetails(tradeIds);
      
      if (state is TradeLoaded) {
        emit((state as TradeLoaded).copyWith(
          isLoadingDetails: false,
          selectedTradeDetails: tradeDetails,
        ));
      }
    } catch (error, stackTrace) {
      if (state is TradeLoaded) {
        emit((state as TradeLoaded).copyWith(
          isLoadingDetails: false,
        ));
      }
      // Optionally emit error or handle silently
    }
  }

  // Refresh data (same pattern as portfolio cubit)
  Future<void> refreshData(String portfolioId) async {
    try {
      await _refreshPortfolioData(portfolioId);
      await loadPortfolioDetails(portfolioId);
    } catch (error, stackTrace) {
      emit(TradeState.error(
        message: _getErrorMessage(error),
        error: error,
        stackTrace: stackTrace,
      ));
    }
  }

  // Clear cache (same pattern as portfolio cubit)
  Future<void> clearCache() async {
    try {
      await _clearCache();
    } catch (error) {
      // Handle error silently or emit error state
    }
  }

  // Reset state (same pattern as portfolio cubit)
  void reset() {
    emit(const TradeState.initial());
  }

  // Private helper methods (same pattern as portfolio cubit)
  String _getErrorMessage(dynamic error) {
    if (error.toString().contains('NetworkException')) {
      return 'Network connection failed. Please check your internet connection.';
    } else if (error.toString().contains('ServerException')) {
      return 'Server error occurred. Please try again later.';
    } else if (error.toString().contains('ArgumentError')) {
      return 'Invalid input provided. Please check your data.';
    } else {
      return 'An unexpected error occurred. Please try again.';
    }
  }
}
