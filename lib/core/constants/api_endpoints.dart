/// API endpoint constants
class ApiEndpoints {
  // Base URLs
  static const String authBaseUrl = '/auth/v1';
  static const String userBaseUrl = '/users/v1';
  static const String apiBaseUrl = '/api/v1'; // For other services
  
  // Authentication endpoints
  static const String login = '$authBaseUrl/tokens'; // Changed from /auth/login
  static const String logout = '$authBaseUrl/logout';
  static const String refreshToken = '$authBaseUrl/refresh';
  static const String register = '$userBaseUrl/auth/register'; // Changed from /auth/register
  
  // User endpoints
  static const String userProfile = '$userBaseUrl/users/profile';
  static const String updateProfile = '$userBaseUrl/users/profile';
  
  // Portfolio endpoints
  static const String portfolios = '$apiBaseUrl/portfolios';
  static const String portfolioSummary = '$apiBaseUrl/portfolios/summary';
  static const String portfolioHoldings = '$apiBaseUrl/portfolios/holdings';
  
  // Trade endpoints
  static const String trades = '$apiBaseUrl/trades';
  static const String tradeHistory = '$apiBaseUrl/trades/history';
  static const String orders = '$apiBaseUrl/orders';
  static const String positions = '$apiBaseUrl/positions';
  
  // Document endpoints
  static const String documentUpload = '$apiBaseUrl/documents/process';
  static const String documentStatus = '$apiBaseUrl/documents/status';
  
  // Analysis endpoints
  static const String analysis = '$apiBaseUrl/analysis';
  static const String performanceAnalysis = '$apiBaseUrl/analysis/performance';
  static const String riskAnalysis = '$apiBaseUrl/analysis/risk';
  
  /// Get portfolio by ID endpoint
  static String portfolioById(String id) => '$portfolios/$id';
  
  /// Get trade by ID endpoint
  static String tradeById(String id) => '$trades/$id';
  
  /// Get user portfolio holdings
  static String userPortfolioHoldings(String userId) => '$portfolioHoldings?userId=$userId';
  
  /// Get user portfolio summary
  static String userPortfolioSummary(String userId) => '$portfolioSummary?userId=$userId';
}