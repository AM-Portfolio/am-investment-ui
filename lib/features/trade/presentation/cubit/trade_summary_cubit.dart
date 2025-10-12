import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../internal/domain/entities/trade_entities.dart';
import '../../internal/domain/usecases/trade_usecases.dart';

part 'trade_summary_cubit.freezed.dart';
part 'trade_summary_state.dart';

class TradeSummaryCubit extends Cubit<TradeSummaryState> {
  TradeSummaryCubit({
    required this.portfolioId,
    required GetPortfolioSummaryUseCase getPortfolioSummary,
    required CalculatePortfolioPerformanceUseCase calculatePerformance,
  }) : _getPortfolioSummary = getPortfolioSummary,
       _calculatePerformance = calculatePerformance,
       super(const TradeSummaryState.initial());
  final String portfolioId;
  final GetPortfolioSummaryUseCase _getPortfolioSummary;
  final CalculatePortfolioPerformanceUseCase _calculatePerformance;

  Future<void> loadSummary({bool forceRefresh = false}) async {
    if (!forceRefresh && state is TradeSummaryLoaded) return;

    try {
      emit(const TradeSummaryState.loading());

      // Load portfolio summary and performance in parallel
      final results = await Future.wait([
        _getPortfolioSummary(portfolioId),
        _calculatePerformance(portfolioId),
      ]);

      final summary = results[0] as TradePortfolioSummary;
      final performance = results[1] as PortfolioPerformance;

      emit(
        TradeSummaryState.loaded(
          summary: summary,
          performance: performance,
          lastRefresh: DateTime.now(),
        ),
      );
    } catch (error, stackTrace) {
      emit(
        TradeSummaryState.error(
          message: _getErrorMessage(error),
          error: error,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  Future<void> refreshSummary() async {
    await loadSummary(forceRefresh: true);
  }

  void retryLoading() {
    loadSummary();
  }

  String _getErrorMessage(error) {
    if (error.toString().contains('NetworkException')) {
      return 'Network connection failed. Please check your internet connection.';
    } else if (error.toString().contains('ServerException')) {
      return 'Server error occurred. Please try again later.';
    } else {
      return 'An unexpected error occurred. Please try again.';
    }
  }
}
