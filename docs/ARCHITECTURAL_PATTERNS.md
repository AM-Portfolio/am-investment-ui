```markdown
# Architectural Patterns

## Clean Architecture Layers

### 1. Data Layer (`lib/core/data/`)
```
data/
├── api/models/          # API request/response models
├── repositories/        # Repository implementations  
└── mappers/            # Data transformation
```

### 2. Domain Layer (`lib/core/domain/`)
```
domain/
├── entities/           # Business entities (Freezed classes)
└── repositories/       # Repository interfaces
```

### 3. Service Layer (`lib/core/services/`)
```
services/
├── clients/           # API clients (Retrofit style)
└── [service_name]_service.dart
```

### 4. Presentation Layer (`lib/features/`)
```
features/
└── [feature_name]/
    ├── screens/
    ├── widgets/
    └── [feature]_screen.dart
```

## Repository Pattern Implementation

### Repository Interface
```dart
@injectable
abstract class PortfolioRepository {
  Future<Portfolio> getPortfolio(String userId);
  Future<List<Holding>> getHoldings(String userId);
}
```

### Repository Implementation
```dart
@Injectable(as: PortfolioRepository)
class PortfolioRepositoryImpl implements PortfolioRepository {
  final PortfolioClient _client;
  
  PortfolioRepositoryImpl(this._client);

  @override
  Future<Portfolio> getPortfolio(String userId) async {
    try {
      final response = await _client.getPortfolio(userId);
      return PortfolioMapper.fromApi(response);
    } catch (e) {
      throw RepositoryException('Failed to fetch portfolio: $e');
    }
  }
}
```

### Service Layer
```dart
@injectable
class PortfolioService {
  final PortfolioRepository _repository;
  
  PortfolioService(this._repository);

  Future<Portfolio> getPortfolio(String userId) async {
    try {
      return await _repository.getPortfolio(userId);
    } catch (e) {
      debugPrint('Error fetching portfolio: $e');
      
      // Fallback to mock data in development environment
      if (_isDevelopmentEnvironment()) {
        debugPrint('Using mock portfolio data in development');
        return _getMockPortfolio(userId);
      }
      rethrow;
    }
  }

  Future<List<Holding>> getHoldings(String userId) async {
    try {
      return await _repository.getHoldings(userId);
    } catch (e) {
      debugPrint('Error fetching holdings: $e');
      
      // Check if environment is dev or mock data is enabled
      if (_isDevelopmentEnvironment() || ConfigService.mockDataEnabled) {
        debugPrint('Using mock holdings data in development');
        return _getMockHoldings(userId);
      }
      rethrow;
    }
  }

  bool _isDevelopmentEnvironment() {
    return const String.fromEnvironment('ENVIRONMENT', defaultValue: 'prod') == 'dev';
  }

  Future<Portfolio> _getMockPortfolio(String userId) async {
    return MockPortfolioDataProvider.getPortfolio(userId);
  }

  Future<List<Holding>> _getMockHoldings(String userId) async {
    return MockPortfolioDataProvider.getHoldings(userId);
  }
}
```

## Riverpod Provider Patterns

### Client Provider
```dart
@riverpod
PortfolioClient portfolioClient(PortfolioClientRef ref) {
  final dio = ref.read(dioProvider);
  final baseUrl = ref.read(apiConfigProvider).baseUrl;
  return PortfolioClient(dio, baseUrl: baseUrl);
}
```

### Repository Provider
```dart
@riverpod
PortfolioRepository portfolioRepository(PortfolioRepositoryRef ref) {
  final client = ref.read(portfolioClientProvider);
  return PortfolioRepositoryImpl(client);
}
```

### Service Provider
```dart
@riverpod
PortfolioService portfolioService(PortfolioServiceRef ref) {
  final repository = ref.read(portfolioRepositoryProvider);
  return PortfolioService(repository);
}
```

### Data Providers
```dart
@riverpod
Future<Portfolio> portfolioData(
  PortfolioDataRef ref, 
  String userId,
) async {
  final service = ref.read(portfolioServiceProvider);
  return service.getPortfolio(userId);
}
```

## Widget Implementation Pattern

### Consumer Widget Usage
```dart
class PortfolioScreen extends ConsumerWidget {
  final String userId;
  
  const PortfolioScreen({required this.userId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final portfolioAsync = ref.watch(portfolioDataProvider(userId));
    
    return Scaffold(
      body: portfolioAsync.when(
        data: (portfolio) => _buildPortfolioView(portfolio),
        loading: () => const LoadingWidget(),
        error: (error, stack) => ErrorWidget(error.toString()),
      ),
    );
  }

  Widget _buildPortfolioView(Portfolio portfolio) {
    return PortfolioView(portfolio: portfolio);
  }
}
```

## Error Handling Pattern

### Repository Level
```dart
Future<Portfolio> getPortfolio(String userId) async {
  try {
    final response = await _client.getPortfolio(userId);
    return _mapResponse(response);
  } on DioException catch (e) {
    throw _handleDioError(e);
  } catch (e) {
    throw RepositoryException('Unexpected error: $e');
  }
}

RepositoryException _handleDioError(DioException e) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
      return RepositoryException('Connection timeout');
    case DioExceptionType.receiveTimeout:
      return RepositoryException('Request timeout');
    default:
      return RepositoryException('Network error: ${e.message}');
  }
}
```

## Reusable Component Patterns

### Generic Repository Pattern
Create base repository classes that can be extended for specific entities.

```dart
// lib/core/data/repositories/base_repository.dart
@injectable
abstract class BaseRepository<TEntity, TApiModel> {
  Future<TEntity> getById(String id);
  Future<List<TEntity>> getAll();
  TEntity mapFromApi(TApiModel apiModel);
}

// lib/core/data/repositories/portfolio_repository.dart
@Injectable(as: PortfolioRepository)
class PortfolioRepositoryImpl extends BaseRepository<Portfolio, ApiPortfolio> 
    implements PortfolioRepository {
  final PortfolioClient _client;
  
  PortfolioRepositoryImpl(this._client);

  @override
  Future<Portfolio> getById(String userId) async {
    final response = await _client.getPortfolio(userId);
    return mapFromApi(response);
  }

  @override
  Portfolio mapFromApi(ApiPortfolio apiModel) {
    return PortfolioMapper.fromApi(apiModel);
  }
}
```

### Reusable Service Mixins
Create mixins for common service functionality.

```dart
// lib/core/services/mixins/error_handling_mixin.dart
mixin ErrorHandlingMixin {
  Future<T> handleApiCall<T>(Future<T> Function() apiCall) async {
    try {
      return await apiCall();
    } on DioException catch (e) {
      throw _mapDioException(e);
    } catch (e) {
      throw ServiceException('Unexpected error: $e');
    }
  }

  ServiceException _mapDioException(DioException e) {
    switch (e.response?.statusCode) {
      case 401:
        return AuthenticationException('Authentication failed');
      case 403:
        return AuthorizationException('Access denied');
      case 404:
        return NotFoundException('Resource not found');
      default:
        return ServiceException('Network error: ${e.message}');
    }
  }
}

// lib/core/services/mixins/mock_data_mixin.dart
mixin MockDataMixin {
  bool get isDevelopment => 
      const String.fromEnvironment('ENVIRONMENT') == 'dev';
  
  bool get mockDataEnabled => 
      const bool.fromEnvironment('MOCK_DATA_ENABLED', defaultValue: false);

  Future<T> withMockFallback<T>(
    Future<T> Function() apiCall,
    Future<T> Function() mockDataProvider,
  ) async {
    try {
      return await apiCall();
    } catch (e) {
      if (isDevelopment || mockDataEnabled) {
        debugPrint('Using mock data due to error: $e');
        return mockDataProvider();
      }
      rethrow;
    }
  }
}

// Usage in service
@injectable
class PortfolioService with ErrorHandlingMixin, MockDataMixin {
  final PortfolioRepository _repository;
  
  PortfolioService(this._repository);

  Future<Portfolio> getPortfolio(String userId) async {
    return withMockFallback(
      () => handleApiCall(() => _repository.getPortfolio(userId)),
      () => MockPortfolioProvider.getPortfolio(userId),
    );
  }
}
```

### Reusable Provider Templates
Create provider templates for common patterns.

```dart
// lib/core/providers/templates/data_provider_template.dart
@riverpod
Future<T> dataProvider<T>(
  DataProviderRef ref,
  String key,
  Future<T> Function() fetcher,
) async {
  return fetcher();
}

@riverpod
class ListNotifier<T> extends _$ListNotifier<T> {
  @override
  Future<List<T>> build(Future<List<T>> Function() fetcher) async {
    return fetcher();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => fetcher());
  }

  void addItem(T item) {
    state.whenData((items) {
      state = AsyncValue.data([...items, item]);
    });
  }

  void removeItem(bool Function(T) predicate) {
    state.whenData((items) {
      state = AsyncValue.data(items.where((item) => !predicate(item)).toList());
    });
  }
}
```

### Composable Widget Builders
Create small widget building functions that can be composed.

```dart
// lib/widgets/builders/card_builders.dart
class CardBuilders {
  static Widget buildInfoCard({
    required String title,
    required String value,
    String? subtitle,
    IconData? icon,
  }) {
    return Card(
      child: ListTile(
        leading: icon != null ? Icon(icon) : null,
        title: Text(title),
        subtitle: subtitle != null ? Text(subtitle) : null,
        trailing: Text(value),
      ),
    );
  }

  static Widget buildMetricCard({
    required String label,
    required double value,
    required bool isPositive,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(label),
            CurrencyDisplay(
              amount: value,
              style: TextStyle(
                color: isPositive ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Usage in screens
Widget build(BuildContext context, WidgetRef ref) {
  return Column(
    children: [
      CardBuilders.buildInfoCard(
        title: 'Portfolio Value',
        value: CurrencyUtils.formatCurrency(portfolio.totalValue),
        icon: Icons.account_balance_wallet,
      ),
      CardBuilders.buildMetricCard(
        label: 'Daily Change',
        value: portfolio.dailyChange,
        isPositive: portfolio.dailyChange >= 0,
      ),
    ],
  );
}
```