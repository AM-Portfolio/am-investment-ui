```markdown
# File Organization Rules

> **Related Documentation:** For development workflow and build rules, see [DEVELOPMENT_RULES.md](./DEVELOPMENT_RULES.md)

## Directory Structure

```
lib/
│
├── core/                          # ✅ App-wide infrastructure
│   │
│   ├── app_logic/                 # 🧠 App-level shared logic (used by multiple features)
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── auth_remote_data_source.dart
│   │   │   │   └── user_prefs_local_data_source.dart
│   │   │   │
│   │   │   └── repositories/
│   │   │       ├── auth_repository_impl.dart
│   │   │       └── user_prefs_repository_impl.dart
│   │   │
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── user.dart
│   │   │   │   ├── session.dart
│   │   │   │   └── app_config.dart
│   │   │   │
│   │   │   ├── repositories/
│   │   │   │   ├── auth_repository.dart          # abstract
│   │   │   │   └── user_prefs_repository.dart    # abstract
│   │   │   │
│   │   │   └── usecases/
│   │   │       ├── login_use_case.dart
│   │   │       ├── logout_use_case.dart
│   │   │       └── get_app_config_use_case.dart
│   │   │
│   │   └── services/
│   │       ├── auth_service.dart
│   │       └── notification_service.dart
│   │
│   ├── constants/
│   │   ├── app_routes.dart        # '/login', '/home', '/portfolio', etc.
│   │   └── api_endpoints.dart     # '/api/v1/auth', '/api/v1/documents', etc.
│   │
│   ├── errors/
│   │   ├── failures.dart
│   │   └── exception_mapper.dart
│   │
│   ├── network/
│   │   ├── api_client.dart
│   │   └── dtos/
│   │       ├── auth_dtos.dart
│   │       ├── user_dtos.dart
│   │       ├── portfolio_dtos.dart
│   │       ├── trade_dtos.dart
│   │       └── document_dtos.dart
│   │
│   └── utils/
│       ├── date_utils.dart
│       ├── string_utils.dart
│       └── filter_sort_utils.dart
│
├── shared/                        # ✅ Reusable across features & platforms
│   ├── models/                    # (optional: UI-safe copies of core/app_logic entities)
│   │   └── user.dart
│   │
│   └── widgets/                   # Shared UI components
│       ├── inputs/
│       ├── buttons/
│       ├── data_table/
│       └── animations/
│
├── platform/                      # Platform-specific services
│   ├── android/
│   │   ├── android_biometric_auth.dart
│   │   ├── android_file_picker.dart
│   │   └── android_deep_link_handler.dart
│   │
│   └── ios/
│       ├── ios_biometric_auth.dart
│       ├── ios_file_picker.dart
│       └── ios_universal_link_handler.dart
│
├── features/                      # ✅ Feature modules
│   │
│   ├── auth/                      # 🔑 Authentication (Login, Signup, Forgot Password)
│   │   ├── internal/
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── services/
│   │   │       └── auth_workflow_service.dart  # Handles login + analytics + session
│   │   │
│   │   └── presentation/
│   │       ├── cubit/
│   │       │   └── auth_cubit.dart
│   │       ├── common/
│   │       │   └── widgets/
│   │       ├── mobile/
│   │       │   └── login_screen.dart
│   │       ├── android/
│   │       │   └── login_screen.dart
│   │       └── ios/
│   │           └── login_screen.dart
│   │
│   ├── home/                      # 🏠 Main Dashboard (Overview, Quick Actions)
│   │   ├── internal/
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── services/
│   │   │       └── home_dashboard_service.dart
│   │   │
│   │   └── presentation/
│   │       ├── cubit/
│   │       │   └── home_cubit.dart
│   │       ├── common/
│   │       │   └── widgets/
│   │       │       ├── portfolio_summary_card.dart
│   │       │       └── trade_activity_card.dart
│   │       ├── mobile/
│   │       │   └── home_screen.dart
│   │       ├── android/
│   │       │   └── home_screen.dart
│   │       └── ios/
│   │           └── home_screen.dart
│   │
│   ├── portfolio/                 # 📊 Portfolio Holdings & Performance
│   │   ├── internal/
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── services/
│   │   │       └── portfolio_sync_service.dart
│   │   │
│   │   └── presentation/
│   │       ├── cubit/
│   │       │   └── portfolio_cubit.dart
│   │       ├── common/
│   │       │   └── widgets/
│   │       ├── mobile/
│   │       │   └── portfolio_screen.dart
│   │       ├── android/
│   │       │   └── portfolio_screen.dart
│   │       └── ios/
│   │           └── portfolio_screen.dart
│   │
│   ├── trade_management/          # 💹 Trade History, Orders, Execution
│   │   ├── internal/
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── services/
│   │   │       └── trade_execution_service.dart
│   │   │
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
│   └── document_processing/       # 📄 Upload, Parse, Verify Documents (KYC, etc.)
│       ├── internal/
│       │   ├── data/
│       │   ├── domain/
│       │   └── services/
│       │       └── document_upload_service.dart
│       │
│       └── presentation/
│           ├── cubit/
│           │   └── document_cubit.dart
│           ├── common/
│           │   └── widgets/
│           │       ├── document_upload_card.dart
│           │       └── verification_status_badge.dart
│           ├── mobile/
│           │   └── document_screen.dart
│           ├── android/
│           │   └── document_screen.dart        # Uses Android file picker
│           └── ios/
│               └── document_screen.dart        # Uses iOS document picker
│
├── di/                            # Dependency Injection
│   ├── injection.dart
│   └── injection.config.dart
│
├── config/
│   └── app_config.dart            # Reads from env (mock mode, base URL)
│
├── assets/
│   └── mock/
│       ├── auth.json
│       ├── home.json
│       ├── portfolio.json
│       ├── trade.json
│       └── document.json
│
├── main.dart                      # ✅ Single entry point (Android, iOS, Web)
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