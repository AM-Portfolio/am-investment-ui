import '../../../../../core/network/api_client.dart';
import '../dtos/metrics/metrics_dtos.dart';
import '../dtos/report/trade_performance_summary_dto.dart';
import '../dtos/report/daily_performance_dto.dart';
import '../dtos/report/timing_analysis_dto.dart';

class TradeReportRemoteDataSource {
  final ApiClient _client;

  TradeReportRemoteDataSource(this._client);

  /// Get comprehensive trade performance summary
  Future<TradePerformanceSummaryDto> getSummary(MetricsFilterRequestDto filter) async {
    final queryParams = {
      if (filter.portfolioIds != null && filter.portfolioIds!.isNotEmpty) 'portfolioId': filter.portfolioIds!.first,
      'startDate': filter.dateRange.startDate.toIso8601String(), 
      'endDate': filter.dateRange.endDate.toIso8601String(), 
    };

    return _client.get(
      'api/v1/performance/summary',
      queryParams: queryParams,
      parser: (data) => TradePerformanceSummaryDto.fromJson(data),
    );
  }

  /// Get daily performance breakdown
  Future<List<DailyPerformanceDto>> getDaily(MetricsFilterRequestDto filter) async {
    final queryParams = {
      if (filter.portfolioIds != null && filter.portfolioIds!.isNotEmpty) 'portfolioId': filter.portfolioIds!.first,
      'limit': 1000, 
    };

    return _client.get(
      'api/v1/performance/daily',
      queryParams: queryParams,
      // API returns a List, parser handles dynamic data
      parser: (data) => (data as List).map((e) => DailyPerformanceDto.fromJson(e)).toList(),
    );
  }

  /// Get timing analysis
  Future<TimingAnalysisDto> getTiming(MetricsFilterRequestDto filter) async {
    final queryParams = {
      if (filter.portfolioIds != null && filter.portfolioIds!.isNotEmpty) 'portfolioId': filter.portfolioIds!.first,
    };

    return _client.get(
      'api/v1/performance/timing',
      queryParams: queryParams,
      parser: (data) => TimingAnalysisDto.fromJson(data),
    );
  }
}
