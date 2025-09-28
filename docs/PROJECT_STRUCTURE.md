```markdown
# File Organization Rules

> **Related Documentation:** For development workflow and build rules, see [DEVELOPMENT_RULES.md](./DEVELOPMENT_RULES.md)

## Directory Structure

```
lib/
│
├── core/                          # Infrastructure & cross-cutting concerns
│   ├── constants/                 # App-wide constants
│   │   ├── app_routes.dart        # Route names (e.g., '/portfolio')
│   │   └── api_endpoints.dart     # API paths (e.g., '/api/v1/portfolios')
│   │
│   ├── errors/                    # Failure types & error handling
│   │   ├── failures.dart          # NetworkFailure, AuthFailure, CacheFailure
│   │   └── exception_mapper.dart  # Maps Dio/HTTP errors to domain failures
│   │
│   ├── network/                   # API layer (100% shared)
│   │   ├── api_client.dart        # Global Retrofit-style client (dio + retrofit.dart)
│   │   └── dtos/                  # ✅ All backend-matching DTOs (Spring Boot contracts)
│   │       ├── auth_dtos.dart     # LoginRequest, TokenResponse
│   │       ├── user_dtos.dart     # UserResponse
│   │       ├── portfolio_dtos.dart
│   │       └── trade_dtos.dart
│   │
│   └── utils/                     # Pure, stateless helpers
│       ├── date_utils.dart        # Formatting, parsing
│       ├── string_utils.dart      # Validation, sanitization
│       └── filter_sort_utils.dart # ✅ Reusable filtering/sorting (stateless)
│
├── shared/                        # Reusable across features & platforms
│   │
│   ├── models/                    # Pure domain models (no JSON, no annotations)
│   │   └── user.dart              # Used in portfolio, trade, profile, etc.
│   │
│   ├── widgets/                   # ✅ Cross-feature, cross-platform UI
│   │   │
│   │   ├── inputs/                # Form controls
│   │   │   ├── app_dropdown.dart
│   │   │   ├── app_text_field.dart
│   │   │   └── app_date_picker.dart
│   │   │
│   │   ├── buttons/               # Action buttons
│   │   │   ├── primary_button.dart
│   │   │   └── icon_button.dart
│   │   │
│   │   ├── data_table/            # ✅ Smart, sortable, responsive table
│   │   │   ├── adaptive_data_table.dart
│   │   │   ├── table_header.dart
│   │   │   └── table_row.dart
│   │   │
│   │   └── animations/            # ✅ Shared motion design
│   │       ├── fade_in_animation.dart
│   │       ├── slide_route.dart
│   │       └── skeleton_loader.dart
│   │
│   └── cubits/                    # ✅ Stateful shared logic (optional)
│       └── filter_sort_cubit.dart # Reusable for portfolio, trade, analysis
│
├── platform/                      # ✅ Platform-specific services (Android/iOS only)
│   ├── android/                   # 🤖 Android-only implementations
│   │   ├── android_biometric_auth.dart
│   │   ├── android_deep_link_handler.dart
│   │   └── android_share_service.dart
│   │
│   └── ios/                       # 🍏 iOS-only implementations
│       ├── ios_biometric_auth.dart
│       ├── ios_universal_link_handler.dart
│       └── ios_share_service.dart
│
├── features/                      # Vertical slices — each is self-contained
│   │
│   ├── auth/                      # Feature: Authentication
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   ├── models/            # Auth-specific data models (if any)
│   │   │   └── repositories/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   ├── repositories/      # abstract AuthRepository
│   │   │   └── usecases/          # Login, Logout, RefreshToken
│   │   └── presentation/
│   │       ├── cubit/
│   │       │   └── auth_cubit.dart
│   │       ├── common/            # Shared login UI (email/password form)
│   │       │   └── widgets/
│   │       ├── mobile/            # Default mobile login screen
│   │       │   └── login_screen.dart
│   │       ├── android/           # 🤖 Only if Android-specific (e.g., biometric prompt)
│   │       │   └── login_screen.dart
│   │       └── ios/               # 🍏 Only if iOS-specific (e.g., Face ID flow)
│   │           └── login_screen.dart
│   │
│   ├── portfolio/                 # Feature: Portfolio Holdings
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │       ├── cubit/
│   │       │   └── portfolio_cubit.dart
│   │       ├── common/
│   │       │   └── widgets/
│   │       ├── mobile/            # Default mobile UI
│   │       │   └── portfolio_screen.dart
│   │       ├── android/           # 🤖 Only if needed (e.g., Android share intent)
│   │       │   └── portfolio_screen.dart
│   │       └── ios/               # 🍏 Only if needed (e.g., iOS share sheet)
│   │           └── portfolio_screen.dart
│   │
│   ├── trade_management/          # Feature: Trade History & Orders
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │       ├── cubit/
│   │       │   └── trade_cubit.dart
│   │       ├── common/
│   │       │   └── widgets/
│   │       ├── mobile/
│   │       │   └── trade_screen.dart
│   │       ├── android/
│   │       │   └── trade_screen.dart
│   │       └── ios/
│   │           └── trade_screen.dart
│   │
│   └── analysis/                  # Feature: Portfolio Analysis
│       ├── data/
│       ├── domain/
│       └── presentation/
│           ├── cubit/
│           │   └── analysis_cubit.dart
│           ├── common/
│           │   └── widgets/
│           ├── mobile/
│           │   └── analysis_screen.dart
│           ├── android/
│           │   └── analysis_screen.dart
│           └── ios/
│               └── analysis_screen.dart
│
├── di/                            # Dependency Injection (get_it + injectable)
│   ├── injection.dart             # Main DI setup
│   └── injection.config.dart      # Generated file
│
├── config/                        # App configuration
│   └── app_config.dart            # Reads from env (mock mode, base URL, feature flags)
│
├── assets/                        # Static resources
│   └── mock/                      # Fallback JSON for offline/mock mode
│       ├── auth.json
│       ├── portfolio.json
│       ├── trade.json
│       └── user.json
│
├── main.dart                      # ✅ SINGLE entry point (Android, iOS, Web)
└── app.dart                       # Root app widget (adaptive navigation)
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

> **Note:** For complete provider patterns and dependency injection details, see [ARCHITECTURAL_PATTERNS.md](./ARCHITECTURAL_PATTERNS.md)

### Provider File Structure Rules
```dart
// lib/core/providers/core_providers.dart - Infrastructure providers
@riverpod
Dio dio(DioRef ref) => Dio();

// lib/features/[feature]/providers/[feature]_providers.dart - Feature providers
@riverpod
PortfolioRepository portfolioRepository(PortfolioRepositoryRef ref) {
  final client = ref.read(portfolioClientProvider);
  return PortfolioRepositoryImpl(client);
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

## Import & Export Rules

### Import Order (Mandatory)
```dart
// 1. Dart core libraries (dart:*)
import 'dart:async';
import 'dart:convert';

// 2. Flutter libraries (package:flutter/*)
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 3. Third-party packages (alphabetical)
import 'package:dio/dio.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

// 4. Internal imports (relative paths, alphabetical)
import '../config/config_service.dart';
import '../domain/entities/portfolio.dart';
import '../../widgets/shared/loading_indicator.dart';
```

### Barrel Export Strategy
```dart
// lib/core/utils/utils.dart - Export all utilities
export 'currency_utils.dart';
export 'date_utils.dart';
export 'validation_utils.dart';

// lib/core/providers/providers.dart - Export all providers
export 'api_providers.dart';
export 'auth_providers.dart';
export 'config_providers.dart';

// lib/widgets/shared/shared.dart - Export shared widgets
export 'buttons/primary_button.dart';
export 'cards/info_card.dart';
export 'displays/currency_display.dart';
```

### Import Best Practices
```dart
// ✅ Good - Use barrel imports for cleaner code
import '../../core/utils/utils.dart';
import '../../widgets/shared/shared.dart';

// ❌ Avoid - Multiple individual imports
// import '../../core/utils/currency_utils.dart';
// import '../../core/utils/date_utils.dart';
// import '../../widgets/shared/buttons/primary_button.dart';

// ✅ Good - Use relative imports within project
import '../config/config_service.dart';

// ❌ Bad - Absolute imports within project
// import 'package:am_investment_ui/core/config/config_service.dart';
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