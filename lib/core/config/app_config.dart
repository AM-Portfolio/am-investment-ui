/// Application configuration model
/// Similar to Spring Boot's application properties
class AppConfig {
  final ApiConfig api;
  final EnvironmentConfig environment;

  const AppConfig({
    required this.api,
    required this.environment,
  });

  factory AppConfig.fromJson(Map<String, dynamic> json) {
    return AppConfig(
      api: ApiConfig.fromJson(json['api'] ?? {}),
      environment: EnvironmentConfig.fromJson(json['environment'] ?? {}),
    );
  }
}

/// API configuration
class ApiConfig {
  final String baseUrl;
  final int timeout;
  final bool useMockData;
  final PortfolioApiConfig portfolio;

  const ApiConfig({
    required this.baseUrl,
    this.timeout = 30000,
    this.useMockData = false,
    required this.portfolio,
  });

  factory ApiConfig.fromJson(Map<String, dynamic> json) {
    return ApiConfig(
      baseUrl: json['baseUrl'],
      timeout: json['timeout'] ?? 30000,
      useMockData: json['useMockData'] ?? false,
      portfolio: PortfolioApiConfig.fromJson(json['portfolio'] ?? {}),
    );
  }
}

/// Portfolio-specific API configuration
class PortfolioApiConfig {
  final String holdingsEndpoint;
  final String summaryEndpoint;
  final String transactionsEndpoint;

  const PortfolioApiConfig({
    this.holdingsEndpoint = '/api/v1/portfolios/holdings',
    this.summaryEndpoint = '/api/v1/portfolios/summary',
    this.transactionsEndpoint = '/api/v1/portfolios/transactions',
  });

  factory PortfolioApiConfig.fromJson(Map<String, dynamic> json) {
    return PortfolioApiConfig(
      holdingsEndpoint: json['holdingsEndpoint'] ?? '/api/v1/portfolios/holdings',
      summaryEndpoint: json['summaryEndpoint'] ?? '/api/v1/portfolios/summary',
      transactionsEndpoint: json['transactionsEndpoint'] ?? '/api/v1/portfolios/transactions',
    );
  }
}

/// Environment configuration
class EnvironmentConfig {
  final String name;
  final bool debugMode;
  final String logLevel;

  const EnvironmentConfig({
    this.name = 'development',
    this.debugMode = true,
    this.logLevel = 'debug',
  });

  factory EnvironmentConfig.fromJson(Map<String, dynamic> json) {
    return EnvironmentConfig(
      name: json['name'] ?? 'development',
      debugMode: json['debugMode'] ?? true,
      logLevel: json['logLevel'] ?? 'debug',
    );
  }

  bool get isDevelopment => name == 'development';
  bool get isProduction => name == 'production';
}