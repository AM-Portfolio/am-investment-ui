import 'package:flutter_bloc/flutter_bloc.dart';
import 'portfolio_state.dart';
import '../../internal/domain/entities/portfolio_summary.dart';
import '../../internal/domain/entities/portfolio_holding.dart';
import '../../internal/services/portfolio_service.dart';
import '../../../../core/utils/logger.dart';

class PortfolioCubit extends Cubit<PortfolioState> {
  final PortfolioService _portfolioService;
  
  PortfolioCubit(this._portfolioService) : super(PortfolioInitial());

  Future<void> loadPortfolio(String userId) async {
    AppLogger.methodEntry('loadPortfolio', tag: 'PortfolioCubit', params: {'userId': userId});
    AppLogger.stateChange('${state.runtimeType}', 'PortfolioLoading', tag: 'PortfolioCubit');
    
    emit(PortfolioLoading());
    
    try {
      AppLogger.info('Starting portfolio data fetch via service', tag: 'PortfolioCubit');
      
      // Use portfolio service to fetch data concurrently
      final results = await Future.wait([
        _portfolioService.getPortfolioHoldings(userId),
        _portfolioService.getPortfolioSummary(userId),
      ]);
      
      final holdings = results[0] as PortfolioHoldings;
      final summary = results[1] as PortfolioSummary;
      
      AppLogger.stateChange('PortfolioLoading', 'PortfolioLoaded', tag: 'PortfolioCubit');
      AppLogger.info('Portfolio data loaded successfully via service (${holdings.holdings.length} holdings)', tag: 'PortfolioCubit');
      
      emit(PortfolioLoaded(
        summary: summary,
        holdings: holdings.holdings,
      ));
      
      AppLogger.methodExit('loadPortfolio', tag: 'PortfolioCubit', result: 'success');
    } catch (error) {
      AppLogger.stateChange('PortfolioLoading', 'PortfolioError', tag: 'PortfolioCubit', event: error.toString());
      AppLogger.error('Failed to load portfolio via service', tag: 'PortfolioCubit', 
          error: error, stackTrace: StackTrace.current);
      
      emit(PortfolioError(error.toString()));
      
      AppLogger.methodExit('loadPortfolio', tag: 'PortfolioCubit', result: 'error');
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
        AppLogger.info('Refreshing portfolio data via service', tag: 'PortfolioCubit');
        
        // Keep current state while refreshing, set refreshing to true
        emit(currentState.copyWith(isRefreshing: true));
        
        // Use portfolio service to refresh data
        final results = await Future.wait([
          _portfolioService.getPortfolioHoldings(userId),
          _portfolioService.getPortfolioSummary(userId),
        ]);
        
        final holdings = results[0] as PortfolioHoldings;
        final summary = results[1] as PortfolioSummary;
        
        emit(currentState.copyWith(
          summary: summary,
          holdings: holdings.holdings,
          isRefreshing: false,
        ));
        
        AppLogger.info('Portfolio data refreshed successfully via service', tag: 'PortfolioCubit');
      } catch (error) {
        AppLogger.error('Failed to refresh portfolio via service', tag: 'PortfolioCubit', error: error);
        emit(PortfolioError(error.toString()));
      }
    } else {
      loadPortfolio(userId);
    }
  }
}
