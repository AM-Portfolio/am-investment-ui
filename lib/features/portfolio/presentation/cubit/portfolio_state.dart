part of 'portfolio_cubit.dart';

/// Represents different portfolio views
enum PortfolioView {
  overview,
  holdings,
  analysis,
}

/// State for portfolio feature
@freezed
class PortfolioState with _$PortfolioState {
  /// Initial state
  const factory PortfolioState.initial() = _Initial;

  /// Loading state
  const factory PortfolioState.loading() = _Loading;

  /// Loaded state with portfolio data
  const factory PortfolioState.loaded({
    required PortfolioHoldings holdings,
    required PortfolioSummary summary,
    required PortfolioView selectedView,
    @Default(false) bool isRefreshing,
    @Default('') String searchQuery,
    @Default([]) List<PortfolioHolding> searchResults,
    @Default([]) List<SectorAllocation> sectorAllocation,
    @Default([]) List<TopPerformer> topPerformers,
  }) = _Loaded;

  /// Error state
  const factory PortfolioState.error(String message) = _Error;
}

/// Extension methods for PortfolioState
extension PortfolioStateX on PortfolioState {
  /// Check if state is loading
  bool get isLoading => this is _Loading;

  /// Check if state has data
  bool get hasData => this is _Loaded;

  /// Check if state has error
  bool get hasError => this is _Error;

  /// Get holdings if available
  PortfolioHoldings? get holdings => maybeWhen(
        loaded: (holdings, _, __, ___, ____, _____, ______, _______) => holdings,
        orElse: () => null,
      );

  /// Get summary if available
  PortfolioSummary? get summary => maybeWhen(
        loaded: (_, summary, __, ___, ____, _____, ______, _______) => summary,
        orElse: () => null,
      );

  /// Get current view
  PortfolioView get currentView => maybeWhen(
        loaded: (_, __, selectedView, ___, ____, _____, ______, _______) => selectedView,
        orElse: () => PortfolioView.overview,
      );

  /// Check if refreshing
  bool get isRefreshing => maybeWhen(
        loaded: (_, __, ___, isRefreshing, ____, _____, ______, _______) => isRefreshing,
        orElse: () => false,
      );

  /// Get search query
  String get searchQuery => maybeWhen(
        loaded: (_, __, ___, ____, searchQuery, _____, ______, _______) => searchQuery,
        orElse: () => '',
      );

  /// Get search results
  List<PortfolioHolding> get searchResults => maybeWhen(
        loaded: (_, __, ___, ____, _____, searchResults, ______, _______) => searchResults,
        orElse: () => [],
      );

  /// Check if search is active
  bool get isSearchActive => searchQuery.isNotEmpty;
}