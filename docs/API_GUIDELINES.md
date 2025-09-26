```markdown
# API Guidelines & Patterns

## Configuration Management

### Properties File Configuration
Always read API resources and base URLs from properties file to ensure environment-specific configurations are properly managed.

```dart
// config/api_config.dart
class ApiConfig {
  static const String _baseUrlKey = 'api.base.url';
  static const String _portfolioResourceKey = 'api.portfolio.resource';
  
  static String get baseUrl => 
      PropertiesReader.getString(_baseUrlKey) ?? 'https://api.default.com';
  
  static String get portfolioResource => 
      PropertiesReader.getString(_portfolioResourceKey) ?? '/api/v1/portfolios';
}
```

```properties
# assets/config/app.properties
api.base.url=https://api.investment.com
api.portfolio.resource=/api/v1/portfolios
api.user.resource=/api/v1/users
api.market.resource=/api/v1/market
```

## Client Implementation Pattern

### Retrofit Style Client with Injectable
```dart
@RestApi()
@injectable
abstract class PortfolioClient {
  @factoryMethod
  factory PortfolioClient(Dio dio, {@Named('baseUrl') String? baseUrl}) = _PortfolioClient;

  @GET('${ApiConfig.portfolioResource}/holdings')
  Future<ApiPortfolioHoldingsResponse> getHoldings(@Query('userId') String userId);

  @GET('${ApiConfig.portfolioResource}/summary')  
  Future<ApiPortfolioSummaryResponse> getSummary(@Query('userId') String userId);
}
```

### Riverpod Client Provider
```dart
@riverpod
PortfolioClient portfolioClient(PortfolioClientRef ref) {
  final config = ref.read(apiConfigProvider);
  final dio = ref.read(dioProvider);
  return PortfolioClient(dio, baseUrl: config.baseUrl);
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