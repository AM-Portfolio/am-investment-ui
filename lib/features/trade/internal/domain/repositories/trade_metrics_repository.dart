import '../entities/metrics/metrics_filter_request.dart';
import '../entities/metrics/trade_metrics_response.dart';

abstract class TradeMetricsRepository {
  Future<TradeMetricsResponse> getMetrics(MetricsFilterRequest filter);
}
