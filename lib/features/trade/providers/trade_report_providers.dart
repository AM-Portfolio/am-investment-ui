import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../internal/data/datasources/trade_report_remote_datasource.dart';
import '../internal/data/repositories/trade_report_repository_impl.dart';
import '../internal/domain/repositories/trade_report_repository.dart';
import '../internal/domain/usecases/get_trade_performance_summary_usecase.dart';
import '../internal/domain/usecases/get_daily_performance_usecase.dart';
import '../internal/domain/usecases/get_timing_analysis_usecase.dart';
import '../presentation/report/cubit/trade_report_cubit.dart';
import '../../../../core/network/api_client.dart';

import '../../../../../config/config_service.dart';

final tradeReportRemoteDataSourceProvider = Provider<TradeReportRemoteDataSource>((ref) {
  final apiConfig = ConfigService.config.api;
  return TradeReportRemoteDataSource(ApiClient(), apiConfig.trade); 
});

final tradeReportRepositoryProvider = Provider<TradeReportRepository>((ref) {
  return TradeReportRepositoryImpl(ref.read(tradeReportRemoteDataSourceProvider));
});

final getTradePerformanceSummaryUseCaseProvider = Provider<GetTradePerformanceSummaryUseCase>((ref) {
  return GetTradePerformanceSummaryUseCase(ref.read(tradeReportRepositoryProvider));
});

final getDailyPerformanceUseCaseProvider = Provider<GetDailyPerformanceUseCase>((ref) {
  return GetDailyPerformanceUseCase(ref.read(tradeReportRepositoryProvider));
});

final getTimingAnalysisUseCaseProvider = Provider<GetTimingAnalysisUseCase>((ref) {
  return GetTimingAnalysisUseCase(ref.read(tradeReportRepositoryProvider));
});

final tradeReportCubitProvider = Provider<TradeReportCubit>((ref) {
  return TradeReportCubit(
    ref.read(getTradePerformanceSummaryUseCaseProvider),
    ref.read(getDailyPerformanceUseCaseProvider),
    ref.read(getTimingAnalysisUseCaseProvider),
  );
});
