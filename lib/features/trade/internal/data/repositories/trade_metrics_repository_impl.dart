import '../../domain/entities/metrics/metrics_filter_request.dart';
import '../../domain/entities/metrics/trade_metrics_response.dart';
import '../../domain/repositories/trade_metrics_repository.dart';
import '../datasources/trade_metrics_remote_datasource.dart';
import '../dtos/metrics/metrics_dtos.dart';

class TradeMetricsRepositoryImpl implements TradeMetricsRepository {
  final TradeMetricsRemoteDataSource remoteDataSource;

  TradeMetricsRepositoryImpl(this.remoteDataSource);

  @override
  Future<TradeMetricsResponse> getMetrics(MetricsFilterRequest filter) async {
    final filterDto = MetricsFilterRequestDto.fromEntity(filter);
    final responseDto = await remoteDataSource.getMetrics(filterDto);
    return responseDto.toEntity();
  }
}
