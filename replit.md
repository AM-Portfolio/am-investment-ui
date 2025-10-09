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
- **Authentication**: Supports email/password, demo login, and Google OAuth Sign-In (using Google Sign-In SDK v7.1.0 and Google Identity Services). Authentication state and navigation are managed via Riverpod and an `AuthWrapper`. Sessions are persistent using SharedPreferences.
- **Holdings Management**: Utilizes a sophisticated template-based architecture for displaying holdings. This includes a `HoldingsSelectorCore` for state management (sorting, filtering, view modes), `HoldingsDisplayConfig` for display presets (web, mobile, minimal), and layout builders (`TableLayoutBuilder`, `CardLayoutBuilder`) following a strategy pattern. A `HoldingsTemplateFactory` creates display components, coordinated by a `UniversalHoldingsWidget` for adaptive template selection and Riverpod integration.
- **Data Handling**: Implements a mock data fallback system where `PortfolioMockDataHelper` loads JSON mock files from `lib/assets/mock_data/` if API calls fail. This system is active only in the development environment, ensuring seamless frontend development without a live backend connection.
- **Configuration**: Uses environment-specific property files (`application.properties`, `application-dev.properties`, `application-prod.properties`) for managing settings.

### Feature Specifications
- **User Authentication**: Login, registration, Google OAuth.
- **Portfolio Analytics**: Sector allocation, market cap distribution, top holdings, and risk metrics.
- **Heatmap Visualizations**: Placeholder, planned for future iterations.
- **Holdings Management**: Comprehensive display with sorting, filtering, and configurable views (table, card).
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