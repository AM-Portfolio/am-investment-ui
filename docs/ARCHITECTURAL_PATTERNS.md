```markdown
# Architectural Patterns

> **Related Documentation:** For API client implementation, HTTP patterns, and Retrofit usage, see [API_GUIDELINES.md](./API_GUIDELINES.md)

## Clean Architecture Layers

### 1. Data Layer (`lib/core      }      rethrow;
    }
  }
}
```

### Environment and Configuration Patterns
```dart
class EnvironmentConfig {
  static bool get isDevelopment => 
      const String.fromEnvironment('ENVIRONMENT') == 'dev';
  
  static bool get isProduction => 
      const String.fromEnvironment('ENVIRONMENT') == 'prod';
  
  static bool get mockDataEnabled => 
      const bool.fromEnvironment('MOCK_DATA_ENABLED', defaultValue: false);
}

// Use in services for environment-specific behavior
abstract class BaseService {
  bool get shouldUseMockData => 
      EnvironmentConfig.isDevelopment || EnvironmentConfig.mockDataEnabled;
      
  Future<T> withEnvironmentFallback<T>(
    Future<T> Function() production,
    Future<T> Function() development,
  ) async {
    if (EnvironmentConfig.isDevelopment) {
      try {
        return await production();
      } catch (e) {
        debugPrint('Production call failed, using development fallback: $e');
        return development();
      }
    }
    return production();
  }
}
```ta/
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

> **Note:** For complete API client and HTTP implementation details, see [API_GUIDELINES.md](./API_GUIDELINES.md)

### Repository Interface Design
```dart
@injectable
abstract class PortfolioRepository {
  Future<Portfolio> getPortfolio(String userId);
  Future<List<Holding>> getHoldings(String userId);
  Stream<Portfolio> watchPortfolio(String userId);
}
```

### Abstract Repository Pattern
Create base repository classes for common functionality:

```dart
abstract class BaseRepository<TEntity, TId> {
  Future<TEntity?> getById(TId id);
  Future<List<TEntity>> getAll();
  Future<TEntity> create(TEntity entity);
  Future<TEntity> update(TEntity entity);
  Future<void> delete(TId id);
}
```

### Service Layer Abstraction
Services should focus on business logic, not API concerns:

```dart
@injectable
abstract class PortfolioService {
  Future<Portfolio> getPortfolio(String userId);
  Future<void> refreshPortfolio(String userId);
  Stream<Portfolio> watchPortfolio(String userId);
}

class PortfolioServiceImpl implements PortfolioService {
  final PortfolioRepository _repository;
  final CacheService _cache;
  
  PortfolioServiceImpl(this._repository, this._cache);

  @override
  Future<Portfolio> getPortfolio(String userId) async {
    // Business logic: check cache, validate user, apply transforms
    final cached = await _cache.get('portfolio_$userId');
    if (cached != null && !_isStale(cached)) {
      return cached;
    }
    
    final portfolio = await _repository.getPortfolio(userId);
    await _cache.set('portfolio_$userId', portfolio);
    return portfolio;
  }
}
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

## Dependency Injection Architecture

> **Note:** For specific API client provider implementations, see [API_GUIDELINES.md](./API_GUIDELINES.md)

### Provider Hierarchy Organization
Organize providers in logical layers that mirror your architecture:

```dart
// Core Infrastructure Layer
@riverpod
Dio dio(DioRef ref) => Dio();

@riverpod 
ConfigService configService(ConfigServiceRef ref) => ConfigService();

// Data Access Layer  
@riverpod
PortfolioRepository portfolioRepository(PortfolioRepositoryRef ref) {
  // Implementation details in API_GUIDELINES.md
}

// Business Logic Layer
@riverpod
PortfolioService portfolioService(PortfolioServiceRef ref) {
  final repository = ref.read(portfolioRepositoryProvider);
  final cache = ref.read(cacheServiceProvider);
  return PortfolioServiceImpl(repository, cache);
}

// Presentation Data Layer
@riverpod
Future<Portfolio> portfolioData(
  PortfolioDataRef ref, 
  String userId,
) async {
  final service = ref.read(portfolioServiceProvider);
  return service.getPortfolio(userId);
}
```

### Provider Scoping Strategy
```dart
// Global providers (singletons)
@riverpod
DatabaseService databaseService(DatabaseServiceRef ref) {
  // Expensive to create, shared across app
}

// Scoped providers (per feature/user)
@riverpod
Future<UserProfile> userProfile(
  UserProfileRef ref,
  String userId,
) async {
  // Scoped to specific user
}

// Disposable providers (auto-dispose when not watched)
@riverpod
Stream<MarketData> marketDataStream(MarketDataStreamRef ref) {
  // Automatically disposed when no listeners
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

## Domain Error Handling Pattern

> **Note:** For API-specific error handling (HTTP, Dio exceptions), see [API_GUIDELINES.md](./API_GUIDELINES.md)

### Domain Exception Hierarchy
```dart
abstract class DomainException implements Exception {
  final String message;
  final String? code;
  
  const DomainException(this.message, {this.code});
}

class ValidationException extends DomainException {
  final Map<String, List<String>> fieldErrors;
  
  const ValidationException(
    super.message, {
    super.code,
    this.fieldErrors = const {},
  });
}

class BusinessRuleException extends DomainException {
  const BusinessRuleException(super.message, {super.code});
}

class ResourceNotFoundException extends DomainException {
  final String resourceType;
  final String resourceId;
  
  const ResourceNotFoundException(
    this.resourceType,
    this.resourceId,
  ) : super('$resourceType with id $resourceId not found');
}
```

### Service Layer Error Translation
```dart
abstract class BaseService {
  Future<T> executeWithErrorHandling<T>(
    Future<T> Function() operation,
    String operationName,
  ) async {
    try {
      return await operation();
    } on RepositoryException catch (e) {
      // Translate repository errors to domain errors
      throw _translateRepositoryError(e, operationName);
    } catch (e) {
      throw DomainException('Unexpected error in $operationName: $e');
    }
  }
  
  DomainException _translateRepositoryError(RepositoryException e, String operation) {
    if (e is NotFoundException) {
      return ResourceNotFoundException('Resource', 'unknown');
    }
    if (e is ValidationException) {
      return ValidationException(e.message);
    }
    return DomainException('Repository error in $operation: ${e.message}');
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