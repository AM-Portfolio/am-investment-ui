import '../../../../../core/utils/logger.dart';
import '../dtos/portfolio_holdings_dto.dart';
import '../dtos/portfolio_summary_dto.dart';

/// Mapper class for Portfolio API operations
/// 
/// Handles conversion between API requests/responses and data transfer objects,
/// following the same pattern as AuthMapper for consistency
class PortfolioMapper {
  
  /// Create API request body for fetching portfolio holdings
  static Map<String, dynamic> portfolioHoldingsRequestToJson(String userId) {
    return {
      'userId': userId,
    };
  }
  
  /// Create API request body for fetching portfolio summary
  static Map<String, dynamic> portfolioSummaryRequestToJson(String userId) {
    return {
      'userId': userId,
    };
  }
  
  /// Parse portfolio holdings from API response JSON
  static PortfolioHoldingsDto portfolioHoldingsFromJson(Map<String, dynamic> json) {
    try {
      return PortfolioHoldingsDto.fromJson(json);
    } catch (e) {
      AppLogger.error('Failed to parse portfolio holdings response', 
          tag: 'PortfolioMapper', error: e);
      throw Exception('Invalid portfolio holdings response format');
    }
  }
  
  /// Parse portfolio summary from API response JSON
  static PortfolioSummaryDto portfolioSummaryFromJson(Map<String, dynamic> json) {
    try {
      return PortfolioSummaryDto.fromJson(json);
    } catch (e) {
      AppLogger.error('Failed to parse portfolio summary response', 
          tag: 'PortfolioMapper', error: e);
      throw Exception('Invalid portfolio summary response format');
    }
  }
  
  // Note: Error parsing is now handled by ApiClient's built-in exception system
  
  /// Create request body for portfolio data refresh
  static Map<String, dynamic> refreshPortfolioRequestToJson(String userId, {
    bool forceRefresh = false,
  }) {
    return {
      'userId': userId,
      'forceRefresh': forceRefresh,
    };
  }
  
  /// Create request body for portfolio search/filter
  static Map<String, dynamic> portfolioSearchRequestToJson(
    String userId, {
    String? searchTerm,
    List<String>? sectors,
    Map<String, double>? priceRange,
    Map<String, double>? valueRange,
  }) {
    final Map<String, dynamic> request = {
      'userId': userId,
    };
    
    if (searchTerm != null && searchTerm.isNotEmpty) {
      request['searchTerm'] = searchTerm;
    }
    
    if (sectors != null && sectors.isNotEmpty) {
      request['sectors'] = sectors;
    }
    
    if (priceRange != null) {
      request['priceRange'] = priceRange;
    }
    
    if (valueRange != null) {
      request['valueRange'] = valueRange;
    }
    
    return request;
  }
}