import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../internal/domain/entities/portfolio_holding.dart';
import '../../internal/domain/entities/portfolio_summary.dart';
import '../../internal/domain/usecases/get_portfolio_holdings.dart';
import '../../internal/domain/usecases/get_portfolio_summary.dart';
import '../../internal/domain/usecases/analyze_portfolio_performance.dart';
import '../../internal/domain/usecases/refresh_portfolio_data.dart';
import '../../internal/domain/usecases/search_portfolio_holdings.dart';

part 'portfolio_state.dart';
part 'portfolio_cubit.freezed.dart';

/// Cubit for managing portfolio state
class PortfolioCubit extends Cubit<PortfolioState> {
  final GetPortfolioHoldings _getPortfolioHoldings;
  final GetPortfolioSummary _getPortfolioSummary;
  final AnalyzePortfolioPerformance _analyzePortfolioPerformance;
  final RefreshPortfolioData _refreshPortfolioData;
  final SearchPortfolioHoldings _searchPortfolioHoldings;

  PortfolioCubit({
    required GetPortfolioHoldings getPortfolioHoldings,
    required GetPortfolioSummary getPortfolioSummary,
    required AnalyzePortfolioPerformance analyzePortfolioPerformance,
    required RefreshPortfolioData refreshPortfolioData,
    required SearchPortfolioHoldings searchPortfolioHoldings,
  })  : _getPortfolioHoldings = getPortfolioHoldings,
        _getPortfolioSummary = getPortfolioSummary,
        _analyzePortfolioPerformance = analyzePortfolioPerformance,
        _refreshPortfolioData = refreshPortfolioData,
        _searchPortfolioHoldings = searchPortfolioHoldings,
        super(const PortfolioState.initial());

  /// Load portfolio data for a user
  Future<void> loadPortfolio(String userId) async {
    emit(const PortfolioState.loading());

    try {
      // Load both holdings and summary concurrently
      final results = await Future.wait([
        _getPortfolioHoldings(userId),
        _getPortfolioSummary(userId),
      ]);

      final holdings = results[0] as PortfolioHoldings;
      final summary = results[1] as PortfolioSummary;

      emit(PortfolioState.loaded(
        holdings: holdings,
        summary: summary,
        selectedView: PortfolioView.overview,
      ));
    } catch (error) {
      emit(PortfolioState.error(error.toString()));
    }
  }

  /// Refresh portfolio data
  Future<void> refreshPortfolio(String userId) async {
    final currentState = state;
    if (currentState is! _Loaded) return;

    emit(currentState.copyWith(isRefreshing: true));

    try {
      await _refreshPortfolioData(userId);
      await loadPortfolio(userId);
    } catch (error) {
      emit(PortfolioState.error(error.toString()));
    }
  }

  /// Change the selected view
  void changeView(PortfolioView view) {
    final currentState = state;
    if (currentState is _Loaded) {
      emit(currentState.copyWith(selectedView: view));
    }
  }

  /// Search holdings
  Future<void> searchHoldings(String userId, String query) async {
    final currentState = state;
    if (currentState is! _Loaded) return;

    try {
      final searchResults = await _searchPortfolioHoldings(userId, query);
      emit(currentState.copyWith(
        searchQuery: query,
        searchResults: searchResults,
      ));
    } catch (error) {
      // Keep current state but show error
      emit(PortfolioState.error(error.toString()));
    }
  }

  /// Clear search
  void clearSearch() {
    final currentState = state;
    if (currentState is _Loaded) {
      emit(currentState.copyWith(
        searchQuery: '',
        searchResults: [],
      ));
    }
  }

  /// Get sector allocation
  Future<void> loadSectorAllocation(String userId) async {
    final currentState = state;
    if (currentState is! _Loaded) return;

    try {
      final sectorAllocation = await _analyzePortfolioPerformance.getSectorAllocation(userId);
      emit(currentState.copyWith(sectorAllocation: sectorAllocation));
    } catch (error) {
      // Ignore sector allocation errors, keep current state
    }
  }

  /// Get top performers
  Future<void> loadTopPerformers(String userId, {int limit = 5}) async {
    final currentState = state;
    if (currentState is! _Loaded) return;

    try {
      final topPerformers = await _analyzePortfolioPerformance.getTopPerformers(userId, limit: limit);
      emit(currentState.copyWith(topPerformers: topPerformers));
    } catch (error) {
      // Ignore top performers errors, keep current state
    }
  }
}