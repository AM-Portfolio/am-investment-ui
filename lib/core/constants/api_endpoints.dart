/// API endpoint constants
class ApiEndpoints {
  // Base URLs
  static const String baseUrl = '/api/v1';
  
  // Authentication endpoints
  static const String login = '$baseUrl/auth/login';
  static const String logout = '$baseUrl/auth/logout';
  static const String refreshToken = '$baseUrl/auth/refresh';
  static const String register = '$baseUrl/auth/register';
  
  // User endpoints
  static const String userProfile = '$baseUrl/user/profile';
  static const String updateProfile = '$baseUrl/user/profile';
  
  // Portfolio endpoints
  static const String portfolios = '$baseUrl/portfolios';
  static const String portfolioSummary = '$baseUrl/portfolios/summary';
  static const String portfolioHoldings = '$baseUrl/portfolios/holdings';
  
  // Trade endpoints
  static const String trades = '$baseUrl/trades';
  static const String tradeHistory = '$baseUrl/trades/history';
  static const String orders = '$baseUrl/orders';
  static const String positions = '$baseUrl/positions';
  
  // Document endpoints
  static const String documentUpload = '$baseUrl/documents/process';
  static const String documentStatus = '$baseUrl/documents/status';
  
  // Analysis endpoints
  static const String analysis = '$baseUrl/analysis';
  static const String performanceAnalysis = '$baseUrl/analysis/performance';
  static const String riskAnalysis = '$baseUrl/analysis/risk';
  
  /// Get portfolio by ID endpoint
  static String portfolioById(String id) => '$portfolios/$id';
  
  /// Get trade by ID endpoint
  static String tradeById(String id) => '$trades/$id';
  
  /// Get user portfolio holdings
  static String userPortfolioHoldings(String userId) => '$portfolioHoldings?userId=$userId';
  
  /// Get user portfolio summary
  static String userPortfolioSummary(String userId) => '$portfolioSummary?userId=$userId';
}