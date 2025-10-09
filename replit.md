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
- **2025-10-09**: Web-Optimized Authentication & Developer Experience
  - Created modern split-screen login design for web (branding left, form right)
  - Added Google OAuth "Continue with Google" button (placeholder for integration)
  - Implemented collapsible Developer Controls Panel with feature flag toggles
  - Enhanced login UI with gradient backgrounds, decorative elements, and professional typography
  - Fixed architecture conflicts between old and new auth systems
  - Streamlined DI to use Riverpod providers exclusively
  - Post-login navigation routes to portfolio screen via AuthWrapper
  - Mobile-responsive design with adaptive layouts

- **2025-10-08**: Enhanced Charts & Analytics UI/UX
  - Created AnimatedSectorDonutChart with smooth animations and scrollable legend supporting 20+ fields
  - Created AnimatedMarketCapChart with similar animations and interactivity
  - Added Sector/Market Cap toggle in Portfolio Overview with segmented button
  - Fixed Analytics section to display real data instead of placeholders
  - Analytics now shows live sector allocation, market cap distribution, top holdings, and risk metrics
  - Charts feature hover effects, touch interactions, and automatic color coding
  - Improved visual presentation with badges, shadows, and responsive layouts

- **2025-10-08**: Mock Data Fallback System Implementation
  - Created PortfolioMockDataHelper to load mock JSON files when API is unavailable
  - Added graceful fallback logic to all PortfolioRemoteDataSource methods
  - Mock data files: portfolio_holdings.json, portfolio_summary.json, portfolio_analytics.json
  - App now works seamlessly without backend API connection in development mode
  - Fallback only activates in development environment for safety
  - Successfully tested with mock data loading confirmed in workflow logs

- **2025-10-08**: Portfolio Overview Dashboard Implementation
  - Built comprehensive Portfolio Overview dashboard with summary cards, top movers, and allocation charts
  - Created data contracts and models (OverviewSummaryData, AllocationItem, OverviewMoversData)
  - Implemented chart components using fl_chart library (sector pie/donut/bar charts, market cap allocation)
  - Built PortfolioOverviewWidget with responsive layout adapters for desktop/tablet/mobile
  - Created PortfolioOverviewDataAdapter to transform domain entities into display models
  - Fixed property name mismatches in adapter (todayChange, totalGainLoss, companyName, todayChangePercentage)
  - Integrated Overview into portfolio web screen with sidebar navigation
  - Added fl_chart dependency (^0.68.0) to pubspec.yaml
  - Successfully built and deployed with zero LSP errors

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
│   │   └── internal/
│   │       └── data/
│   │           └── datasources/
│   │               ├── portfolio_remote_data_source.dart   # API client with fallback
│   │               └── portfolio_mock_data_helper.dart     # Mock data loader (NEW)
│   └── watchlist/     # Watchlist features
├── shared/            # Shared widgets and components
│   └── widgets/
│       ├── heatmap/            # Heatmap template architecture
│       ├── holdings/           # Holdings template architecture
│       │   ├── core/           # State management (HoldingsSelectorCore)
│       │   ├── configs/        # Display configurations
│       │   ├── layouts/        # Layout builders (Table, Card)
│       │   ├── universal_holdings/ # Factory and universal widget
│       │   └── HOLDINGS_TEMPLATE_USAGE.md
│       └── portfolio_overview/ # Portfolio Overview dashboard
│           ├── contracts/      # Data contracts and models
│           ├── adapters/       # Data transformation adapters
│           ├── charts/         # Chart components (sector, market cap)
│           └── portfolio_overview_widget.dart
├── assets/            # Static assets
│   ├── mock_data/     # Mock JSON data for development (NEW)
│   │   ├── portfolio_holdings.json
│   │   ├── portfolio_summary.json
│   │   └── portfolio_analytics.json
│   └── test_users.json
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

### Web-Optimized Login Experience
The app features a modern, web-optimized authentication system with:

**Split-Screen Design (Web)**:
- Left panel: Purple gradient branding with "AM Investment" logo, tagline, and feature highlights
- Right panel: Clean, focused login form with professional styling
- Mobile-responsive with adaptive layouts

**Authentication Methods**:
- Email/password authentication with validation
- Demo login for quick testing (credentials: ssd2658/password)
- Google OAuth button (placeholder for future integration)

**Developer Tools**:
- Collapsible Developer Controls panel (web only)
- Feature flags: Real/Mock Google Auth, Real/Mock Backend API, Mock Delays, Debug Logging
- Quick settings reset functionality

**Technical Architecture**:
- Riverpod-based state management (authStateNotifierProvider)
- AuthWrapper handles authentication state and navigation
- Persistent session using SharedPreferences
- Automatic navigation to portfolio screen after successful login
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

### Portfolio Overview System
Located in `lib/shared/widgets/portfolio_overview/`, the overview dashboard provides a high-level portfolio summary:

1. **Data Contracts** (`OverviewSummaryData`, `AllocationItem`, `OverviewMoversData`)
   - Well-defined interfaces for overview data
   - Type-safe data models for charts and displays
   - Clear separation between domain and display layers

2. **Data Adapters** (`PortfolioOverviewDataAdapter`)
   - Transforms domain entities (PortfolioSummary, PortfolioAnalytics, PortfolioHoldings) into display models
   - Handles property mapping and data aggregation
   - Extracts top movers, sector allocations, and market cap breakdowns

3. **Chart Components**
   - Sector allocation charts (pie, donut, bar views)
   - Market cap allocation visualizations
   - Built with fl_chart library for rich interactivity

4. **Responsive Layout**
   - Desktop layout: Multi-column grid with side-by-side charts
   - Tablet layout: 2-column grid with stacked sections
   - Mobile layout: Single column with simplified views

### Usage Example
```dart
PortfolioOverviewWidget(
  summaryData: OverviewSummaryData(...),
  sectorAllocation: [...],
  marketCapAllocation: [...],
  topGainers: [...],
  topLosers: [...],
  onNavigateToHoldings: () => navigateToHoldings(),
)
```

## Mock Data Fallback System

The app includes a sophisticated fallback mechanism for API unavailability:

### How It Works
1. **Primary**: App attempts to fetch data from backend API (localhost:8072)
2. **Fallback**: If API call fails, app automatically loads mock data from JSON files
3. **Environment-Aware**: Fallback only activates in development mode for safety

### Mock Data Files
Located in `lib/assets/mock_data/`:
- `portfolio_holdings.json` - Sample holdings data
- `portfolio_summary.json` - Portfolio summary with performance metrics
- `portfolio_analytics.json` - Analytics data with sector/market cap allocations

### Implementation
**PortfolioMockDataHelper** (`lib/features/portfolio/internal/data/datasources/portfolio_mock_data_helper.dart`):
- Loads mock JSON files using Flutter's `rootBundle.loadString()`
- Parses JSON and transforms into DTOs using existing mappers
- Provides static methods for each data type

**PortfolioRemoteDataSource** - Updated with try-catch fallback:
```dart
try {
  // Attempt API call
  return await _apiClient.get(...);
} catch (e) {
  // Fallback to mock data
  return await PortfolioMockDataHelper.getMockPortfolioSummary();
}
```

### Benefits
- **Zero Backend Dependency**: App works without running backend server
- **Seamless Development**: Developers can work on frontend independently
- **Graceful Degradation**: Users see realistic data instead of errors
- **Easy Testing**: Mock data provides consistent test scenarios

## Notes
- The app is designed to work with a backend API (not included in this project)
- **NEW**: Graceful fallback to mock data when API is unavailable (development mode only)
- Supports both mobile and web layouts with responsive design
- Template architecture maximizes code reuse between platforms
