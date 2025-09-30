import '../dtos/portfolio_holdings_dto.dart';
import '../dtos/portfolio_summary_dto.dart';
import '../../../../../core/utils/logger.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../config/app_config.dart';
import '../mappers/portfolio_mapper.dart';

/// Abstract data source for portfolio data
abstract class PortfolioRemoteDataSource {
  /// Get portfolio holdings from remote API
  Future<PortfolioHoldingsDto> getPortfolioHoldings(String userId);
  
  /// Get portfolio summary from remote API
  Future<PortfolioSummaryDto> getPortfolioSummary(String userId);
}

/// Concrete implementation of portfolio remote data source
/// 
/// Handles API calls for portfolio operations following clean architecture principles
class PortfolioRemoteDataSourceImpl implements PortfolioRemoteDataSource {
  final ApiClient _apiClient;
  final PortfolioApiConfig _portfolioConfig;
  
  const PortfolioRemoteDataSourceImpl({
    required ApiClient apiClient,
    required PortfolioApiConfig portfolioConfig,
  }) : _apiClient = apiClient,
       _portfolioConfig = portfolioConfig;



  @override
  Future<PortfolioHoldingsDto> getPortfolioHoldings(String userId) async {
    AppLogger.methodEntry('getPortfolioHoldings', tag: 'PortfolioRemoteDataSource', 
        params: {'userId': userId});
    
    try {
      // Use mapper to create request body
      final requestBody = PortfolioMapper.portfolioHoldingsRequestToJson(userId);
      
      AppLogger.debug('API request prepared for portfolio holdings', tag: 'PortfolioRemoteDataSource');
      
      // Construct full URI from portfolio config
      final fullUri = '${_portfolioConfig.baseUrl}${_portfolioConfig.holdingsResource}';
      
      // Use ApiClient for consistent error handling and logging
      final holdingsResponse = await _apiClient.post<PortfolioHoldingsDto>(
        fullUri,
        body: requestBody,
        parser: (data) => PortfolioMapper.portfolioHoldingsFromJson(data as Map<String, dynamic>),
      );

      AppLogger.info('Portfolio holdings fetched successfully from API', tag: 'PortfolioRemoteDataSource');
      AppLogger.methodExit('getPortfolioHoldings', tag: 'PortfolioRemoteDataSource', result: 'success');

      return holdingsResponse;
    } catch (e) {
      AppLogger.error('Failed to fetch portfolio holdings', tag: 'PortfolioRemoteDataSource',
          error: e, stackTrace: StackTrace.current);
      AppLogger.methodExit('getPortfolioHoldings', tag: 'PortfolioRemoteDataSource', result: 'error');
      rethrow;
    }
  }

  @override
  Future<PortfolioSummaryDto> getPortfolioSummary(String userId) async {
    AppLogger.methodEntry('getPortfolioSummary', tag: 'PortfolioRemoteDataSource', 
        params: {'userId': userId});
    
    try {
      // Use mapper to create request body
      final requestBody = PortfolioMapper.portfolioSummaryRequestToJson(userId);
      
      AppLogger.debug('API request prepared for portfolio summary', tag: 'PortfolioRemoteDataSource');
      
      // Construct full URI from portfolio config
      final fullUri = '${_portfolioConfig.baseUrl}${_portfolioConfig.summaryResource}';
      
      // Use ApiClient for consistent error handling and logging
      final summaryResponse = await _apiClient.post<PortfolioSummaryDto>(
        fullUri,
        body: requestBody,
        parser: (data) => PortfolioMapper.portfolioSummaryFromJson(data as Map<String, dynamic>),
      );

      AppLogger.info('Portfolio summary fetched successfully from API', tag: 'PortfolioRemoteDataSource');
      AppLogger.methodExit('getPortfolioSummary', tag: 'PortfolioRemoteDataSource', result: 'success');

      return summaryResponse;
    } catch (e) {
      AppLogger.error('Failed to fetch portfolio summary', tag: 'PortfolioRemoteDataSource',
          error: e, stackTrace: StackTrace.current);
      AppLogger.methodExit('getPortfolioSummary', tag: 'PortfolioRemoteDataSource', result: 'error');
      rethrow;
    }
  }


}