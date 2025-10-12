# AM Investment Portfolio Management App

## Overview
A comprehensive Flutter web application for investment portfolio management. The application provides features such as user authentication, portfolio analytics and tracking, investment heatmap visualizations, market cap and sector allocation analysis, and holdings management. The business vision is to provide a robust, user-friendly platform for individual investors to manage and analyze their portfolios with advanced tools and clear visualizations, aiming to capture a segment of the retail investment market.

## User Preferences
The user prefers iterative development and expects the agent to ask before making major changes. The user prefers detailed explanations of changes and decisions.

## System Architecture
The application is built using Flutter 3.32.0 and Dart 3.8.0, adhering to Clean Architecture principles with distinct domain and data layers. Riverpod is used for state management, complemented by Freezed, JSON Serializable, and Build Runner for code generation.

### UI/UX Decisions
- **Login/Authentication**: Modern split-screen design for web, with a branded left panel and a clean login form. Mobile-responsive with adaptive layouts, gradient backgrounds, and professional typography.
- **Charts & Analytics**: Employs `fl_chart` for interactive and animated visualizations including sector and market cap charts. Supports hover effects, touch interactions, automatic color coding, badges, shadows, and responsive layouts.
- **Portfolio Overview Dashboard**: Comprehensive dashboard with summary cards, top movers, and allocation charts, designed with responsive layout adapters for all screen sizes.

### Technical Implementations
- **Authentication**: Unified Clean Architecture implementation with BLoC/Cubit state management. Supports email/password, demo login, and Google OAuth. Features persistent sessions using FlutterSecureStorage, feature flags for mock/real API toggling, and `AuthWrapper` for navigation and state management. Google Sign-In is configured via `ConfigService`.
- **Holdings Management**: Utilizes a template-based architecture with `HoldingsSelectorCore` for state management, `HoldingsDisplayConfig` for presets, and layout builders (`TableLayoutBuilder`, `CardLayoutBuilder`) following a strategy pattern. `UniversalHoldingsWidget` and `HoldingsTemplateFactory` coordinate display components.
- **Data Handling**: Implements a mock data fallback system using `PortfolioMockDataHelper` that loads JSON mock files from `lib/assets/mock_data/` for development environments if API calls fail.
- **Trade System Architecture**: Comprehensive Clean Architecture implementation supporting portfolio discovery, holdings analysis, portfolio summary, and calendar analytics.
  - **API Endpoints**: `GET /api/v1/portfolio-summary/by-owner/{ownerId}`, `GET /api/v1/trades/portfolio-details/{portfolioId}`, `GET /api/v1/portfolio-summary/{portfolioId}`, `GET /api/v1/trades/calendar/month`.
  - **Rich Data Capabilities**: Includes detailed portfolio metrics (P&L, win/loss rates, Sharpe ratio, sector allocations), trade details (instrument info, entry/exit, execution history), and performance analytics.
  - **Internal Layer**: Pure Clean Architecture with comprehensive nested DTOs (using Freezed and `@JsonSerializable`), rich nested entities (using Freezed), a layered mapper system for DTO-to-entity transformation, and repository/data sources with mock data fallback. Includes validated domain use cases with stream support.
  - **Presentation Layer**: Utilizes View Models (`TradeHoldingViewModel`, `TradeCalendarViewModel`, etc.) to flatten domain entities into presentation-friendly structures. Riverpod stream providers map entities to view models. Template components consume only view models, ensuring UI decoupling. Supports adaptive web and mobile implementations.
  - **Architecture Benefits**: Ensures clean layer separation, testability, maintainability, and type-safety through Freezed code generation.
  - **Sequential API Flow**: Portfolio discovery → Holdings analysis → Summary/analytics → Calendar events.
- **Configuration**: Uses environment-specific property files (`application.properties`, `application-dev.properties`, `application-prod.properties`) managed by `ConfigService` and `AppConfig` for type-safe access to API endpoints and credentials.

### Feature Specifications
- **User Authentication**: Login, registration (UI only), forgot password (UI only), Google OAuth.
- **Portfolio Analytics**: Sector allocation, market cap distribution, top holdings, and risk metrics.
- **Heatmap Visualizations**: Planned for future iterations.
- **Holdings Management**: Comprehensive display with sorting, filtering, and configurable views.
- **Trade System Integration**: Complete trade management with portfolio discovery, holdings analysis, and calendar views, including automatic API fallback and template-based components.
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
- **FlutterSecureStorage**: For persistent session storage.