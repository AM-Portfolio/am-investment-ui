part of 'unified_trade_cubit.dart';

@freezed
class UnifiedTradeState with _$UnifiedTradeState {
  const factory UnifiedTradeState.initial() = _Initial;
  const factory UnifiedTradeState.loading() = _Loading;
  const factory UnifiedTradeState.portfoliosLoaded(List<TradePortfolio> portfolios) = _PortfoliosLoaded;
  const factory UnifiedTradeState.portfolioSummaryLoaded(TradePortfolio summary) = _PortfolioSummaryLoaded;
  const factory UnifiedTradeState.holdingsLoaded(PaginatedResponse<TradeHolding> holdings) = _HoldingsLoaded;
  const factory UnifiedTradeState.tradeDetailsLoaded(List<TradeExecution> details) = _TradeDetailsLoaded;
  const factory UnifiedTradeState.calendarLoaded(CalendarData calendar) = _CalendarLoaded;
  const factory UnifiedTradeState.error(String message) = _Error;
}
