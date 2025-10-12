# AM Investment Portfolio Management App

## Overview
A comprehensive Flutter web application for investment portfolio management. The application provides features such as user authentication, portfolio analytics and tracking, investment heatmap visualizations, market cap and sector allocation analysis, and holdings management. The business vision is to provide a robust, user-friendly platform for individual investors to manage and analyze their portfolios with advanced tools and clear visualizations. The project aims to capture a segment of the retail investment market by offering a superior, data-rich experience.

## User Preferences
The user prefers iterative development and expects the agent to ask before making major changes. The user prefers detailed explanations of changes and decisions.

## System Architecture
The application is built using Flutter 3.32.0 and Dart 3.8.0, adhering to Clean Architecture principles with distinct domain and data layers. Riverpod is used for state management, complemented by Freezed, JSON Serializable, and Build Runner for code generation.

### UI/UX Decisions
- **Login/Authentication**: Features a modern split-screen design for web, with a branded left panel and a clean login form on the right. It includes gradient backgrounds, decorative elements, and professional typography. The design is mobile-responsive with adaptive layouts.
- **Charts & Analytics**: Employs `fl_chart` for interactive and animated visualizations such including `AnimatedSectorDonutChart` and `AnimatedMarketCapChart`. Charts support hover effects, touch interactions, and automatic color coding. Visuals are enhanced with badges, shadows, and responsive layouts.
- **Portfolio Overview Dashboard**: A comprehensive dashboard featuring summary cards, top movers, and allocation charts, designed with responsive layout adapters for desktop, tablet, and mobile.

### Technical Implementations
- **Authentication**: Unified Clean Architecture implementation with BLoC/Cubit state management in `lib/features/authentication/`. This consolidated module contains all authentication-related functionality. Supports email/password, demo login, and Google OAuth Sign-In. Architecture includes:
  - **Domain Layer**: Entities (UserEntity, AuthResultEntity, AuthTokensEntity), repository interfaces, and use cases (EmailLoginUseCase, GoogleLoginUseCase, DemoLoginUseCase, LogoutUseCase, CheckAuthStatusUseCase, GetCurrentUserUseCase)
  - **Data Layer**: DTOs, data sources (MockAuthDataSource for development, AuthRemoteDataSource for production), and repository implementations with automatic fallback to mock data
  - **Presentation Layer**: 
    - **State Management**: AuthCubit and FeatureFlagCubit for managing authentication state and feature toggles
    - **Pages**: AuthWrapper (main entry), LoginScreen (with responsive web/mobile layouts), RegisterPage, ForgotPasswordPage, ResetPasswordPage
    - **Widgets**: GoogleSignInButton, DeveloperControlsPanel, EmailLoginForm, and other reusable UI components
    - **Responsive Design**: Modern split-screen layout for web, card-based layout for mobile
  - **Security**: Sessions are persistent using FlutterSecureStorage with encrypted shared preferences on Android. GetCurrentUserUseCase restores authenticated sessions on app restart
  - **Feature Flags**: Toggle between mock and real API backends via FeatureFlags
  - **DI**: Dependency injection configured in `lib/di/auth_providers.dart` using singleton pattern with BLoC providers
  - **Navigation**: `AuthWrapper` manages authentication state and routing using BlocBuilder, serving as the main app entry point
  - Google Sign-In configuration is managed through the `ConfigService` with `GoogleConfig` class, which loads the Web Client ID from environment-specific properties files
- **Holdings Management**: Utilizes a sophisticated template-based architecture for displaying holdings. This includes a `HoldingsSelectorCore` for state management (sorting, filtering, view modes), `HoldingsDisplayConfig` for display presets (web, mobile, minimal), and layout builders (`TableLayoutBuilder`, `CardLayoutBuilder`) following a strategy pattern. A `HoldingsTemplateFactory` creates display components, coordinated by a `UniversalHoldingsWidget` for adaptive template selection and Riverpod integration.
- **Data Handling**: Implements a mock data fallback system where `PortfolioMockDataHelper` loads JSON mock files from `lib/assets/mock_data/` if API calls fail. This system is active only in the development environment, ensuring seamless frontend development without a live backend connection.
- **Trade System Architecture**: Pure Clean Architecture implementation with Riverpod state management and corrected Trade API endpoints:
  - **API Endpoints (Corrected per Trade API Spec)**:
    - **Portfolio Discovery**: `GET /api/v1/portfolio-summary/by-owner/{ownerId}` - Returns array of portfolios for authenticated user
    - **Holdings Analysis**: `GET /api/v1/trades/portfolio-details/{portfolioId}?page=0&size=50&sort=tradeDate,desc` - Paginated trade holdings with comprehensive metrics
    - **Portfolio Summary**: `GET /api/v1/portfolio-summary/{portfolioId}` - Detailed portfolio metrics, win/loss rates, trade statistics
    - **Calendar Analytics**: `GET /api/v1/trades/calendar/month?portfolioId={id}&year={year}&month={month}` - Time-based trade data for visualization
  - **Rich Data Capabilities**:
    - **Portfolio Metrics**: Initial/current capital, net P&L, win rate, loss rate, profit factor, expectancy, drawdown, Sharpe ratio, Sortino ratio
    - **Trade Details**: Symbol, ISIN, exchange, segment, entry/exit timestamps, prices, quantities, fees, P&L metrics, risk-reward ratios
    - **Performance Analytics**: Monthly/weekly returns, winning/losing/break-even trades, trade execution history
    - **Calendar Features**: Day/month/quarter/financial-year views, trade event aggregation, time-based filtering
  - **Internal Layer (lib/features/trade/internal/)**:
    - **Domain Layer**: Freezed entities (TradePortfolio, TradeHolding, TradeSummary, TradeCalendar, TradeCalendarEvent), repository interfaces with stream support, and validated use cases (GetTradePortfolios, GetTradeHoldings, GetTradeSummary, GetTradeCalendar)
    - **Data Layer**: DTOs matching Trade API response structures (portfolioId field, optional metrics), remote data sources with corrected endpoints, mappers for DTO-to-entity conversion, and repository implementations with broadcast stream controllers and caching
    - **Mock Data Fallback**: Automatic fallback to mock JSON files in `lib/assets/mock_data/trade/` when API endpoints fail (dev environment only)
  - **Presentation Layer (Fully Riverpod-Based)**:
    - **Stream Providers**: Complete Riverpod stream provider implementation (`tradePortfoliosStreamProvider`, `tradeHoldingsStreamProvider`, `tradeSummaryStreamProvider`, `tradeCalendarStreamProvider`) using family providers with record parameters
    - **Template Components**: Reusable presentation templates (TradePortfolioDiscoveryTemplate, TradeHoldingsTemplate, TradeSummaryTemplate, CalendarAnalyticsTemplate) consuming domain entities with shared callbacks for web/mobile
    - **Web Implementation**: ConsumerWidget-based pages with stream watching, sidebar navigation, and Map<String, String> routing arguments (userId, portfolioId)
    - **Mobile Implementation**: ConsumerWidget/ConsumerStatefulWidget pages with pull-to-refresh, client-side filtering (calendar by month), card-based layouts, and userId forwarding in navigation
  - **Clean Codebase**: All legacy code removed - no BLoC/Cubit dependencies, DTO models, or redundant services. Pure Riverpod with stream providers and domain entities throughout
  - **Sequential API Flow**: Portfolio discovery → Holdings analysis → Summary/analytics → Calendar events
  - **Generated Code**: Freezed entities with @Default annotations and JSON serialization for type-safe data handling
- **Configuration**: Uses environment-specific property files (`application.properties`, `application-dev.properties`, `application-prod.properties`) for managing settings. The `ConfigService` and `AppConfig` classes provide type-safe access to configuration values, including API endpoints (e.g., `api.baseUrl=https://api.munish.org/api/v1` for development), environment settings, and third-party service credentials (like Google Web Client ID).

### Feature Specifications
- **User Authentication**: Login, registration (UI only), forgot password (UI only), Google OAuth.
  - **Registration Screen**: Full signup form with validation (awaits backend integration)
  - **Forgot Password**: Email input screen with reset instructions (awaits backend integration)
  - **Reset Password**: Token-based password reset form (awaits backend integration)
  - **Navigation**: "Forgot Password?" and "Create Account" links on login screen
- **Portfolio Analytics**: Sector allocation, market cap distribution, top holdings, and risk metrics.
- **Heatmap Visualizations**: Placeholder, planned for future iterations.
- **Holdings Management**: Comprehensive display with sorting, filtering, and configurable views (table, card).
- **Trade System Integration**: Complete trade management system with portfolio discovery, holdings analysis, and calendar views. Features automatic API fallback to mock data, template-based components for reusability, and sequential API flow following trade specifications.
  - **Web Access**: "Trade Analysis" link in portfolio sidebar
  - **Mobile Access**: "Trade" tab in mobile portfolio bottom navigation (5th tab)
- **Developer Controls**: A collapsible panel with feature flags for toggling mock data, authentication methods, and debug logging.

## External Dependencies
- **Flutter Framework**: For cross-platform development.
- **Dart Language**: Primary programming language.
- **Riverpod**: State management library.
- **Freezed, JSON Serializable, Build Runner**: Code generation tools.
- **dhttpd**: Dart HTTP server for serving the web application.
- **fl_chart**: Library for charting and data visualization.
- **Google Sign-In SDK**: For Google OAuth authentication.
- **Google Identity Services (GIS)**: Used for web-based Google Sign-In.
- **SharedPreferences**: For persistent session storage.

## Deployment
The application uses **Static Deployment** with pre-built files (Cloud Run environments don't support Flutter SDK).

### Important: Build Locally First
Since Replit's deployment environments don't have Flutter SDK, you must build the app in the development environment before deploying:
```bash
flutter build web --release
```
This creates production-ready static files in `build/web/` directory.

### How to Deploy (Static Deployment - Recommended)

**Step 1: Build the App (Already Done)**
The app is already built and ready to deploy. The static files are in `build/web/`.

**Step 2: Configure Static Deployment**
1. Click **"Deploy"** button at the top of your Replit workspace
2. Select **"Static Deployment"**
3. Configure settings:
   - **Build command**: Leave empty (files are pre-built)
   - **Output directory**: `build/web`
4. Click **"Deploy"**

**Benefits:**
- ✅ Global CDN distribution (faster loading worldwide)
- ✅ Cost-effective (only pay for data transfer)
- ✅ Automatic caching and scaling
- ✅ Perfect for Flutter web apps

**Note:** If you make code changes, rebuild with `flutter build web --release` before redeploying.

### Demo Credentials
- **Demo Login**: demo@example.com / password123
- **Test User**: ssd2658 / password
- **Google Sign-In**: Available on mobile/native platforms (web requires additional setup)

### Authentication Navigation
The login screen now includes:
- **"Forgot Password?"** link - navigates to password reset request screen
- **"Create Account"** link - navigates to user registration screen
- Routes configured: `/register`, `/forgot-password`, `/reset-password`

**Note**: Registration and password reset UIs are complete but show "not implemented" messages until backend integration is complete. See `AUTHENTICATION_IMPLEMENTATION_STATUS.md` for details.