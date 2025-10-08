# AM Investment Portfolio Management App

## Overview
A comprehensive Flutter web application for investment portfolio management with features including:
- User authentication (login/register)
- Portfolio analytics and tracking
- Investment heatmap visualizations
- Market cap and sector allocation analysis
- Holdings management

## Project Setup

### Technology Stack
- **Framework**: Flutter 3.32.0
- **Language**: Dart 3.8.0
- **State Management**: Riverpod
- **Architecture**: Clean Architecture with domain/data layers
- **Code Generation**: Freezed, JSON Serializable, Build Runner

### Development Environment
- **Web Server**: dhttpd (Dart HTTP server)
- **Port**: 5000
- **Environment**: Development (configurable via properties files)

## Recent Changes
- **2025-10-08**: Holdings Template Architecture Implementation
  - Created sophisticated template-based architecture for portfolio holdings display
  - Implemented factory pattern with HoldingsTemplateFactory and UniversalHoldingsWidget
  - Built HoldingsSelectorCore for state management (sorting, filtering, view modes)
  - Created layout builders (TableLayoutBuilder, CardLayoutBuilder) following strategy pattern
  - Added HoldingsDisplayConfig with web/mobile/minimal presets
  - Comprehensive documentation in lib/shared/widgets/holdings/HOLDINGS_TEMPLATE_USAGE.md
  - Architecture reviewed and approved by architect with zero LSP errors
  
- **2025-10-07**: Initial project import and setup
  - Installed Flutter 3.32.0 and Dart 3.8.0
  - Fixed SDK version compatibility (changed from ^3.8.1 to ^3.8.0)
  - Generated freezed/JSON serialization files using build_runner
  - Built production web bundle
  - Configured workflow to serve app on port 5000 using dhttpd
  - Set up deployment configuration for autoscale

## Project Structure
```
lib/
├── core/              # Core business logic and utilities
│   ├── app_logic/     # Authentication, domain entities, DTOs
│   ├── constants/     # App constants and routes
│   ├── network/       # API client and error handling
│   └── utils/         # Utility functions
├── features/          # Feature modules
│   ├── login/         # Authentication UI
│   ├── portfolio/     # Portfolio management
│   └── watchlist/     # Watchlist features
├── shared/            # Shared widgets and components
│   └── widgets/
│       ├── heatmap/   # Heatmap template architecture
│       └── holdings/  # Holdings template architecture (NEW)
│           ├── core/            # State management (HoldingsSelectorCore)
│           ├── configs/         # Display configurations
│           ├── layouts/         # Layout builders (Table, Card)
│           ├── universal_holdings/ # Factory and universal widget
│           ├── holdings_display_template.dart
│           └── HOLDINGS_TEMPLATE_USAGE.md
├── config/            # Configuration files
├── di/                # Dependency injection
├── app.dart          # Root app widget
└── main.dart         # App entry point
```

## Running the Application

### Development
The app runs automatically via the configured workflow:
```bash
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter build web --release
export PATH="$PATH:$HOME/.pub-cache/bin"
dhttpd --host=0.0.0.0 --port=5000 --path=build/web
```

### Code Generation
When modifying DTOs or entities with Freezed annotations:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Building for Production
```bash
flutter build web --release
```

## Configuration
The app uses environment-specific configuration files:
- `lib/assets/application.properties` - Base configuration
- `lib/assets/application-dev.properties` - Development settings
- `lib/assets/application-prod.properties` - Production settings

Current environment: **Development**
API URL: `http://localhost:8072`

## Authentication
The app includes a login system with:
- Email/password authentication
- Demo login option
- Persistent session using SharedPreferences
- Test users available in `lib/assets/test_users.json`

## Deployment
Configured for Replit autoscale deployment:
- Build command generates optimized web bundle
- Serves static files via dhttpd on port 5000
- No backend server included (expects API at localhost:8072)

## Template Architecture Pattern

The app uses a sophisticated template-based architecture for reusable components:

### Holdings Template System
Located in `lib/shared/widgets/holdings/`, the holdings display system follows a factory-based pattern with:

1. **Core State Management** (`HoldingsSelectorCore`)
   - Centralized state for sorting, filtering, and display preferences
   - Observable pattern with callback notifications
   - Independent of UI implementation

2. **Display Configuration** (`HoldingsDisplayConfig`)
   - Preset configurations: web, mobile, minimal
   - Controls feature visibility and defaults
   - Highly customizable

3. **Layout Builders** (Strategy Pattern)
   - `TableLayoutBuilder` - Web-optimized table view
   - `CardLayoutBuilder` - Mobile-optimized card view
   - Extensible for new layout types

4. **Template Factory** (`HoldingsTemplateFactory`)
   - Creates display, selector, and layout components
   - Supports minimal, compact, full, and adaptive templates
   - Coordinates component assembly

5. **Universal Widget** (`UniversalHoldingsWidget`)
   - All-in-one component with Riverpod integration
   - Automatic data fetching via portfolioHoldingsProvider
   - Adaptive template selection

### Usage Example
```dart
UniversalHoldingsWidget(
  userId: userId,
  portfolioId: portfolioId,
  config: HoldingsDisplayConfig.web(),
  templateType: HoldingsTemplateType.adaptive,
  onHoldingTap: (holding) => navigateToDetails(holding),
)
```

See `lib/shared/widgets/holdings/HOLDINGS_TEMPLATE_USAGE.md` for comprehensive documentation.

## Notes
- The app is designed to work with a backend API (not included in this project)
- Mock data providers available for development/testing
- Supports both mobile and web layouts with responsive design
- Template architecture maximizes code reuse between platforms
