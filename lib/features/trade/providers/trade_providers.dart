import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../data/services/trade_api_service.dart';
import '../data/services/trade_mock_service.dart';
import '../presentation/cubit/unified_trade_cubit.dart';
import '../../../config/config_service.dart';

final tradeApiServiceProvider = Provider<TradeApiService>((ref) {
  final baseUrl = ConfigService.config.api.baseUrl;
  
  return TradeApiService(
    baseUrl: baseUrl,
    httpClient: http.Client(),
  );
});

final tradeMockServiceProvider = Provider<TradeMockService>((ref) {
  return TradeMockService();
});

final unifiedTradeCubitProvider = Provider<UnifiedTradeCubit>((ref) {
  final useMockData = ConfigService.config.api.useMockData;
  
  return UnifiedTradeCubit(
    apiService: useMockData ? null : ref.read(tradeApiServiceProvider),
    mockService: useMockData ? ref.read(tradeMockServiceProvider) : null,
    useMockData: useMockData,
  );
});
