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

