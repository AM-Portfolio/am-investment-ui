import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/config_service.dart';
import '../../../core/network/api_client.dart';
import '../internal/data/datasources/trade_metrics_remote_datasource.dart';
import '../internal/data/repositories/trade_metrics_repository_impl.dart';
import '../internal/domain/repositories/trade_metrics_repository.dart';
import '../internal/domain/usecases/get_trade_metrics.dart';
import '../presentation/metrics/cubit/trade_metrics_cubit.dart';

// Infrastructure

/// Provider for ApiClient
final _apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

/// Provider for TradeMetricsRemoteDataSource
final _tradeMetricsRemoteDataSourceProvider = Provider<TradeMetricsRemoteDataSource>((ref) {
  final apiClient = ref.watch(_apiClientProvider);
  final apiConfig = ConfigService.config.api;
  return TradeMetricsRemoteDataSourceImpl(apiClient: apiClient, tradeConfig: apiConfig.trade);
});

/// Provider for TradeMetricsRepository
final _tradeMetricsRepositoryProvider = Provider<TradeMetricsRepository>((ref) {
  final remoteDataSource = ref.watch(_tradeMetricsRemoteDataSourceProvider);
  return TradeMetricsRepositoryImpl(remoteDataSource);
});

// Use Cases

/// Provider for GetTradeMetrics UseCase
final getTradeMetricsUseCaseProvider = Provider<GetTradeMetrics>((ref) {
  final repository = ref.watch(_tradeMetricsRepositoryProvider);
  return GetTradeMetrics(repository);
});

// Presentation

/// Provider for TradeMetricsCubit
final tradeMetricsCubitProvider = Provider<TradeMetricsCubit>((ref) {
  final getTradeMetrics = ref.watch(getTradeMetricsUseCaseProvider);
  return TradeMetricsCubit(getTradeMetrics: getTradeMetrics);
});
