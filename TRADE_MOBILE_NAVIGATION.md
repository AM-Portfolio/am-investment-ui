# Trade Feature Mobile Navigation Implementation

## Summary

Implemented a new mobile trade screen with bottom tab navigation that replaces the default app bottom navigation when in the Trade section.

## Changes Made

### 1. New Mobile Trade Screen
**File:** `lib/features/trade/presentation/mobile/trade_mobile_screen.dart`

- Created `TradeMobileScreen` widget with its own bottom tab navigation
- Three tabs: Portfolios, Holdings, Calendar
- Smart navigation: Holdings and Calendar tabs disabled until a portfolio is selected
- Back button in app bar to return to main app navigation
- Integrated portfolio selection flow

**Key Features:**
- Context-aware app bar with refresh actions
- Bottom tab bar with visual indicators for enabled/disabled states
- Automatic view switching when portfolio is selected
- Portfolio selection prompt for holdings/calendar views
- Clean state management for current portfolio

### 2. Mobile Calendar Page
**File:** `lib/features/trade/presentation/mobile/pages/trade_calendar_analytics_mobile_page.dart`

- Simplified calendar view for mobile
- Summary statistics display (Total Trades, P&L, Win Rate)
- List view of calendar events with trade details
- Proper error and loading states

### 3. Updated Mobile Holdings Page
**File:** `lib/features/trade/presentation/mobile/pages/trade_holdings_dashboard_mobile_page.dart`

- Removed duplicate app bar (now handled by parent screen)
- Removed calendar navigation (handled by bottom tabs)
- Cleaner component structure

### 4. Mobile Layout Enhancement
**File:** `lib/shared/widgets/layouts/mobile_layout.dart`

- Added `hideBottomNav` parameter to conditionally hide default bottom navigation
- Allows sub-features to have their own navigation systems

### 5. Auth Wrapper Integration
**File:** `lib/features/authentication/presentation/pages/auth_wrapper.dart`

- Platform-specific trade screen selection (Web vs Mobile)
- Hides default bottom navigation when Trade section is active on mobile
- Added back navigation callback from Trade to main app

## User Flow

### Mobile Experience:

1. **Main App Navigation**
   - User sees default bottom nav: Portfolio, Dashboard, Trade, Market, News
   
2. **Entering Trade Section**
   - User taps "Trade" on main bottom nav
   - Default bottom nav is hidden
   - Trade screen appears with its own bottom tabs: Portfolios, Holdings, Calendar
   
3. **Within Trade Section**
   - Start on "Portfolios" tab showing available portfolios
   - Select a portfolio → automatically switches to "Holdings" tab
   - Can switch between Holdings and Calendar tabs
   - Back button in app bar returns to main app (Portfolio section)

4. **Easy Navigation**
   - Within Trade: Use bottom tabs to switch between Portfolios, Holdings, Calendar
   - Back to Main: Tap back button in app bar
   - No nested navigation complexity

## Benefits

1. **Cleaner UX**: No confusion between main app and trade-specific navigation
2. **Context-Aware**: Bottom nav changes based on current section
3. **Easy Back Navigation**: Clear back button to exit trade section
4. **Portfolio-Centric**: Holdings and Calendar only accessible after selecting a portfolio
5. **Visual Feedback**: Disabled tabs are visually distinct, tooltips inform users

## Design Highlights

- **Material Design 3**: Follows modern Material Design principles
- **Responsive**: Adapts to different screen sizes
- **Consistent**: Maintains app-wide theming
- **Accessible**: Clear icons, labels, and visual states

## Technical Implementation

- Uses `ConsumerStatefulWidget` for state management with Riverpod
- Conditional rendering based on portfolio selection state
- Clean separation between main app nav and trade nav
- Platform detection for Web vs Mobile experience
- Proper provider invalidation for data refresh
