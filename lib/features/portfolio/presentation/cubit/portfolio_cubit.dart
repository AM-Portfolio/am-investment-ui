import 'package:flutter_bloc/flutter_bloc.dart';
import 'portfolio_state.dart';
import '../../internal/domain/entities/portfolio_summary.dart';
import '../../internal/domain/entities/portfolio_holding.dart';

class PortfolioCubit extends Cubit<PortfolioState> {
  PortfolioCubit() : super(PortfolioInitial());

  Future<void> loadPortfolio(String userId) async {
    emit(PortfolioLoading());
    
    try {
      // Mock implementation for now - replace with actual service calls
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Create mock data
      final summary = PortfolioSummary.empty(userId);
      final holdings = <PortfolioHolding>[];
      
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
        
        // Mock delay
        await Future.delayed(const Duration(seconds: 1));
        
        // Create mock refreshed data
        final summary = PortfolioSummary.empty(userId);
        final holdings = <PortfolioHolding>[];
        
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
          // Mock search - in real implementation, call search service
          final searchResults = <PortfolioHolding>[];
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
