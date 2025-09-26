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

## Dependency Injection with Riverpod

### Always Use Riverpod for Object Creation
Never manually initialize objects in widgets/features. Always use Riverpod providers.

```dart
// ❌ Bad - Manual initialization
class PortfolioScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final service = PortfolioService(PortfolioClient(Dio()));
    // ...
  }
}

// ✅ Good - Use Riverpod providers
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
```

## Dart/Flutter Code Style

### File Naming
- Use snake_case for file names: `portfolio_service.dart`
- Use PascalCase for class names: `PortfolioService`
- Use camelCase for variables: `portfolioData`

### Import Organization
```dart
// 1. Dart core libraries
import 'dart:async';

// 2. Flutter libraries  
import 'package:flutter/material.dart';

// 3. Third-party packages
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:retrofit/retrofit.dart';
import 'package:injectable/injectable.dart';

// 4. Internal imports - relative paths
import '../config/app_config.dart';
import '../../domain/entities/portfolio.dart';
```

### Required Annotations

#### Data Classes - Use @freezed
```dart
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
@injectable
class PortfolioService {
  final PortfolioRepository _repository;
  
  PortfolioService(this._repository);
  
  Future<Portfolio> getPortfolio(String userId) async {
    return _repository.getPortfolio(userId);
  }
}
```

#### API Calls - Use @retrofit
```dart
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
// lib/widgets/shared/loading_indicator.dart
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

// lib/widgets/shared/currency_display.dart
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