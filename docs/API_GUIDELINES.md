```markdown
# API Guidelines & Patterns

## Configuration Management

### Retrofit Limitations and Best Practices

**Important**: Retrofit requires static endpoint definitions in annotations. Dynamic endpoint configuration is not well supported.

#### ✅ **What CAN be configured:**
- Base URLs
- Timeouts and connection settings
- Headers and authentication
- Interceptors and error handling

#### ❌ **What CANNOT be easily configured:**
- API endpoint paths (must be static in annotations)
- HTTP methods
- Path parameters structure

### Properties File Configuration
Configure base URLs and client settings through properties, but endpoints remain static in code.

```dart
// Retrofit client with static endpoints
@RestApi()
abstract class PortfolioClient {
  factory PortfolioClient(Dio dio, {String baseUrl}) = _PortfolioClient;

  // ❌ Cannot be dynamic - must be hardcoded
  @GET('/api/v1/portfolios/holdings')
  Future<ApiPortfolioHoldingsResponse> getHoldings(@Query('userId') String userId);

  // ❌ Cannot be dynamic - must be hardcoded  
  @GET('/api/v1/portfolios/summary')
  Future<ApiPortfolioSummaryResponse> getSummary(@Query('userId') String userId);
}
```

```properties
# assets/config/app.properties
# ✅ These CAN be configured
api.base.url=https://api.investment.com
api.timeout=30000
api.portfolio.baseUrl=http://localhost:8072

# ❌ These CANNOT be used with Retrofit (endpoints are hardcoded)
# api.portfolio.resource=/api/v1/portfolios
# api.user.resource=/api/v1/users
```

### Alternative: Non-Retrofit Implementation
For full endpoint configurability, use direct Dio implementation instead of Retrofit:

```dart
// Non-Retrofit approach for dynamic endpoints
class PortfolioClient {
  final Dio _dio;
  
  PortfolioClient({required String baseUrl, Dio? dio}) : _dio = dio ?? Dio() {
    _dio.options = BaseOptions(baseUrl: baseUrl);
  }

  Future<ApiPortfolioHoldingsResponse> getHoldings(String userId) async {
    // ✅ Can read endpoint from configuration
    final endpoint = ConfigService.config?.api?.portfolio?.holdingsResource ?? '/api/v1/portfolios/holdings';
    final response = await _dio.get(endpoint, queryParameters: {'userId': userId});
    return ApiPortfolioHoldingsResponse.fromJson(response.data);
  }
}
```

## Client Implementation Pattern

### Retrofit Style Client with Static Endpoints
```dart
@RestApi()
abstract class PortfolioClient {
  factory PortfolioClient(Dio dio, {String baseUrl}) = _PortfolioClient;

  // Endpoints must be static with Retrofit
  @GET('/api/v1/portfolios/holdings')
  Future<ApiPortfolioHoldingsResponse> getHoldings(@Query('userId') String userId);

  @GET('/api/v1/portfolios/summary')  
  Future<ApiPortfolioSummaryResponse> getSummary(@Query('userId') String userId);
}
```

### Riverpod Client Provider (Configurable Base URL Only)
```dart
@riverpod
PortfolioClient portfolioClient(PortfolioClientRef ref) {
  final dio = Dio();
  
  // Configure base URL and client settings from properties
  final config = ConfigService.config;
  final portfolioApiConfig = config?.api?.portfolio;
  
  dio.options = BaseOptions(
    baseUrl: portfolioApiConfig?.baseUrl ?? 'http://localhost:8072',
    connectTimeout: Duration(seconds: portfolioApiConfig?.connectTimeout ?? 30),
    receiveTimeout: Duration(seconds: portfolioApiConfig?.receiveTimeout ?? 60),
    headers: {
      'Accept': 'application/json',
    },
  );
  
  // Add interceptors for auth, logging, etc.
  _addInterceptors(dio);
  
  return PortfolioClient(dio);
}
```

### Repository Pattern Implementation
```dart
@Injectable(as: PortfolioRepository)
class PortfolioRepositoryImpl implements PortfolioRepository {
  final PortfolioClient _client;
  
  PortfolioRepositoryImpl(this._client);

  @override
  Future<PortfolioHoldings> getHoldings(String userId) async {
    final response = await _client.getHoldings(userId);
    return PortfolioHoldingsMapper.fromApi(response);
  }
}

@riverpod
PortfolioRepository portfolioRepository(PortfolioRepositoryRef ref) {
  final client = ref.read(portfolioClientProvider);
  return PortfolioRepositoryImpl(client);
}
```

### Service Layer Pattern
```dart
@injectable
class PortfolioService {
  final PortfolioRepository _repository;
  
  PortfolioService(this._repository);

  Future<PortfolioHoldings> getHoldings(String userId) async {
    try {
      return await _repository.getHoldings(userId);
    } catch (e) {
      debugPrint('Error fetching holdings: $e');
      
      // Check if environment is dev or mock data is enabled
      if (_isDevelopmentEnvironment() || ConfigService.mockDataEnabled) {
        debugPrint('Using mock data for holdings in development');
        return _getMockHoldings(userId);
      }
      rethrow;
    }
  }

  bool _isDevelopmentEnvironment() {
    return const String.fromEnvironment('ENVIRONMENT', defaultValue: 'prod') == 'dev';
  }

  Future<PortfolioHoldings> _getMockHoldings(String userId) async {
    return MockPortfolioDataProvider.getHoldings(userId);
  }
}

@riverpod
PortfolioService portfolioService(PortfolioServiceRef ref) {
  final repository = ref.read(portfolioRepositoryProvider);
  return PortfolioService(repository);
}
```

### Widget Integration - Never Manual Initialization
```dart
// ❌ Bad - Manual initialization
class PortfolioScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final service = PortfolioService(PortfolioRepositoryImpl(PortfolioClient(Dio())));
    // ...
  }
}

// ✅ Good - Use Riverpod providers
class PortfolioScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final holdingsAsync = ref.watch(portfolioHoldingsProvider(userId));
    return holdingsAsync.when(
      data: (holdings) => Portfolio HoldingsView(holdings: holdings),
      loading: () => const CircularProgressIndicator(),
      error: (error, stack) => ErrorWidget(error),
    );
  }
}

@riverpod
Future<PortfolioHoldings> portfolioHoldings(
  PortfolioHoldingsRef ref,
  String userId,
) async {
  final service = ref.read(portfolioServiceProvider);
  return service.getHoldings(userId);
}
```

## Request/Response Models

### API Response Model
```dart
@freezed
class ApiPortfolioResponse with _$ApiPortfolioResponse {
  const factory ApiPortfolioResponse({
    required List<ApiEquityHolding> equityHoldings,
  }) = _ApiPortfolioResponse;

  factory ApiPortfolioResponse.fromJson(Map<String, dynamic> json) =>
      _$ApiPortfolioResponseFromJson(json);
}
```

### Domain Entity
```dart
@freezed
class PortfolioHoldings with _$PortfolioHoldings {
  const factory PortfolioHoldings({
    required String userId,
    required List<EquityHolding> holdings,
    required DateTime lastUpdated,
  }) = _PortfolioHoldings;
}
```