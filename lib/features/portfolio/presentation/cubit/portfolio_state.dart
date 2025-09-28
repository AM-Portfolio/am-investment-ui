import 'package:equatable/equatable.dart';
import '../../internal/domain/entities/portfolio_summary.dart';
import '../../internal/domain/entities/portfolio_holding.dart';

/// Represents different portfolio views
enum PortfolioViewType { overview, holdings, analysis }

/// Base class for all portfolio states
abstract class PortfolioState extends Equatable {
  const PortfolioState();

  @override
  List<Object?> get props => [];
}

/// Initial state when portfolio is not loaded
class PortfolioInitial extends PortfolioState {}

/// Loading state when portfolio data is being fetched
class PortfolioLoading extends PortfolioState {}

/// Loaded state with portfolio data
class PortfolioLoaded extends PortfolioState {
  final PortfolioSummary summary;
  final List<PortfolioHolding> holdings;
  final PortfolioViewType currentView;
  final bool isRefreshing;
  final String searchQuery;
  final List<PortfolioHolding> searchResults;

  const PortfolioLoaded({
    required this.summary,
    required this.holdings,
    this.currentView = PortfolioViewType.overview,
    this.isRefreshing = false,
    this.searchQuery = '',
    this.searchResults = const [],
  });

  PortfolioLoaded copyWith({
    PortfolioSummary? summary,
    List<PortfolioHolding>? holdings,
    PortfolioViewType? currentView,
    bool? isRefreshing,
    String? searchQuery,
    List<PortfolioHolding>? searchResults,
  }) {
    return PortfolioLoaded(
      summary: summary ?? this.summary,
      holdings: holdings ?? this.holdings,
      currentView: currentView ?? this.currentView,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      searchQuery: searchQuery ?? this.searchQuery,
      searchResults: searchResults ?? this.searchResults,
    );
  }

  @override
  List<Object?> get props => [
        summary,
        holdings,
        currentView,
        isRefreshing,
        searchQuery,
        searchResults,
      ];
}

/// Error state when portfolio loading fails
class PortfolioError extends PortfolioState {
  final String message;

  const PortfolioError(this.message);

  @override
  List<Object?> get props => [message];
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