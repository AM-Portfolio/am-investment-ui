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
- **Authentication**: Supports email/password, demo login, and Google OAuth Sign-In (using Google Sign-In SDK v7.1.0 and Google Identity Services). Authentication state and navigation are managed via Riverpod and an `AuthWrapper`. Sessions are persistent using SharedPreferences. Google Sign-In configuration is managed through the `ConfigService` with `GoogleConfig` class, which loads the Web Client ID from environment-specific properties files. The login screen validates configuration and provides user-friendly error messages with setup guidance when Client ID is missing.
- **Holdings Management**: Utilizes a sophisticated template-based architecture for displaying holdings. This includes a `HoldingsSelectorCore` for state management (sorting, filtering, view modes), `HoldingsDisplayConfig` for display presets (web, mobile, minimal), and layout builders (`TableLayoutBuilder`, `CardLayoutBuilder`) following a strategy pattern. A `HoldingsTemplateFactory` creates display components, coordinated by a `UniversalHoldingsWidget` for adaptive template selection and Riverpod integration.
- **Data Handling**: Implements a mock data fallback system where `PortfolioMockDataHelper` loads JSON mock files from `lib/assets/mock_data/` if API calls fail. This system is active only in the development environment, ensuring seamless frontend development without a live backend connection.
- **Trade System Architecture**: Follows the proven template design pattern with:
  - **Unified Cubit Approach**: `UnifiedTradeCubit` manages all trade operations with automatic fallback from API to mock data when endpoints fail
  - **Template Components**: Reusable `TradePortfolioDiscoveryTemplate`, `TradeHoldingsTemplate`, and `CalendarAnalyticsTemplate` for consistent UI across web and mobile
  - **Sequential API Flow**: Portfolio discovery → Portfolio analysis → Trade details → Calendar analytics, following the trade API specification
  - **Mock Data Integration**: Complete mock data set in `lib/assets/mock_data/trade/` for development and testing
  - **Navigation**: Three web pages (portfolio list, holdings dashboard, calendar analytics) with dynamic routing and Riverpod provider integration
- **Configuration**: Uses environment-specific property files (`application.properties`, `application-dev.properties`, `application-prod.properties`) for managing settings. The `ConfigService` and `AppConfig` classes provide type-safe access to configuration values, including API endpoints, environment settings, and third-party service credentials (like Google Web Client ID).

### Feature Specifications
- **User Authentication**: Login, registration (UI only), forgot password (UI only), Google OAuth.
  - **Registration Screen**: Full signup form with validation (awaits backend integration)
  - **Forgot Password**: Email input screen with reset instructions (awaits backend integration)
  - **Reset Password**: Token-based password reset form (awaits backend integration)
  - **Navigation**: "Forgot Password?" and "Create Account" links on login screen
- **Portfolio Analytics**: Sector allocation, market cap distribution, top holdings, and risk metrics.
- **Heatmap Visualizations**: Placeholder, planned for future iterations.
- **Holdings Management**: Comprehensive display with sorting, filtering, and configurable views (table, card).
- **Trade System Integration**: Complete trade management system with portfolio discovery, holdings analysis, and calendar views. Features automatic API fallback to mock data, template-based components for reusability, and sequential API flow following trade specifications. Accessible via "Trade Analysis" link in portfolio sidebar.
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