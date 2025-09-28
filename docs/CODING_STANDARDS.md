```markdown
# Coding Standards & Conventions

## Code Size Constraints

### Method & File Limits
- **Maximum method length**: 20 lines
- **Maximum file length**: 500 lines
- **When exceeding limits**: Extract functionality into separate methods/files

```dart
// ❌ Bad - Method too long
Future<Portfolio> processPortfolioData(ApiResponse response) async {
  // 25+ lines of processing...
}

// ✅ Good - Split into smaller methods
Future<Portfolio> processPortfolioData(ApiResponse response) async {
  final holdings = _extractHoldings(response);
  final summary = _calculateSummary(holdings);
  return _buildPortfolio(holdings, summary);
}

Future<List<Holding>> _extractHoldings(ApiResponse response) async {
  // Max 20 lines
}
```

## Dependency Injection Standards

> **Note:** For complete dependency injection patterns and provider organization, see [ARCHITECTURAL_PATTERNS.md](./ARCHITECTURAL_PATTERNS.md)

### Riverpod Usage Rules
```dart
// ✅ Always use providers for object creation
class PortfolioScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final portfolioAsync = ref.watch(portfolioHoldingsProvider(userId));
    return portfolioAsync.when(
      data: (portfolio) => PortfolioView(portfolio: portfolio),
      loading: () => const CircularProgressIndicator(),
      error: (error, stack) => ErrorWidget(error),
    );
  }
}

// ❌ Never manually initialize services or repositories
final service = PortfolioService(client); // Bad!
```

## Dart/Flutter Code Style

### File Naming
- Use snake_case for file names: `portfolio_service.dart`
- Use PascalCase for class names: `PortfolioService`
- Use camelCase for variables: `portfolioData`

### Import Organization

> **Note:** For complete import rules and file organization, see [PROJECT_STRUCTURE.md](./PROJECT_STRUCTURE.md)

```dart
// Follow the import order defined in PROJECT_STRUCTURE.md:
// 1. Dart core → 2. Flutter → 3. Packages → 4. Internal (relative paths)
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../config/app_config.dart';
```

### Required Annotations

#### Data Classes - Use @freezed
```dart
// lib/features/portfolio/internal/data/dtos/api_portfolio_response.dart
@freezed
class ApiPortfolioResponse with _$ApiPortfolioResponse {
  const factory ApiPortfolioResponse({
    required String userId,
    required double totalValue,
    required double dailyChange,
    required List<ApiEquityHolding> holdings,
  }) = _ApiPortfolioResponse;

  factory ApiPortfolioResponse.fromJson(Map<String, dynamic> json) =>
      _$ApiPortfolioResponseFromJson(json);
}
```

#### State Management - Use @riverpod
```dart
// lib/features/portfolio/presentation/cubit/portfolio_cubit.dart
@riverpod
class PortfolioNotifier extends _$PortfolioNotifier {
  @override
  Future<Portfolio> build(String userId) async {
    final repository = ref.read(portfolioRepositoryProvider);
    return repository.getPortfolio(userId);
  }
}
```

#### Dependency Injection - Use @Injectable
```dart
// lib/features/portfolio/internal/services/portfolio_service.dart
@Injectable(as: PortfolioService)
class PortfolioServiceImpl implements PortfolioService {
  final PortfolioRepository _repository;
  
  PortfolioService(this._repository);
  
  Future<Portfolio> getPortfolio(String userId) async {
    return _repository.getPortfolio(userId);
  }
}
```

#### API Calls - Use @retrofit
```dart
// lib/core/network/clients/portfolio_client.dart (if global)
// OR lib/features/portfolio/internal/data/clients/portfolio_client.dart (if feature-specific)
@RestApi()
@injectable
abstract class PortfolioClient {
  @factoryMethod
  factory PortfolioClient(Dio dio, {@Named('baseUrl') String? baseUrl}) = _PortfolioClient;

  @GET('/portfolios/{userId}')
  Future<ApiPortfolioResponse> getPortfolio(@Path('userId') String userId);
}
```

## Reusable Code Design Principles

### Single Responsibility Principle
Each function/class should have one clear purpose and be easily reusable.

```dart
// ❌ Bad - Multiple responsibilities
class PortfolioProcessor {
  Future<Portfolio> processAndValidateAndSave(ApiResponse response) async {
    // Validation logic
    // Processing logic  
    // Saving logic
    // 50+ lines...
  }
}

// ✅ Good - Separate, reusable components
class PortfolioValidator {
  static bool isValid(ApiResponse response) {
    return response.data != null && response.data!.isNotEmpty;
  }
}

class PortfolioMapper {
  static Portfolio fromApi(ApiResponse response) {
    return Portfolio(/* mapping logic */);
  }
}

class PortfolioProcessor {
  Future<Portfolio> process(ApiResponse response) async {
    if (!PortfolioValidator.isValid(response)) {
      throw ValidationException('Invalid portfolio data');
    }
    return PortfolioMapper.fromApi(response);
  }
}
```

### Utility Functions Pattern
Create small, focused utility functions that can be reused across the app.

```dart
// lib/core/utils/date_utils.dart
class DateUtils {
  static String formatMarketDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }
  
  static bool isMarketOpen() {
    final now = DateTime.now();
    return now.weekday <= 5 && 
           now.hour >= 9 && 
           now.hour < 16;
  }
}

// lib/core/utils/currency_utils.dart
class CurrencyUtils {
  static String formatCurrency(double amount) {
    return NumberFormat.currency(symbol: '\$').format(amount);
  }
  
  static String formatPercentage(double value) {
    final sign = value >= 0 ? '+' : '';
    return '$sign${value.toStringAsFixed(2)}%';
  }
}

// lib/core/utils/validation_utils.dart
class ValidationUtils {
  static bool isValidUserId(String? userId) {
    return userId != null && userId.isNotEmpty && userId.length >= 3;
  }
  
  static bool isValidAmount(double? amount) {
    return amount != null && amount > 0;
  }
}
```

### Reusable Widget Components
Design small, configurable widgets that can be used in multiple contexts.

```dart
// lib/shared/widgets/loading_indicator.dart
class LoadingIndicator extends StatelessWidget {
  final String? message;
  final double size;
  
  const LoadingIndicator({
    this.message,
    this.size = 24.0,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: const CircularProgressIndicator(),
        ),
        if (message != null) ...[
          const SizedBox(height: 8),
          Text(message!),
        ],
      ],
    );
  }
}

// lib/shared/widgets/currency_display.dart
class CurrencyDisplay extends StatelessWidget {
  final double amount;
  final TextStyle? style;
  final bool showSign;
  
  const CurrencyDisplay({
    required this.amount,
    this.style,
    this.showSign = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final formattedAmount = CurrencyUtils.formatCurrency(amount);
    final displayText = showSign && amount > 0 ? '+$formattedAmount' : formattedAmount;
    
    return Text(
      displayText,
      style: style ?? Theme.of(context).textTheme.bodyMedium,
    );
  }
}
```

### Reusable Provider Patterns
Create generic, reusable providers that can be configured for different use cases.

```dart
// lib/core/providers/generic_providers.dart
@riverpod
Future<T> apiCall<T>(
  ApiCallRef ref,
  Future<T> Function() apiFunction,
  String cacheKey,
) async {
  // Generic API call with caching and error handling
  return apiFunction();
}

@riverpod
Future<List<T>> listData<T>(
  ListDataRef ref,
  Future<List<T>> Function() dataFetcher,
  String userId,
) async {
  return dataFetcher();
}

// Usage examples
@riverpod
Future<Portfolio> portfolio(PortfolioRef ref, String userId) async {
  return ref.watch(apiCallProvider(
    () => ref.read(portfolioServiceProvider).getPortfolio(userId),
    'portfolio_$userId',
  ).future);
}
```

### Configuration-Driven Components
Design components that can be configured through parameters or configuration objects.

```dart
// lib/core/config/ui_config.dart
@freezed
class CardConfig with _$CardConfig {
  const factory CardConfig({
    @Default(8.0) double borderRadius,
    @Default(EdgeInsets.all(16.0)) EdgeInsets padding,
    Color? backgroundColor,
    @Default(true) bool showShadow,
  }) = _CardConfig;
}

// lib/widgets/shared/configurable_card.dart
class ConfigurableCard extends StatelessWidget {
  final Widget child;
  final CardConfig config;
  
  const ConfigurableCard({
    required this.child,
    required this.config,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: config.backgroundColor,
      elevation: config.showShadow ? 2.0 : 0.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(config.borderRadius),
      ),
      child: Padding(
        padding: config.padding,
        child: child,
      ),
    );
  }
}
```

### Function Composition Pattern
Create small functions that can be composed together for complex operations.

```dart
// lib/core/utils/portfolio_calculations.dart
class PortfolioCalculations {
  static double calculateTotalValue(List<Holding> holdings) {
    return holdings.fold(0.0, (sum, holding) => sum + holding.currentValue);
  }
  
  static double calculateDailyChange(List<Holding> holdings) {
    return holdings.fold(0.0, (sum, holding) => sum + holding.dailyChange);
  }
  
  static double calculatePercentageChange(double current, double previous) {
    if (previous == 0) return 0.0;
    return ((current - previous) / previous) * 100;
  }
  
  static PortfolioSummary buildSummary(List<Holding> holdings) {
    final totalValue = calculateTotalValue(holdings);
    final dailyChange = calculateDailyChange(holdings);
    final previousValue = totalValue - dailyChange;
    final percentageChange = calculatePercentageChange(totalValue, previousValue);
    
    return PortfolioSummary(
      totalValue: totalValue,
      dailyChange: dailyChange,
      percentageChange: percentageChange,
    );
  }
}
```

## Testing Standards

> **Note:** For complete testing workflow and rules, see [DEVELOPMENT_RULES.md](./DEVELOPMENT_RULES.md)

### Test File Conventions
```dart
// test/features/portfolio/internal/services/portfolio_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

// Generate mocks for external dependencies only
@GenerateMocks([PortfolioClient])
void main() {
  group('PortfolioService', () {
    late PortfolioService service;
    late MockPortfolioClient mockClient;
    late PortfolioRepository repository;
    
    setUp(() {
      mockClient = MockPortfolioClient();
      // Use real repository and mapper - don't mock internal logic
      repository = PortfolioRepositoryImpl(mockClient);
      service = PortfolioService(repository);
    });
    
    test('should return portfolio data when API call succeeds', () async {
      // Arrange - Mock external API response
      when(mockClient.getPortfolio(any))
          .thenAnswer((_) async => mockApiResponse);
      
      // Act - Test real business logic
      final result = await service.getPortfolio('user123');
      
      // Assert - Validate complete flow including mapping
      expect(result.userId, 'user123');
      expect(result.holdings, isNotEmpty);
      verify(mockClient.getPortfolio('user123')).called(1);
    });
  });
}
```

### Testing Principles
1. **Mock External Dependencies Only**: HTTP clients, APIs, external services
2. **Test Real Internal Logic**: Repositories, mappers, business logic
3. **Validate Complete Flows**: End-to-end data transformation
4. **Test All Error Scenarios**: Network failures, validation errors, edge cases
5. **Use Real Data**: Test with realistic data structures and edge cases

### Mock Data Strategy
```dart
// ✅ Good - Mock external API responses
class MockApiResponses {
  static ApiPortfolioResponse get validPortfolioResponse => ApiPortfolioResponse(
    userId: 'test-user',
    totalValue: 50000.0,
    holdings: [
      ApiEquityHolding(symbol: 'AAPL', quantity: 10, currentPrice: 150.0),
      ApiEquityHolding(symbol: 'GOOGL', quantity: 5, currentPrice: 2800.0),
    ],
  );
  
  static ApiPortfolioResponse get emptyPortfolioResponse => ApiPortfolioResponse(
    userId: 'test-user',
    totalValue: 0.0,
    holdings: [],
  );
}

// ✅ Good - Test real mapper logic with mock data
test('mapper should handle empty holdings list', () {
  final apiResponse = MockApiResponses.emptyPortfolioResponse;
  final portfolio = PortfolioMapper.fromApi(apiResponse);
  
  expect(portfolio.holdings, isEmpty);
  expect(portfolio.totalValue, 0.0);
});
```