import '../../domain/entities/metrics/metrics_filter_request.dart';
import '../../domain/entities/report/daily_performance.dart';
import '../../domain/entities/report/timing_analysis.dart';
import '../../domain/entities/report/trade_performance_summary.dart';
import '../../domain/repositories/trade_report_repository.dart';
import '../datasources/trade_report_remote_datasource.dart';
import '../dtos/metrics/metrics_dtos.dart';
import '../mappers/trade_report_mapper.dart';

class TradeReportRepositoryImpl implements TradeReportRepository {
  final TradeReportRemoteDataSource remoteDataSource;

  TradeReportRepositoryImpl(this.remoteDataSource);

  @override
  Future<TradePerformanceSummary> getPerformanceSummary(MetricsFilterRequest filter) async {
    final filterDto = MetricsFilterRequestDto.fromEntity(filter);
    final responseDto = await remoteDataSource.getSummary(filterDto);
    return TradeReportMapper.toSummary(responseDto);
  }

  @override
  Future<List<DailyPerformance>> getDailyPerformance(MetricsFilterRequest filter) async {
    final filterDto = MetricsFilterRequestDto.fromEntity(filter);
    final responseDtos = await remoteDataSource.getDaily(filterDto);
    return responseDtos.map((e) => TradeReportMapper.toDaily(e)).toList();
  }

  @override
  Future<TimingAnalysis> getTimingAnalysis(MetricsFilterRequest filter) async {
    final filterDto = MetricsFilterRequestDto.fromEntity(filter);
    final responseDto = await remoteDataSource.getTiming(filterDto);
    return TradeReportMapper.toTimingAnalysis(responseDto);
  }
}
