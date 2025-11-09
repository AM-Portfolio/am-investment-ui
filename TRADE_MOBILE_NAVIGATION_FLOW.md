# Trade Mobile Navigation - Visual Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                        MAIN APP VIEW                             │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                   Content Area                            │  │
│  │              (Portfolio, Dashboard, etc.)                 │  │
│  │                                                           │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │            DEFAULT BOTTOM NAVIGATION BAR                  │  │
│  │  [Portfolio] [Dashboard] [Trade] [Market] [News]         │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
                              │
                              │ User taps "Trade"
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                    TRADE SECTION VIEW                            │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  App Bar: "Trade Portfolios"  [←] [Refresh]              │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                                                           │  │
│  │              PORTFOLIOS LIST VIEW                         │  │
│  │        (Shows available portfolios to select)             │  │
│  │                                                           │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │           TRADE BOTTOM NAVIGATION BAR                     │  │
│  │    [Portfolios✓] [Holdings] [Calendar]                   │  │
│  │                    ↑ disabled  ↑ disabled                 │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                  │
│  Note: Default bottom nav is HIDDEN                             │
└─────────────────────────────────────────────────────────────────┘
                              │
                              │ User selects a portfolio
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│              TRADE SECTION - HOLDINGS VIEW                       │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  App Bar: "Holdings - Portfolio Name"  [×] [Refresh]     │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                                                           │  │
│  │              HOLDINGS DASHBOARD                           │  │
│  │        (Detailed trade positions & analytics)             │  │
│  │                                                           │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │           TRADE BOTTOM NAVIGATION BAR                     │  │
│  │    [Portfolios] [Holdings✓] [Calendar]                   │  │
│  │                      ↑ active    ↑ enabled                │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
                              │
                              │ User taps "Calendar"
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│              TRADE SECTION - CALENDAR VIEW                       │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  App Bar: "Calendar - Portfolio Name"  [×] [Refresh]     │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │         Summary: Trades | P&L | Win Rate                 │  │
│  ├──────────────────────────────────────────────────────────┤  │
│  │                                                           │  │
│  │              CALENDAR ANALYTICS                           │  │
│  │        (Trade events timeline & insights)                 │  │
│  │                                                           │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │           TRADE BOTTOM NAVIGATION BAR                     │  │
│  │    [Portfolios] [Holdings] [Calendar✓]                   │  │
│  │                                      ↑ active             │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
                              │
                              │ User taps [←] Back button
                              ▼
                    Returns to MAIN APP VIEW
```

## Key Navigation Actions

1. **← Back Button** (in app bar)
   - Always visible in Trade section
   - Returns to main app (Portfolio view)
   - Restores default bottom navigation

2. **× Close Portfolio** (in app bar when portfolio selected)
   - Clears current portfolio selection
   - Returns to Portfolios tab
   - Disables Holdings and Calendar tabs

3. **Refresh Button** (in app bar)
   - Context-aware: refreshes current view data
   - Shows toast notification

4. **Trade Bottom Tabs**
   - Portfolios: Always enabled
   - Holdings: Enabled only when portfolio selected
   - Calendar: Enabled only when portfolio selected
   - Visual feedback for disabled state

## State Management

- Portfolio Selection State: Maintained in TradeMobileScreen
- Auto-navigation: Selecting portfolio → switches to Holdings view
- Smart tab disabling: No portfolio = Holdings/Calendar disabled
- Clear user feedback: Toast messages and visual indicators
