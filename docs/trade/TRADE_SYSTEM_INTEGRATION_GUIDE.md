# Trade System Integration Guide

## Overview
This guide explains how to integrate the unified trade management system in your Flutter app, following the proven template design pattern used in investment portfolio heatmap features. The system provides reusable components for trade analysis, trade portfolio management, and calendar views across mobile and web platforms.

---

## 📊 **Trade System Architecture**

### **Template Design Pattern**

Following the proven investment portfolio heatmap approach, the trade system uses:

- **Reusable Components**: Template widgets for different trade views
- **Dual Architecture Support**: Both unified and dual cubit approaches (borrowed from investment portfolio patterns)
- **Platform Optimization**: Mobile and web-specific implementations
- **Consistent API**: Standardized methods across all components
- **Sequential User Flow**: Structured API calls following trade specifications

### **Core Components Structure**

```
lib/features/trade/
├── data/
│   ├── models/
│   │   ├── trade_portfolio_summary.dart
│   │   ├── trade_holding.dart
│   │   ├── trade_execution.dart
│   │   ├── calendar_data.dart
│   │   └── paginated_response.dart
│   └── services/
│       └── trade_api_service.dart
├── domain/
│   ├── entities/
│   └── repositories/
├── presentation/
│   ├── cubit/
│   │   ├── unified_trade_cubit.dart           # Unified approach
│   │   ├── trade_portfolio_list_cubit.dart    # Dual approach - Step 1
│   │   ├── trade_holdings_cubit.dart          # Dual approach - Steps 2-3
│   │   └── trade_calendar_cubit.dart          # Dual approach - Step 4
│   ├── components/templates/
│   │   ├── trade_portfolio_discovery_template.dart  # Step 1: Owner portfolios
│   │   ├── trade_portfolio_analysis_template.dart   # Step 2: Summary & holdings
│   │   ├── trade_details_template.dart              # Step 3: Individual trades
│   │   └── calendar_analytics_template.dart         # Step 4: Calendar views
│   ├── web/pages/
│   │   ├── trade_portfolio_list_web_page.dart       # Page 1: Portfolio discovery
│   │   ├── trade_holdings_dashboard_web_page.dart   # Page 2: Holdings & analysis
│   │   └── trade_calendar_analytics_web_page.dart   # Page 3: Calendar & analytics
│   └── mobile/pages/
│       ├── trade_portfolio_list_mobile_page.dart    # Page 1: Portfolio discovery
│       ├── trade_holdings_dashboard_mobile_page.dart # Page 2: Holdings & analysis
│       └── trade_calendar_analytics_mobile_page.dart # Page 3: Calendar & analytics
```

---

## 📊 **Data Schema Reference**

### **API Data Schemas**
Based on trade API technical specifications:

**1. Trade Portfolio Summary Schema**
- Reference: `trade_portfolio_summary.json`
- Key Properties: Portfolio identification, financial metrics, trade statistics, performance metrics

**2. Trade Holdings Schema**
- Reference: `trade_holdings.json` (1796 lines)
- Key Properties: Trade identification, instrument details, entry/exit information, performance metrics

**3. Detailed Trade Execution Schema**
- Reference: `trade_details_by_id.json`
- Key Properties: Basic info, instrument information, execution details

**4. Calendar Response Schema**
- Reference: `calender-response.json` (887 lines)
- Structure: Portfolio ID as key with array of simplified trade objects

---

## 🔌 **API Endpoint Integration**

### **Sequential API Flow**

**Step 1: User Portfolio Discovery**
- Endpoint: `GET /api/v1/portfolio-summary/by-owner/{ownerId}`
- Purpose: Initial endpoint - Retrieve list of all portfolios for authenticated user
- Usage Flow: First call after user authentication

**Step 2: Portfolio Analysis**
- Endpoint: `GET /api/v1/portfolio-summary/{portfolioId}`
- Purpose: Get detailed portfolio summary with comprehensive metrics
- Endpoint: `GET /api/v1/trades/portfolio-details/{portfolioId}`
- Purpose: Retrieve all trades within the selected portfolio with pagination

**Step 3: Detailed Trade Information**
- Endpoint: `POST /api/v1/trades/details/by-ids`
- Purpose: Get detailed execution information for specific trades

**Step 4: Calendar & Analytics Views**
- Endpoints: Various calendar endpoints (month, day, quarter, financial-year)
- Purpose: Get calendar view data for portfolio trades

---

## 📱 **Page Structure & Integration**

### **Web Pages (Desktop-Optimized UI)**

#### **1. TradePortfolioListWebPage**
- **Purpose**: Trade portfolio discovery and selection
- **UI Features**: Grid layout with large cards, sidebar filters, desktop navigation
- **Template Used**: `TradePortfolioDiscoveryTemplate`
- **Integration**: Uses `TradePortfolioListCubit` with desktop-optimized grid layout

#### **2. TradeHoldingsDashboardWebPage**
- **Purpose**: Comprehensive trade holdings analysis
- **UI Features**: Split-panel layout, advanced filtering, data tables
- **Template Used**: `TradeHoldingsTemplate` + `TradePortfolioAnalysisTemplate`
- **Integration**: Uses `TradeHoldingsCubit` with split-panel design

#### **3. TradeCalendarAnalyticsWebPage**
- **Purpose**: Time-based trade analytics and calendar views
- **UI Features**: Full-screen calendar, multiple view types, export options
- **Template Used**: `CalendarAnalyticsTemplate`
- **Integration**: Uses `TradeCalendarCubit` with full-screen calendar

### **Mobile Pages (Touch-Optimized UI)**

#### **1. TradePortfolioListMobilePage**
- **Purpose**: Trade portfolio discovery with mobile-first design
- **UI Features**: Vertical list layout, pull-to-refresh, bottom navigation
- **Template Used**: `TradePortfolioDiscoveryTemplate`
- **Integration**: Uses `TradePortfolioListCubit` with mobile-first vertical list

#### **2. TradeHoldingsDashboardMobilePage**
- **Purpose**: Mobile-optimized trade holdings dashboard
- **UI Features**: Tabbed interface, collapsible sections, bottom sheets
- **Template Used**: `TradeHoldingsTemplate` + `TradePortfolioAnalysisTemplate`
- **Integration**: Uses `TradeHoldingsCubit` with tabbed interface

#### **3. TradeCalendarAnalyticsMobilePage**
- **Purpose**: Mobile calendar with swipe gestures and touch interactions
- **UI Features**: Swipeable calendar, FAB controls, compact analytics
- **Template Used**: `CalendarAnalyticsTemplate`
- **Integration**: Uses `TradeCalendarCubit` with swipeable calendar

---

## 🎯 **Template-Based Development**

### **Template Advantages** (Based on Investment Portfolio Heatmap Success)

- **Code Reusability**: Shared business logic across platforms
- **Consistent Behavior**: Same data handling and state management
- **Easy Maintenance**: Single template for multiple UI implementations
- **Platform Optimization**: UI adapted for each platform's strengths
- **Rapid Development**: Template-based approach accelerates development

### **Template Implementation Strategy**

#### **TradePortfolioDiscoveryTemplate**
- **Web Implementation**: Large grid cards with detailed metrics, hover effects
- **Mobile Implementation**: Compact list cards with essential information only
- **Shared Logic**: Portfolio loading, selection handling, error states

#### **TradeHoldingsTemplate**
- **Web Implementation**: Data table with sorting, filtering, multi-select
- **Mobile Implementation**: Card-based list with swipe actions, infinite scroll
- **Shared Logic**: Pagination handling, trade selection, data formatting

#### **CalendarAnalyticsTemplate**
- **Web Implementation**: Full calendar with sidebar controls, export options
- **Mobile Implementation**: Compact calendar with FAB controls, bottom sheets
- **Shared Logic**: Date navigation, data fetching, analytics calculations

---

## 🏗️ **State Management Patterns**

### **Architectural Options** (Following Investment Portfolio Heatmap Pattern)

#### **Dual Cubit Approach (Recommended for Complex Flows)**
- **TradePortfolioListCubit**: Handles Step 1 - Portfolio Discovery
- **TradeHoldingsCubit**: Handles Steps 2-3 - Portfolio Analysis & Trade Holdings
- **TradeCalendarCubit**: Handles Step 4 - Calendar Analytics

#### **Unified Cubit Approach (Simplified for Web)**
- **UnifiedTradeCubit**: Single cubit managing entire trade flow
- Combines all trade operations in one state manager
- Reduced boilerplate code

### **Architecture Decision Matrix**

| Use Case | Recommended Approach | Page Class | Cubit Pattern | Benefits |
|----------|---------------------|------------|---------------|----------|
| Mobile App (Complex) | Dual Cubit | `TradeDashboardMobilePage` | Multi-provider | Fine-grained control, separation of concerns |
| Mobile App (Simple) | Unified Cubit | `SimplifiedTradeDashboardMobilePage` | Single provider | Reduced boilerplate, easier state management |
| Web App (New) | Unified Cubit | `SimplifiedTradeDashboardWebPage` | Single provider | Clean architecture, easy maintenance |
| Web App (Legacy) | Dual Cubit | `TradeDashboardWebPage` | Multi-provider | Consistent with existing patterns |
| Responsive App | Mixed | Both based on breakpoint | Context-dependent | Platform-optimized experiences |

---

## 📱 **Platform-Specific Features**

### **Web UI Features:**
- **Desktop Navigation**: Breadcrumbs, sidebar navigation, keyboard shortcuts
- **Advanced Interactions**: Hover states, right-click menus, drag-and-drop
- **Layout Optimization**: Multi-column layouts, split panels, modal dialogs
- **Data Display**: Sortable tables, advanced filters, export functionality
- **Screen Real Estate**: Full utilization of wide screens, detailed information display

### **Mobile UI Features:**
- **Touch Navigation**: Bottom tabs, swipe gestures, pull-to-refresh
- **Mobile Interactions**: Long press actions, swipe-to-dismiss, haptic feedback
- **Layout Optimization**: Single column, collapsible sections, FAB controls
- **Data Display**: Card layouts, bottom sheets, simplified filtering
- **Screen Optimization**: Thumb-friendly controls, vertical scrolling focus

### **Responsive Features:**
- Automatic layout switching at 800px breakpoint
- Platform-appropriate UI patterns
- Consistent state across screen sizes
- Adaptive grid/list layouts

---

## 🧪 **Testing Framework**

### **Template Testing Strategy:**

**Component Testing:**
- Test templates with different UI configurations
- Verify responsive behavior across screen sizes
- Test platform-specific interactions

**Page Testing:**
- Test web pages with desktop interactions
- Test mobile pages with touch gestures
- Verify navigation flows between pages

**Integration Testing:**
- Test complete user flows across all pages
- Verify state management consistency
- Test API integration with real data

### **Testing Utilities:**

**TradeSystemTestUtils**: Utility class for creating test wrappers with both unified and dual cubit approaches. Includes methods for testing complete user flows and state transitions.

**MockTradeApiService**: Mock service following API specifications with sample data for all endpoints including portfolio discovery, holdings, and calendar data.

---

## 🚀 **Getting Started Checklist**

### **Basic Page Setup:**
- [ ] Implement `TradePortfolioListWebPage` with grid layout
- [ ] Implement `TradePortfolioListMobilePage` with list layout
- [ ] Add navigation between portfolio list and holdings dashboard
- [ ] Implement `TradeHoldingsDashboardWebPage` with split-panel design
- [ ] Implement `TradeHoldingsDashboardMobilePage` with tabbed interface
- [ ] Add trade detail views (modal for web, bottom sheet for mobile)
- [ ] Implement `TradeCalendarAnalyticsWebPage` with full calendar
- [ ] Implement `TradeCalendarAnalyticsMobilePage` with swipeable calendar

### **Template Integration:**
- [ ] Create reusable templates for each major component
- [ ] Implement platform-specific UI variations
- [ ] Add responsive breakpoints for hybrid experiences
- [ ] Test templates across different screen sizes
- [ ] Optimize for performance on both platforms

### **Advanced Features:**
- [ ] Add search and filtering across all pages
- [ ] Implement export functionality for web
- [ ] Add offline support for mobile
- [ ] Integrate push notifications
- [ ] Add advanced analytics and reporting

---

## 💡 **Best Practices**

### **Template Development:**
- **Separation of Concerns**: Keep UI logic separate from business logic
- **Platform Optimization**: Leverage each platform's strengths
- **Code Reusability**: Maximize shared code while optimizing UX
- **Performance**: Optimize for each platform's performance characteristics
- **Accessibility**: Ensure templates work well with accessibility features

### **Performance Optimization:**
- Use pagination for large trade lists (50 items per page)
- Implement lazy loading for trade details
- Cache frequently accessed trade portfolio data
- Optimize calendar rendering with virtual scrolling
- Use Flutter's ListView.builder for efficient rendering

### **Error Handling:**
- Implement retry mechanisms for network failures
- Show user-friendly error messages with actionable steps
- Log errors for debugging with proper error codes
- Provide offline fallbacks with cached data

---

## 📁 **Complete File Structure**

```
lib/features/trade/
├── data/
│   ├── models/
│   │   ├── trade_portfolio.dart
│   │   ├── trade_portfolio_summary.dart
│   │   ├── trade_holding.dart
│   │   ├── trade_execution.dart
│   │   ├── calendar_data.dart
│   │   └── paginated_response.dart
│   ├── services/
│   │   ├── trade_api_service.dart
│   │   └── trade_cache_service.dart
│   └── repositories/
│       └── trade_repository_impl.dart
├── domain/
│   ├── entities/
│   ├── repositories/
│   │   └── trade_repository.dart
│   └── usecases/
├── presentation/
│   ├── cubit/
│   │   ├── unified_trade_cubit.dart           # Unified approach
│   │   ├── trade_portfolio_list_cubit.dart    # Page 1 state management
│   │   ├── trade_holdings_cubit.dart          # Page 2 state management
│   │   └── trade_calendar_cubit.dart          # Page 3 state management
│   ├── components/templates/
│   │   ├── trade_portfolio_discovery_template.dart  # Template for page 1
│   │   ├── trade_portfolio_analysis_template.dart   # Template for page 2
│   │   ├── trade_holdings_template.dart             # Template for holdings
│   │   ├── trade_details_template.dart              # Template for details
│   │   ├── calendar_analytics_template.dart         # Template for page 3
│   │   ├── trade_card_template.dart                 # Reusable card
│   │   ├── trade_portfolio_metrics_template.dart    # Reusable metrics
│   │   └── filter_panel_template.dart               # Reusable filters
│   ├── web/pages/
│   │   ├── trade_portfolio_list_web_page.dart       # Web Page 1
│   │   ├── trade_holdings_dashboard_web_page.dart   # Web Page 2
│   │   └── trade_calendar_analytics_web_page.dart   # Web Page 3
│   ├── mobile/pages/
│   │   ├── trade_portfolio_list_mobile_page.dart    # Mobile Page 1
│   │   ├── trade_holdings_dashboard_mobile_page.dart # Mobile Page 2
│   │   └── trade_calendar_analytics_mobile_page.dart # Mobile Page 3
│   └── shared/
│       ├── responsive_trade_dashboard.dart
│       ├── trade_navigation_helper.dart
│       └── trade_ui_helpers.dart
├── utils/
│   ├── trade_formatters.dart
│   ├── trade_calculations.dart
│   ├── mock_data.dart
│   └── trade_migration_helper.dart
└── tests/
    ├── pages/
    │   ├── web_pages_test.dart
    │   └── mobile_pages_test.dart
    ├── templates/
    │   └── template_test.dart
    ├── cubit_test.dart
    ├── service_test.dart
    ├── component_test.dart
    ├── integration_test.dart
    └── user_flow_test.dart
```

---

## 📞 **Support & Documentation**

### **Migration from Investment Portfolio Heatmap Pattern:**

This trade system leverages the proven template design pattern from investment portfolio heatmap features while implementing the complete trade API specification flow for optimal user experience with dedicated trade portfolio management.

### **Page Development Guidelines:**

**Web Pages:**
- Focus on desktop interactions and layouts
- Utilize screen real estate effectively
- Implement keyboard shortcuts and accessibility
- Provide advanced filtering and export options

**Mobile Pages:**
- Optimize for touch interactions
- Use mobile-specific UI patterns
- Implement gesture-based navigation
- Focus on essential information display

**Template Usage:**
- Leverage shared templates for consistency
- Customize UI for platform-specific needs
- Maintain separation between logic and presentation
- Test across different screen sizes

### **Related Documentation:**
- `TRADE_API_TECHNICAL_SPECS.md` - Complete API specifications and data schemas
- Investment Portfolio Heatmap Integration (reference pattern for template design)

This comprehensive trade system follows the proven template design pattern while providing platform-optimized experiences through dedicated web and mobile pages that share common business logic and templates.

<!-- This file should be deleted - consolidated into main trade guide -->
