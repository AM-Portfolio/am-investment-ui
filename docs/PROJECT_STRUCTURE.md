# File Organization Rules

## Directory Structure

```
lib/
│
├── core/                          # 🧱 App-wide infrastructure used by ALL features.
│   │                              # Contains non-feature-specific utilities, network layer, and shared logic.
│   │
│   ├── app_logic/                 # 🧠 App-level shared business logic (used across multiple features).
│   │   │                          # Examples: User, Auth, AppConfig, Session.
│   │   │
│   │   ├── data/                  # App-wide data sources and repository implementations.
│   │   │   ├── datasources/       # Remote (API) and local (DB, SharedPrefs) data sources.
│   │   │   └── repositories/      # Concrete implementations of app-level repositories (e.g., AuthRepositoryImpl).
│   │   │
│   │   ├── domain/                # Pure app-level business logic (no Flutter or platform dependencies).
│   │   │   ├── entities/          # Core app entities (e.g., User, Session, AppConfig).
│   │   │   ├── repositories/      # Abstract interfaces for app repositories (e.g., abstract AuthRepository).
│   │   │   └── usecases/          # Single-purpose app use cases (e.g., LoginUseCase, GetAppConfig).
│   │   │
│   │   └── services/              # App-level orchestration services (multi-step workflows).
│   │                              # Example: AuthService (login + analytics + session setup).
│   │
│   ├── constants/                 # 📏 App-wide constants (routes, API paths, keys, enums).
│   │   ├── app_routes.dart        # Named routes (e.g., '/login', '/portfolio').
│   │   └── api_endpoints.dart     # Backend API paths (e.g., '/api/v1/auth/login').
│   │
│   ├── errors/                    # ❌ Failure types and error handling utilities.
│   │   ├── failures.dart          # Domain failures (NetworkFailure, AuthFailure).
│   │   └── exception_mapper.dart  # Maps Dio/HTTP errors to domain failures.
│   │
│   ├── network/                   # 🌐 Global API layer (shared by all features).
│   │   ├── api_client.dart        # Retrofit-style API client (uses dio + retrofit.dart).
│   │   └── dtos/                  # Backend-matching Data Transfer Objects (DTOs).
│   │       ├── auth_dtos.dart     # LoginRequest, TokenResponse.
│   │       ├── user_dtos.dart     # UserResponse from API.
│   │       ├── portfolio_dtos.dart
│   │       ├── trade_dtos.dart
│   │       └── document_dtos.dart
│   │
│   └── utils/                     # 🛠️ Pure, stateless helper functions (no side effects).
│       ├── date_utils.dart        # Date formatting, parsing.
│       ├── string_utils.dart      # Validation, sanitization.
│       └── filter_sort_utils.dart # Reusable filtering/sorting logic (stateless).
│
├── shared/                        # ♻️ Reusable components shared across features AND platforms (web, Android, iOS).
│   │                              # Contains ONLY UI/widgets and cross-feature models.
│   │
│   ├── models/                    # UI-safe copies of domain models (optional; avoid if using core/app_logic/entities directly).
│   │   └── user.dart              # Example: simplified User for UI display.
│   │
│   └── widgets/                   # ✨ Shared UI components used in multiple features.
│       ├── inputs/                # Form controls (AppTextField, AppDropdown).
│       ├── buttons/               # Action buttons (PrimaryButton, IconButton).
│       ├── data_table/            # Smart, responsive, sortable table.
│       └── animations/            # Motion design (FadeIn, SkeletonLoader).
│
├── platform/                      # 📱 Platform-specific implementations (Android/iOS only).
│   │                              # NEVER used directly by features — injected via DI.
│   │
│   ├── android/                   # 🤖 Android-only service implementations.
│   │   ├── android_biometric_auth.dart
│   │   ├── android_file_picker.dart
│   │   └── android_deep_link_handler.dart
│   │
│   └── ios/                       # 🍏 iOS-only service implementations.
│       ├── ios_biometric_auth.dart
│       ├── ios_file_picker.dart
│       └── ios_universal_link_handler.dart
│
├── features/                      # 📦 Feature modules — each is a self-contained vertical slice.
│   │                              # Features do NOT depend on each other.
│   │
│   ├── auth/                      # 🔑 Authentication feature (login, signup, forgot password).
│   │   │                          # Note: Currently transitioning to clean architecture structure.
│   │   ├── auth_wrapper.dart      # Authentication state wrapper component.
│   │   ├── login_screen.dart      # Legacy login screen (to be moved to presentation/).
│   │   │
│   │   └── presentation/          # 🎨 UI layer for auth (web + mobile).
│   │       ├── screens/           # Auth screen implementations.
│   │       │   ├── login_screen.dart      # Login screen implementation.
│   │       │   └── register_screen.dart   # Registration screen implementation.
│   │       │
│   │       └── widgets/           # Auth-specific UI components.
│   │           ├── app_logo.dart          # Application logo widget.
│   │           ├── animated_login_elements.dart  # Login animations.
│   │           ├── login_background.dart  # Login background styling.
│   │           └── modern_login_form.dart # Modern login form component.
│   │
│   ├── portfolio/                 # 📊 Portfolio holdings and performance.
│   │   │                          # Example of complete clean architecture implementation.
│   │   ├── internal/              # 🧠 ALL feature-specific logic (data, domain, services).
│   │   │   ├── data/              # Portfolio data sources and repository implementations.
│   │   │   │   ├── datasources/   # Remote and local data sources.
│   │   │   │   ├── dtos/          # Data transfer objects for API communication.
│   │   │   │   ├── mappers/       # Data transformation between layers.
│   │   │   │   └── repositories/  # Repository implementations.
│   │   │   │
│   │   │   ├── domain/            # Portfolio entities, use cases, abstract repositories.
│   │   │   │   ├── entities/      # Domain entities (PortfolioHolding, PortfolioSummary).
│   │   │   │   ├── repositories/  # Abstract repository interfaces.
│   │   │   │   └── usecases/      # Business use cases (GetPortfolioHoldings, etc.).
│   │   │   │
│   │   │   └── services/          # Portfolio complex workflows (e.g., sync + analytics).
│   │   │
│   │   ├── presentation/          # 🎨 UI layer for portfolio (web + mobile).
│   │   │   ├── cubit/             # PortfolioCubit (state management for portfolio screens).
│   │   │   │   ├── portfolio_cubit.dart  # State management logic.
│   │   │   │   └── portfolio_state.dart  # State definitions.
│   │   │   │
│   │   │   ├── common/            # Widgets reused across web/mobile for portfolio.
│   │   │   ├── mobile/            # Default mobile UI (used by both Android & iOS).
│   │   │   ├── pages/             # Portfolio page implementations.
│   │   │   │   └── portfolio_screen.dart  # Main portfolio screen.
│   │   │   │
│   │   │   ├── web/               # Web-specific portfolio UI.
│   │   │   │   ├── portfolio_holdings_widget.dart  # Holdings display widget.
│   │   │   │   └── portfolio_web_screen.dart       # Web portfolio screen.
│   │   │   │
│   │   │   └── widgets/           # Portfolio-specific UI components.
│   │   │       └── portfolio_sidebar.dart  # Portfolio navigation sidebar.
│   │   │
│   │   ├── data/                  # Legacy data layer (to be moved to internal/).
│   │   ├── domain/                # Legacy domain layer (to be moved to internal/).
│   │   ├── portfolio_screen.dart  # Legacy screen file (to be removed).
│   │   └── README.md              # Portfolio feature documentation.
│   │
│   └── web_app_entry.dart         # Web application entry point and routing.
│
├── di/                            # ⚙️ Dependency Injection setup (get_it + injectable).
│   ├── injection.dart             # Main DI configuration (registers all dependencies).
│   └── injection.config.dart      # Generated DI file (do not edit).
│
├── config/                        # ⚙️ App configuration (reads from environment or properties).
│   └── app_config.dart            # Base URL, mock mode, feature flags, etc.
│
├── assets/                        # 🖼️ Static resources (images, fonts, JSON).
│   └── mock/                      # 🧪 Fallback JSON files for offline/mock mode.
│       ├── auth.json
│       ├── home.json
│       ├── portfolio.json
│       ├── trade.json
│       └── document.json
│
├── main.dart                      # 🚀 SINGLE entry point for Android, iOS, and Web.
│                                  # Flutter handles platform detection automatically.
│
└── app.dart                       # 🏗️ Root app widget (sets up DI, router, theme).
                                   # Uses adaptive navigation if needed (e.g., sidebar on web).
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