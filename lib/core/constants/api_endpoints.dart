import '/config/app_properties.dart';
import 'app_constants.dart';

/// API endpoint constants
/// Now reads dynamically from [AppProperties] for a single source of truth
class ApiEndpoints {
  // Base URLs
  static String get apiBaseUrl => AppProperties().getValue(PropertyKeys.apiBaseUrl, defaultValue: 'https://am.munish.org'); // Consistently use am.munish.org
  static String get authBaseUrl => '$apiBaseUrl/auth/token/v1';
  static String get userBaseUrl => '$apiBaseUrl/users/account/v1';
  
  // Authentication endpoints
  static String get login => '$authBaseUrl/tokens'; 
  static String get logout => '$authBaseUrl/logout';
  static String get refreshToken => '$authBaseUrl/refresh';
  static String get register => '$userBaseUrl/register'; 
  
  static String get googleLogin => AppProperties().getValue(PropertyKeys.apiAuthGoogleLoginEndpoint, defaultValue: '$authBaseUrl/google/token');
  static String get forgotPassword => AppProperties().getValue(PropertyKeys.apiUserForgotPasswordEndpoint, defaultValue: '$authBaseUrl/forgot-password');
  static String get resetPassword => AppProperties().getValue(PropertyKeys.apiUserResetPasswordEndpoint, defaultValue: '$authBaseUrl/reset-password');
  
  // User endpoints
  static String get userProfile => '$userBaseUrl/profile';
  static String get updateProfile => '$userBaseUrl/profile';
  
  /// Get user status endpoint (for activation/status check)
  static String userStatus(String userId) => '$userBaseUrl/$userId/status';
  
  // Portfolio endpoints
  static String get portfolios => '$apiBaseUrl/portfolios';
  static String get portfolioSummary => '$apiBaseUrl/portfolios/summary';
  static String get portfolioHoldings => '$apiBaseUrl/portfolios/holdings';
  
  // Trade endpoints
  static String get trades => '$apiBaseUrl/trades';
  static String get tradeHistory => '$apiBaseUrl/trades/history';
  static String get orders => '$apiBaseUrl/orders';
  static String get positions => '$apiBaseUrl/positions';
  
  // Document endpoints
  static String get documentUpload => '$apiBaseUrl/documents/process';
  static String get documentStatus => '$apiBaseUrl/documents/status';
  
  // Analysis endpoints
  static String get analysis => '$apiBaseUrl/analysis';
  static String get performanceAnalysis => '$apiBaseUrl/analysis/performance';
  static String get riskAnalysis => '$apiBaseUrl/analysis/risk';
  
  /// Get portfolio by ID endpoint
  static String portfolioById(String id) => '$portfolios/$id';
  
  /// Get trade by ID endpoint
  static String tradeById(String id) => '$trades/$id';
  
  /// Get user portfolio holdings
  static String userPortfolioHoldings(String userId) => '$portfolioHoldings?userId=$userId';
  
  /// Get user portfolio summary
  static String userPortfolioSummary(String userId) => '$portfolioSummary?userId=$userId';
}