import '../../../../core/network/api_client.dart';
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
      'startDate': filter.startDate, 
      'endDate': filter.endDate, 
    };

    final response = await _client.get(
      '/performance/summary',
      queryParameters: queryParams,
    );
    return TradePerformanceSummaryDto.fromJson(response.data);
  }

  /// Get daily performance breakdown
  Future<List<DailyPerformanceDto>> getDaily(MetricsFilterRequestDto filter) async {
    final queryParams = {
      if (filter.portfolioIds != null && filter.portfolioIds!.isNotEmpty) 'portfolioId': filter.portfolioIds!.first,
      'limit': 1000, 
    };

    final response = await _client.get(
      '/performance/daily',
      queryParameters: queryParams,
    );
     // API returns a List
    return (response.data as List).map((e) => DailyPerformanceDto.fromJson(e)).toList();
  }

  /// Get timing analysis
  Future<TimingAnalysisDto> getTiming(MetricsFilterRequestDto filter) async {
    final queryParams = {
      if (filter.portfolioIds != null && filter.portfolioIds!.isNotEmpty) 'portfolioId': filter.portfolioIds!.first,
    };

    final response = await _client.get(
      '/performance/timing',
      queryParameters: queryParams,
    );
    return TimingAnalysisDto.fromJson(response.data);
  }
}
