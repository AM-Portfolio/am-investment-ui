import 'package:flutter_bloc/flutter_bloc.dart';
import 'portfolio_state.dart';
import '../../internal/domain/entities/portfolio_summary.dart';
import '../../internal/domain/entities/portfolio_holding.dart';
import '../../internal/domain/usecases/get_portfolio_summary.dart';
import '../../internal/domain/usecases/get_portfolio_holdings.dart';
import '../../internal/domain/usecases/search_portfolio_holdings.dart';

class PortfolioCubit extends Cubit<PortfolioState> {
  final GetPortfolioSummary _getPortfolioSummary;
  final GetPortfolioHoldings _getPortfolioHoldings;
  final SearchPortfolioHoldings _searchPortfolioHoldings;

  PortfolioCubit(
    this._getPortfolioSummary,
    this._getPortfolioHoldings,
    this._searchPortfolioHoldings,
  ) : super(PortfolioInitial());

  Future<void> loadPortfolio(String userId) async {
    emit(PortfolioLoading());
    
    try {
      // Load both summary and holdings in parallel
      final results = await Future.wait([
        _getPortfolioSummary(userId),
        _getPortfolioHoldings(userId),
      ]);
      
      final summary = results[0] as PortfolioSummary;
      final holdings = results[1] as List<PortfolioHolding>;
      
      emit(PortfolioLoaded(
        summary: summary,
        holdings: holdings,
      ));
    } catch (error) {
      emit(PortfolioError(error.toString()));
    }
  }

  void changeView(PortfolioViewType viewType) {
    final currentState = state;
    if (currentState is PortfolioLoaded) {
      emit(currentState.copyWith(currentView: viewType));
    }
  }

  Future<void> refreshPortfolio(String userId) async {
    final currentState = state;
    if (currentState is PortfolioLoaded) {
      try {
        // Keep current state while refreshing, set refreshing to true
        emit(currentState.copyWith(isRefreshing: true));
        
        final results = await Future.wait([
          _getPortfolioSummary(userId),
          _getPortfolioHoldings(userId),
        ]);
        
        final summary = results[0] as PortfolioSummary;
        final holdings = results[1] as List<PortfolioHolding>;
        
        emit(currentState.copyWith(
          summary: summary,
          holdings: holdings,
          isRefreshing: false,
        ));
      } catch (error) {
        emit(PortfolioError(error.toString()));
      }
    } else {
      loadPortfolio(userId);
    }
  }

  Future<void> searchHoldings(String userId, String query) async {
    final currentState = state;
    if (currentState is PortfolioLoaded) {
      try {
        if (query.isEmpty) {
          emit(currentState.copyWith(
            searchQuery: '',
            searchResults: [],
          ));
        } else {
          final searchResults = await _searchPortfolioHoldings(userId, query);
          emit(currentState.copyWith(
            searchQuery: query,
            searchResults: searchResults,
          ));
        }
      } catch (error) {
        // Keep current state but clear search on error
        emit(currentState.copyWith(
          searchQuery: '',
          searchResults: [],
        ));
      }
    }
  }
}
