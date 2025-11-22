import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/config_service.dart';
import '../../../core/network/api_client.dart';
import '../internal/data/datasources/trade_controller_remote_data_source.dart';
import '../internal/data/repositories/trade_controller_repository_impl.dart';
import '../internal/domain/repositories/trade_controller_repository.dart';
import '../internal/domain/usecases/add_trade.dart';
import '../internal/domain/usecases/delete_trade.dart';
import '../internal/domain/usecases/get_trades_by_portfolio.dart';
import '../internal/domain/usecases/update_trade.dart';
import '../presentation/cubit/trade_controller_cubit.dart';

/// Provider for API client (if not already available, reuse from trade_internal_providers)
final _apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

/// Provider for trade controller remote data source
final _tradeControllerRemoteDataSourceProvider = Provider<TradeControllerRemoteDataSource>((ref) {
  final apiClient = ref.watch(_apiClientProvider);
  final apiConfig = ConfigService.config.api;

  return TradeControllerRemoteDataSourceImpl(apiClient: apiClient, apiConfig: apiConfig);
});

/// Provider for trade controller repository
final _tradeControllerRepositoryProvider = Provider<TradeControllerRepository>((ref) {
  final remoteDataSource = ref.watch(_tradeControllerRemoteDataSourceProvider);

  return TradeControllerRepositoryImpl(remoteDataSource: remoteDataSource);
});

/// Provider for AddTrade use case
final _addTradeProvider = Provider<AddTrade>((ref) {
  final repository = ref.watch(_tradeControllerRepositoryProvider);
  return AddTrade(repository);
});

/// Provider for UpdateTrade use case
final _updateTradeProvider = Provider<UpdateTrade>((ref) {
  final repository = ref.watch(_tradeControllerRepositoryProvider);
  return UpdateTrade(repository);
});

/// Provider for DeleteTrade use case
final _deleteTradeProvider = Provider<DeleteTrade>((ref) {
  final repository = ref.watch(_tradeControllerRepositoryProvider);
  return DeleteTrade(repository);
});

/// Provider for GetTradesByPortfolio use case
final _getTradesByPortfolioProvider = Provider<GetTradesByPortfolio>((ref) {
  final repository = ref.watch(_tradeControllerRepositoryProvider);
  return GetTradesByPortfolio(repository);
});

/// Provider for TradeControllerCubit
final tradeControllerCubitProvider = Provider.autoDispose<TradeControllerCubit>((ref) {
  final addTrade = ref.watch(_addTradeProvider);
  final updateTrade = ref.watch(_updateTradeProvider);
  final deleteTrade = ref.watch(_deleteTradeProvider);
  final getTradesByPortfolio = ref.watch(_getTradesByPortfolioProvider);

  return TradeControllerCubit(
    addTrade: addTrade,
    updateTrade: updateTrade,
    deleteTrade: deleteTrade,
    getTradesByPortfolio: getTradesByPortfolio,
  );
});

/// Provider for TradeControllerCubit with portfolio ID parameter
/// Use this when you need a cubit scoped to a specific portfolio
final tradeControllerCubitForPortfolioProvider = Provider.family.autoDispose<TradeControllerCubit, String>((
  ref,
  portfolioId,
) {
  final cubit = ref.watch(tradeControllerCubitProvider);
  // Optionally load trades immediately for this portfolio
  cubit.loadTrades(portfolioId: portfolioId);
  return cubit;
});
