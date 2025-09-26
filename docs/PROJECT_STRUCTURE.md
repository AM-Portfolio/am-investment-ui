```markdown
# File Organization Rules

## Directory Structure

```
lib/
├── core/                          # Core functionality
│   ├── config/                    # Configuration management
│   ├── data/                      # Data layer
│   │   ├── api/models/            # API models (@freezed + @JsonSerializable)
│   │   ├── repositories/          # Repository implementations (@Injectable)
│   │   └── mappers/               # Data mapping (static methods)
│   ├── domain/                    # Domain layer
│   │   ├── entities/              # Business entities (@freezed)
│   │   └── repositories/          # Repository interfaces (@injectable)
│   ├── clients/                   # API clients (@retrofit + @injectable)
│   ├── providers/                 # Riverpod providers (@riverpod)
│   └── services/                  # Business services (@injectable)
├── features/                      # Feature modules
│   └── [feature]/
│       ├── screens/               # ConsumerWidget screens
│       ├── widgets/               # Feature-specific widgets
│       └── providers/             # Feature-specific providers (@riverpod)
├── widgets/shared/                # Shared widgets
└── main.dart                      # App entry point
```

## Naming Conventions & Annotations

### Files & Required Annotations
- **API Models**: `api_[feature].dart` → `@freezed` + `@JsonSerializable`
- **Domain Entities**: `[feature].dart` → `@freezed`
- **Services**: `[feature]_service.dart` → `@injectable`
- **Clients**: `[feature]_client.dart` → `@RestApi` + `@injectable`
- **Repositories**: `[feature]_repository.dart` → `@Injectable(as: Interface)`
- **Providers**: `[feature]_providers.dart` → `@riverpod`
- **Screens**: `[feature]_screen.dart` → `ConsumerWidget`

### Classes & Annotations
- **API Models**: `Api[Feature]Response` → `@freezed`
- **Domain Entities**: `[Feature]` → `@freezed`
- **Services**: `[Feature]Service` → `@injectable`
- **Clients**: `[Feature]Client` → `@RestApi` + `@injectable`
- **Repositories**: `[Feature]Repository` → `@Injectable(as: I[Feature]Repository)`

## Riverpod Provider Organization

### Provider Files Structure
```dart
// lib/core/providers/api_providers.dart
@riverpod
Dio dio(DioRef ref) {
  return Dio()..interceptors.add(LoggingInterceptor());
}

@riverpod
ApiConfig apiConfig(ApiConfigRef ref) {
  return ApiConfig.fromProperties();
}

// lib/features/portfolio/providers/portfolio_providers.dart
@riverpod
PortfolioClient portfolioClient(PortfolioClientRef ref) {
  final dio = ref.read(dioProvider);
  final config = ref.read(apiConfigProvider);
  return PortfolioClient(dio, baseUrl: config.baseUrl);
}

@riverpod
PortfolioRepository portfolioRepository(PortfolioRepositoryRef ref) {
  final client = ref.read(portfolioClientProvider);
  return PortfolioRepositoryImpl(client);
}

@riverpod
Future<Portfolio> portfolio(PortfolioRef ref, String userId) async {
  final repository = ref.read(portfolioRepositoryProvider);
  return repository.getPortfolio(userId);
}
```

## Method & File Size Rules

### Code Constraints
- **Maximum method length**: 20 lines
- **Maximum file length**: 500 lines
- **When exceeding**: Extract to separate files/methods

```dart
// ❌ Bad - File too large (500+ lines)
class MegaPortfolioService {
  // 600+ lines of methods
}

// ✅ Good - Split into focused services
class PortfolioService {        // < 500 lines
  // Portfolio-specific logic
}

class PortfolioCalculationService {  // < 500 lines
  // Calculation-specific logic
}

class PortfolioValidationService {   // < 500 lines
  // Validation-specific logic
}
```

## Import Rules

1. **Always use relative imports** within the project
2. **Group imports** by type (core, flutter, packages, internal)
3. **Sort imports** alphabetically within groups
4. **Use barrel exports** where appropriate

```dart
// Barrel export example - lib/core/providers/providers.dart
export 'api_providers.dart';
export 'auth_providers.dart';
export 'config_providers.dart';
```

## Asset Organization

```
assets/
├── application.properties         # Main config
├── application-dev.properties     # Dev config
├── application-prod.properties    # Prod config
└── config/                       # Additional configs
```

## Reusable Component Organization

### Utility Classes Structure
```
lib/core/utils/
├── date_utils.dart           # Date formatting and manipulation
├── currency_utils.dart       # Currency formatting
├── validation_utils.dart     # Input validation
├── calculation_utils.dart    # Mathematical calculations
└── string_utils.dart         # String manipulation
```

### Shared Widget Structure
```
lib/widgets/shared/
├── buttons/                  # Reusable button components
│   ├── primary_button.dart
│   └── icon_button_with_text.dart
├── cards/                    # Reusable card components
│   ├── info_card.dart
│   └── metric_card.dart
├── indicators/               # Loading and status indicators
│   ├── loading_indicator.dart
│   └── status_indicator.dart
└── displays/                 # Data display components
    ├── currency_display.dart
    └── percentage_display.dart
```

### Mixin Organization
```
lib/core/mixins/
├── error_handling_mixin.dart # Error handling functionality
├── mock_data_mixin.dart      # Mock data fallback
├── validation_mixin.dart     # Input validation
└── logging_mixin.dart        # Logging functionality
```

### Template and Builder Organization
```
lib/core/templates/
├── providers/                # Provider templates
├── repositories/             # Repository templates
└── services/                 # Service templates

lib/widgets/builders/
├── card_builders.dart        # Card building functions
├── list_builders.dart        # List building functions
└── form_builders.dart        # Form building functions
```

### Configuration Structure
```
lib/core/config/
├── ui_config.dart           # UI configuration classes
├── api_config.dart          # API configuration
├── theme_config.dart        # Theme configuration
└── feature_flags.dart       # Feature flag configuration
```

### Barrel Export Examples
```dart
// lib/core/utils/utils.dart
export 'date_utils.dart';
export 'currency_utils.dart';
export 'validation_utils.dart';
export 'calculation_utils.dart';

// lib/widgets/shared/shared_widgets.dart
export 'buttons/primary_button.dart';
export 'cards/info_card.dart';
export 'displays/currency_display.dart';

// lib/core/mixins/mixins.dart
export 'error_handling_mixin.dart';
export 'mock_data_mixin.dart';
export 'validation_mixin.dart';
```

### Import Best Practices for Reusability
```dart
// Use barrel imports for better organization
import '../../../core/utils/utils.dart';
import '../../../widgets/shared/shared_widgets.dart';
import '../../../core/mixins/mixins.dart';

// Instead of individual imports
// import '../../../core/utils/date_utils.dart';
// import '../../../core/utils/currency_utils.dart';
// import '../../../widgets/shared/buttons/primary_button.dart';
```