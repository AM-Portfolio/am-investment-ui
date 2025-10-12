import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../data/models/trade_portfolio.dart';
import '../../data/models/trade_holding.dart';
import '../../data/models/paginated_response.dart';
import '../../data/models/calendar_data.dart';
import '../../data/services/trade_api_service.dart';
import '../../data/services/trade_mock_service.dart';

part 'unified_trade_state.dart';
part 'unified_trade_cubit.freezed.dart';

class UnifiedTradeCubit extends Cubit<UnifiedTradeState> {
  final TradeApiService? apiService;
  final TradeMockService? mockService;
  final bool useMockData;

  UnifiedTradeCubit({
    this.apiService,
    this.mockService,
    this.useMockData = false,
  }) : super(const UnifiedTradeState.initial());

  Future<void> loadPortfoliosByOwner(String ownerId) async {
    emit(const UnifiedTradeState.loading());
    
    try {
      if (useMockData) {
        final portfolios = await mockService!.getPortfoliosByOwner(ownerId);
        emit(UnifiedTradeState.portfoliosLoaded(portfolios));
      } else {
        try {
          final portfolios = await apiService!.getPortfoliosByOwner(ownerId);
          emit(UnifiedTradeState.portfoliosLoaded(portfolios));
        } catch (apiError) {
          // Fallback to mock data if API fails
          final portfolios = await mockService!.getPortfoliosByOwner(ownerId);
          emit(UnifiedTradeState.portfoliosLoaded(portfolios));
        }
      }
    } catch (e) {
      emit(UnifiedTradeState.error(e.toString()));
    }
  }

  Future<void> loadPortfolioSummary(String portfolioId) async {
    emit(const UnifiedTradeState.loading());
    
    try {
      if (useMockData) {
        final summary = await mockService!.getPortfolioSummary(portfolioId);
        emit(UnifiedTradeState.portfolioSummaryLoaded(summary));
      } else {
        try {
          final summary = await apiService!.getPortfolioSummary(portfolioId);
          emit(UnifiedTradeState.portfolioSummaryLoaded(summary));
        } catch (apiError) {
          // Fallback to mock data if API fails
          final summary = await mockService!.getPortfolioSummary(portfolioId);
          emit(UnifiedTradeState.portfolioSummaryLoaded(summary));
        }
      }
    } catch (e) {
      emit(UnifiedTradeState.error(e.toString()));
    }
  }

  Future<void> loadPortfolioHoldings(
    String portfolioId, {
    int page = 0,
    int size = 50,
    String? sort,
  }) async {
    emit(const UnifiedTradeState.loading());
    
    try {
      if (useMockData) {
        final holdings = await mockService!.getPortfolioHoldings(
          portfolioId,
          page: page,
          size: size,
          sort: sort,
        );
        emit(UnifiedTradeState.holdingsLoaded(holdings));
      } else {
        try {
          final holdings = await apiService!.getPortfolioHoldings(
            portfolioId,
            page: page,
            size: size,
            sort: sort,
          );
          emit(UnifiedTradeState.holdingsLoaded(holdings));
        } catch (apiError) {
          // Fallback to mock data if API fails
          final holdings = await mockService!.getPortfolioHoldings(
            portfolioId,
            page: page,
            size: size,
            sort: sort,
          );
          emit(UnifiedTradeState.holdingsLoaded(holdings));
        }
      }
    } catch (e) {
      emit(UnifiedTradeState.error(e.toString()));
    }
  }

  Future<void> loadTradeDetails(List<String> tradeIds) async {
    emit(const UnifiedTradeState.loading());
    
    try {
      if (useMockData) {
        final details = await mockService!.getTradeDetailsByIds(tradeIds);
        emit(UnifiedTradeState.tradeDetailsLoaded(details));
      } else {
        try {
          final details = await apiService!.getTradeDetailsByIds(tradeIds);
          emit(UnifiedTradeState.tradeDetailsLoaded(details));
        } catch (apiError) {
          // Fallback to mock data if API fails
          final details = await mockService!.getTradeDetailsByIds(tradeIds);
          emit(UnifiedTradeState.tradeDetailsLoaded(details));
        }
      }
    } catch (e) {
      emit(UnifiedTradeState.error(e.toString()));
    }
  }

  Future<void> loadMonthlyCalendar(
    String portfolioId,
    int year,
    int month,
  ) async {
    emit(const UnifiedTradeState.loading());
    
    try {
      if (useMockData) {
        final calendar = await mockService!.getMonthlyCalendar(portfolioId, year, month);
        emit(UnifiedTradeState.calendarLoaded(calendar));
      } else {
        try {
          final calendar = await apiService!.getMonthlyCalendar(portfolioId, year, month);
          emit(UnifiedTradeState.calendarLoaded(calendar));
        } catch (apiError) {
          // Fallback to mock data if API fails
          final calendar = await mockService!.getMonthlyCalendar(portfolioId, year, month);
          emit(UnifiedTradeState.calendarLoaded(calendar));
        }
      }
    } catch (e) {
      emit(UnifiedTradeState.error(e.toString()));
    }
  }

  Future<void> loadQuarterCalendar(
    String portfolioId,
    int year,
    int quarter,
  ) async {
    emit(const UnifiedTradeState.loading());
    
    try {
      if (useMockData) {
        final calendar = await mockService!.getQuarterCalendar(portfolioId, year, quarter);
        emit(UnifiedTradeState.calendarLoaded(calendar));
      } else {
        try {
          final calendar = await apiService!.getQuarterCalendar(portfolioId, year, quarter);
          emit(UnifiedTradeState.calendarLoaded(calendar));
        } catch (apiError) {
          // Fallback to mock data if API fails
          final calendar = await mockService!.getQuarterCalendar(portfolioId, year, quarter);
          emit(UnifiedTradeState.calendarLoaded(calendar));
        }
      }
    } catch (e) {
      emit(UnifiedTradeState.error(e.toString()));
    }
  }
}
