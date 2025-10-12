part of 'trade_cubit.dart';

@freezed
class TradeState with _$TradeState {
  const factory TradeState.initial() = TradeInitial;
  
  const factory TradeState.loading() = TradeLoading;
  
  const factory TradeState.loaded({
    required List<TradePortfolioSummary> portfolios,
    TradePortfolioSummary? selectedPortfolioSummary,
    required List<TradeHolding> holdings,
    @Default(0) int totalCount,
    @Default(1) int currentPage,
    @Default(false) bool hasMore,
    @Default(false) bool isLoadingDetails,
    String? searchQuery,
    TradeStatus? statusFilter,
    TradeType? typeFilter,
    List<TradeHolding>? selectedTradeDetails,
  }) = TradeLoaded;
  
  const factory TradeState.error({
    required String message,
    required Object error,
    required StackTrace stackTrace,
  }) = TradeError;
}

// Extension methods for convenience (same pattern as portfolio state)
extension TradeStateExtension on TradeState {
  bool get isLoading => this is TradeLoading;
  bool get isLoaded => this is TradeLoaded;
  bool get isError => this is TradeError;
  bool get hasData => this is TradeLoaded && (this as TradeLoaded).portfolios.isNotEmpty;
  
  List<TradePortfolioSummary> get portfolios => maybeWhen(
    loaded: (portfolios, _, __, ___, ____, _____, ______, _______, ________, ________, _________) => portfolios,
    orElse: () => [],
  );
  
  List<TradeHolding> get holdings => maybeWhen(
    loaded: (_, __, holdings, ___, ____, _____, ______, _______, ________, ________, _________) => holdings,
    orElse: () => [],
  );
  
  TradePortfolioSummary? get selectedPortfolio => maybeWhen(
    loaded: (_, summary, __, ___, ____, _____, ______, _______, ________, ________, _________) => summary,
    orElse: () => null,
  );
  
  bool get canLoadMore => maybeWhen(
    loaded: (_, __, ___, ____, _____, hasMore, ______, _______, ________, ________, _________) => hasMore,
    orElse: () => false,
  );
}
