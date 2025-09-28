# Architectural Patterns

> **Related Documentation:** For API client implementation, HTTP patterns, and Retrofit usage, see [API_GUIDELINES.md](./API_GUIDELINES.md)

## Clean Architecture Layers

### 1. Data Layer (`lib/features/[feature]/internal/data/`)
```
internal/data/
├── datasources/         # Remote (API) and local data sources
├── dtos/               # Data Transfer Objects (API request/response models) 
├── mappers/            # Data transformation between API and domain
└── repositories/       # Repository implementations
```

### 2. Domain Layer (`lib/features/[feature]/internal/domain/`)
```
internal/domain/
├── entities/           # Business entities (Freezed classes)
├── repositories/       # Repository interfaces (abstract classes)
└── usecases/          # Single-purpose business use cases
```

### 3. Service Layer (`lib/features/[feature]/internal/services/`)
```
internal/services/
├── [feature]_service.dart    # Business logic orchestration
└── clients/                  # API clients (Retrofit style) - if feature-specific
```

**Note:** Global API clients are still in `lib/core/network/` for shared use across features.

### 4. Presentation Layer (`lib/features/[feature]/presentation/`)
```
presentation/
├── cubit/              # State management (BLoC/Cubit)
├── common/             # Widgets shared between web/mobile
├── mobile/             # Mobile-specific UI components
├── web/               # Web-specific UI components  
├── pages/             # Screen/page implementations
└── widgets/           # Feature-specific UI components
```

## Repository Pattern Implementation

> **Note:** For complete API client and HTTP implementation details, see [API_GUIDELINES.md](./API_GUIDELINES.md)

### Repository Interface Design
```dart
// lib/features/portfolio/internal/domain/repositories/portfolio_repository.dart
abstract class PortfolioRepository {
  Future<Portfolio> getPortfolio(String userId);
  Future<List<Holding>> getHoldings(String userId);
  Stream<Portfolio> watchPortfolio(String userId);
}

// lib/features/portfolio/internal/data/repositories/portfolio_repository_impl.dart
class PortfolioRepositoryImpl implements PortfolioRepository {
  final PortfolioDataSource _dataSource;
  
  const PortfolioRepositoryImpl(this._dataSource);

// Provider in lib/features/portfolio/providers/portfolio_providers.dart
@riverpod
PortfolioRepository portfolioRepository(PortfolioRepositoryRef ref) {
  final dataSource = ref.watch(portfolioDataSourceProvider);
  return PortfolioRepositoryImpl(dataSource);
}
  
  @override
  Future<Portfolio> getPortfolio(String userId) async {
    final dto = await _dataSource.getPortfolio(userId);
    return PortfolioMapper.fromDto(dto);
  }
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
// lib/features/portfolio/internal/services/portfolio_service.dart
abstract class PortfolioService {
  Future<Portfolio> getPortfolio(String userId);
  Future<void> refreshPortfolio(String userId);
  Stream<Portfolio> watchPortfolio(String userId);
}

class PortfolioServiceImpl implements PortfolioService {
  final PortfolioRepository _repository;
  final CacheService _cache;
  
  const PortfolioServiceImpl(this._repository, this._cache);

// Provider in lib/features/portfolio/providers/portfolio_providers.dart
@riverpod
PortfolioService portfolioService(PortfolioServiceRef ref) {
  final repository = ref.watch(portfolioRepositoryProvider);
  final cache = ref.watch(cacheServiceProvider);
  return PortfolioServiceImpl(repository, cache);
}

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
  
  @override
  Future<void> refreshPortfolio(String userId) async {
    try {
      final portfolio = await _repository.getPortfolio(userId);
      await _cache.set('portfolio_$userId', portfolio);
    } catch (e) {
      debugPrint('Error refreshing portfolio: $e');
      
      // Use mock data in development if available
      if (_isDevelopmentEnvironment() && _hasMockDataFor<Portfolio>()) {
        debugPrint('Falling back to mock data for portfolio');
        final mockPortfolio = await _getMockPortfolio(userId);
        await _cache.set('portfolio_$userId', mockPortfolio);
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
// lib/features/portfolio/presentation/pages/portfolio_screen.dart
class PortfolioScreen extends ConsumerWidget {
  final String userId;
  
  const PortfolioScreen({required this.userId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final portfolioAsync = ref.watch(portfolioDataProvider(userId));
    
    return Scaffold(
      body: portfolioAsync.when(
        data: (portfolio) => _buildPortfolioView(portfolio),
        loading: () => const CircularProgressIndicator(),
        error: (error, stack) => ErrorWidget(error),
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

// lib/features/portfolio/internal/data/repositories/portfolio_repository_impl.dart
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
// lib/core/mixins/error_handling_mixin.dart
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
      case 500:
        return ServerException('Internal server error');
      default:
        return ServiceException('HTTP error: ${e.response?.statusCode}');
    }
  }
}

// lib/core/mixins/mock_data_mixin.dart
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
        debugPrint('API call failed, using mock data: $e');
        return mockDataProvider();
      }
      rethrow;
    }
  }
}

// Usage in service - lib/features/portfolio/internal/services/portfolio_service.dart
@Injectable(as: PortfolioService)
class PortfolioServiceImpl with ErrorHandlingMixin, MockDataMixin implements PortfolioService {
  final PortfolioRepository _repository;
  
  PortfolioServiceImpl(this._repository);

  Future<Portfolio> getPortfolio(String userId) async {
    return withMockFallback(
      () => handleApiCall(() => _repository.getPortfolio(userId)),
      () => _getMockPortfolio(userId),
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
// lib/shared/widgets/builders/card_builders.dart
class CardBuilders {
  static Widget buildInfoCard({
    required String title,
    required String value,
    String? subtitle,
    IconData? icon,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (icon != null) Icon(icon),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(value, style: const TextStyle(fontSize: 24)),
            if (subtitle != null) Text(subtitle),
          ],
        ),
      ),
    );
  }

  static Widget buildMetricCard({
    required String label,
    required String value,
    required String change,
    required bool isPositive,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(label),
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(
              change,
              style: TextStyle(
                color: isPositive ? Colors.green : Colors.red,
                fontWeight: FontWeight.w500,
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
        title: 'Total Portfolio Value',
        value: '\$${portfolio.totalValue.toStringAsFixed(2)}',
        icon: Icons.account_balance_wallet,
      ),
      CardBuilders.buildMetricCard(
        label: 'Daily Change',
        value: '\$${portfolio.dailyChange.toStringAsFixed(2)}',
        change: '${portfolio.percentageChange.toStringAsFixed(2)}%',
        isPositive: portfolio.dailyChange >= 0,
      ),
    ],
  );
}
```

## Environment and Configuration Patterns

### Environment Detection
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
```