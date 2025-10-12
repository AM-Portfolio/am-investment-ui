# Trade Module Feature Documentation

Based on the comprehensive analysis of mock data in `/lib/assets/mock_data/trade/`, this document outlines all possible features that can be implemented across the 4 main trade pages.

## Data Sources Available

### Core Data Files:
- **trade_portfolios.json** - Portfolio overview with basic metrics
- **trade_summary.json** - Comprehensive portfolio analytics and sector allocation 
- **trade_holdings.json** - Detailed individual trade records with full lifecycle data
- **trade_calendar.json** - Simplified calendar events for trade activities
- **trade_portfolio_summary.json** - Advanced portfolio metrics and performance data
- **calander/calender-response.json** - Detailed trade data organized by portfolio ID
- **details/trade_details_by_id.json** - Individual trade execution details
- **portfolio_analytics.json** - Advanced heatmap and sector analysis

---

## COMMON FILTER COMPONENT (Shared across Holdings & Calendar Pages)

### Universal Filter Panel
A reusable filter component that can be applied to both Holdings and Calendar pages with consistent behavior and UI.

#### 1. Date Range Filters
- **From Date Picker**: Select start date for filtering
- **To Date Picker**: Select end date for filtering  
- **Quick Date Presets**:
  - Today
  - This Week
  - This Month
  - Last 30 days
  - Last 90 days
  - This Year
  - All Time
  - Custom Range

#### 2. Security/Stock Filters
- **Symbol Search**: Type-ahead search for stock symbols
  - Examples: `TATAMTRDVR`, `COALINDIA`, `SUNPHARMA`, `ITC`, `PNB`
- **Multi-Select Dropdown**: Select multiple securities
- **Select All/None** toggles
- **Recent Selections**: Quick access to recently filtered stocks

#### 3. Sector/Category Filters
- **Sector Selection** (Multi-select checkboxes):
  - Healthcare (39.6% allocation)
  - Automotive (27.4% allocation)
  - Financial Services (22.2% allocation)
  - FMCG (7.4% allocation)
  - Energy (3.4% allocation)
- **Sector Performance Filter**:
  - Top Performing Sectors
  - Underperforming Sectors
  - All Sectors

#### 4. Trade Status Filters
- **Trade Outcome** (Multi-select):
  - Profitable Trades
  - Loss-making Trades
  - Break-even Trades
  - Open Positions
- **Trade Type**:
  - BUY transactions
  - SELL transactions
  - Both

#### 5. Performance Filters
- **P&L Range Sliders**:
  - Minimum Profit/Loss amount: `-₹5,000 to +₹5,000`
  - Percentage gain/loss: `-5% to +5%`
- **Position Size Filters**:
  - Investment amount range: `₹0 to ₹1,000,000`
  - Quantity range: `0 to 50,000 shares`

#### 6. Advanced Filters
- **Broker Filter**:
  - ZERODHA
  - Other brokers (when available)
- **Exchange Filter**:
  - NSE
  - BSE
  - Others
- **Holding Period**:
  - Intraday (< 1 day)
  - Short-term (1-30 days)
  - Medium-term (31-365 days)
  - Long-term (> 365 days)

#### 7. Risk Management Filters
- **Risk-Reward Ratio**:
  - High Risk-Reward (>2:1)
  - Moderate Risk-Reward (1:1 to 2:1)
  - Low Risk-Reward (<1:1)
- **Portfolio Impact**:
  - High Impact (>5% of portfolio)
  - Medium Impact (1-5% of portfolio)
  - Low Impact (<1% of portfolio)

### Filter UI Components

#### Filter Bar Layout
```
[Date Range] [Stocks ▼] [Sectors ▼] [Status ▼] [P&L Range] [More Filters ▼] [Clear All] [Apply]
```

#### Filter State Management
- **Active Filters Display**: Show applied filters as removable chips
- **Filter Count Indicator**: "(5 filters active)"
- **Save Filter Presets**: Save commonly used filter combinations
- **Quick Filter Suggestions**: Based on user behavior

#### Filter Integration Behavior

**For Holdings Page**:
- Filters applied to holdings table rows
- Updates holdings count and total value dynamically
- Maintains sort order within filtered results
- Shows filtered aggregations (total value, P&L of filtered holdings)

**For Calendar Page**:
- Filters applied to calendar events/trades
- Updates event visibility on calendar
- Maintains chronological order within filtered date range
- Shows filtered statistics (trade count, total volume for filtered period)

### Common Filter API Structure
```typescript
interface CommonFilter {
  dateRange: {
    startDate: string;
    endDate: string;
  };
  securities: string[]; // Array of stock symbols
  sectors: string[]; // Array of sector names
  tradeStatus: ('PROFITABLE' | 'LOSS' | 'BREAK_EVEN' | 'OPEN')[];
  tradeTypes: ('BUY' | 'SELL')[];
  pnlRange: {
    min: number;
    max: number;
  };
  investmentRange: {
    min: number;
    max: number;
  };
  brokers: string[];
  exchanges: string[];
  holdingPeriod: ('INTRADAY' | 'SHORT_TERM' | 'MEDIUM_TERM' | 'LONG_TERM')[];
  riskRewardRatio: {
    min: number;
    max: number;
  };
}
```

### Filter State Synchronization

#### Cross-Page Filter Persistence
- **Shared Filter State**: Filters applied on Holdings page remain active when switching to Calendar page
- **URL State Management**: Filter parameters stored in URL for bookmarking and sharing
- **Session Storage**: Filter preferences saved for user session
- **Default Filter Restoration**: Return to last used filters on page reload

#### Filter Impact Indicators
- **Result Count Updates**: Real-time count of filtered items
  - Holdings Page: "Showing 8 of 15 holdings"  
  - Calendar Page: "Showing 23 of 45 trade events"
- **Value Aggregations**: Update totals based on filtered data
  - Holdings: "Filtered Portfolio Value: ₹1,234,567"
  - Calendar: "Filtered Period P&L: ₹-2,345"

#### User Experience Enhancements
- **Filter Suggestions**: Auto-suggest based on available data
- **Smart Defaults**: Pre-populate common filter combinations
- **Filter History**: Quick access to recently used filter sets
- **Performance Optimization**: Efficient filtering for large datasets
- **Mobile-Friendly**: Touch-optimized filter interface for mobile devices

### Filter Integration Examples

#### Sample Filter Applications
1. **"Show Healthcare Profitable Trades This Month"**
   - Sectors: [Healthcare]
   - Trade Status: [PROFITABLE]  
   - Date Range: This Month
   - Result: Both pages show only profitable healthcare trades from current month

2. **"View Large Position Losses"**
   - Investment Range: >₹500,000
   - Trade Status: [LOSS]
   - Result: Holdings and Calendar show only loss-making positions above ₹5L

3. **"Analyze Short-term Trading Activity"**  
   - Holding Period: [INTRADAY, SHORT_TERM]
   - Date Range: Last 90 days
   - Result: Focus on quick trades in recent period across both views

---

## 1. TRADE DASHBOARD PAGE

### Key Performance Indicators (KPIs)
- **Portfolio Value Metrics**
  - Total portfolio value: `$2,637,100.00`
  - Total invested amount: `$2,638,221.20`
  - Net gain/loss: `-$1,121.20 (-0.04%)`
  - Today's change: `+$1,490.00 (+0.06%)`

- **Trading Performance Stats**
  - Total trades executed: `15`
  - Win rate: `46.67%` (7 winning trades)
  - Loss rate: `26.67%` (4 losing trades) 
  - Break-even trades: `4`
  - Open positions: `0`

### Visual Dashboard Components

#### 1. Portfolio Overview Cards
- **Total Value Card** with trend indicator
- **Daily P&L Card** with percentage change
- **Win Rate Card** with visual percentage indicator
- **Active Trades Counter**

#### 2. Quick Action Buttons
- View All Holdings
- Trade Calendar
- Portfolio Summary
- Export Reports

#### 3. Top Performers Section
- **Top Gainers List**
  - Sun Pharmaceutical: `+$2,000.00 (+0.19%)`
  - ITC Limited: `+$900.00 (+0.46%)`
  - Coal India: `+$630.00 (+0.69%)`

- **Top Losers List**
  - Punjab National Bank: `-$4,651.20 (-0.79%)`

#### 4. Sector Allocation Pie Chart
- Healthcare: `39.6%` - `$1,044,000`
- Automotive: `27.4%` - `$722,400`
- Financial Services: `22.2%` - `$584,250`
- FMCG: `7.4%` - `$195,100`
- Energy: `3.4%` - `$91,350`

#### 5. Recent Activity Feed
- Latest 5-10 trade executions with timestamps
- Quick trade status indicators (Profit/Loss/Break-even)

---

## 2. TRADE SUMMARY PAGE

### Comprehensive Analytics Dashboard

#### 1. Portfolio Performance Metrics
- **Financial Summary**
  - Total Portfolio Value: `$2,637,100.00`
  - Total Amount Invested: `$2,638,221.20`
  - Absolute P&L: `-$1,121.20`
  - Percentage Return: `-0.04%`
  - Today's Performance: `+$1,490.00 (+0.06%)`

- **Advanced Trading Metrics**
  - Net Profit/Loss: `-$4,794.75`
  - Net P&L Percentage: `-0.06%`
  - Risk-Reward Analysis (where available)
  - Sharpe Ratio, Sortino Ratio (when calculated)

#### 2. Sector Analysis & Allocation
- **Interactive Sector Breakdown**
  - Pie chart with 5 sectors
  - Holdings count per sector
  - Performance comparison across sectors
  - Sector-wise contribution to overall portfolio

#### 3. Trade Performance Analytics
- **Trade Statistics**
  - Total Trades: `15`
  - Winning Trades: `7 (46.67%)`
  - Losing Trades: `4 (26.67%)`
  - Break-even Trades: `4 (26.67%)`
  - Average Holding Time Analysis

- **Profit Factor Analysis**
  - Win/Loss ratio calculations
  - Risk-reward ratio per trade
  - Maximum drawdown analysis

#### 4. Top Performers Analysis
- **Gainers Table** with sortable columns
  - Stock symbol, name, absolute change, percentage change
  - Current price information
  - Contribution to portfolio performance

- **Losers Table** with detailed metrics
  - Impact analysis on overall portfolio
  - Recovery potential indicators

#### 5. Historical Performance Charts
- **Portfolio Value Trend** (time series)
- **Cumulative P&L Chart**
- **Sector Performance Comparison**
- **Monthly/Weekly Returns** (when data available)

---

## 3. HOLDINGS PAGE

### Detailed Position Management

#### 1. Holdings Overview
- **Total Holdings Count**: `5 active positions`
- **Total Holdings Value**: `$2,637,100.00`
- **Aggregated Gain/Loss**: `-$1,121.20`

#### 2. Individual Holdings Table
Each holding displays:
- **Basic Information**
  - Symbol (e.g., TATAMTRDVR, COALINDIA, SUNPHARMA, ITC, PNB)
  - Company name and ISIN code
  - Exchange and segment details

- **Position Details**
  - Current quantity held
  - Average buy price
  - Current market price
  - Total investment value
  - Current market value
  - Unrealized P&L (absolute and percentage)

- **Performance Metrics**
  - Days held
  - Price change since purchase
  - Contribution to portfolio percentage

#### 3. Advanced Holdings Features
- **Common Filter Integration** *(See Common Filter Component above)*
  - Apply universal filters to holdings data
  - Real-time filtering of holdings table
  - Filtered aggregations and totals
  - Filter state persistence across page navigation

- **Holdings-Specific Sorting**
  - Sort by current value (highest to lowest)
  - Sort by P&L performance (best to worst performers)
  - Sort by holding period (newest to oldest positions)
  - Sort by portfolio allocation percentage
  - Sort alphabetically by stock symbol/name

- **Holdings Analytics**
  - Concentration risk analysis based on filtered data
  - Sector diversification metrics within filter scope
  - Position size recommendations for filtered holdings
  - Risk exposure analysis for selected securities

#### 4. Risk Management Tools
- **Position Sizing Analysis**
  - Individual position as % of portfolio
  - Risk concentration warnings
  - Diversification recommendations

- **Performance Attribution**
  - Sector contribution to overall performance
  - Individual stock impact analysis

---

## 4. CALENDAR VIEW PAGE

### Trade Timeline & Activity Tracking

#### 1. Calendar Interface
- **Monthly View** with trade activities marked
- **Event Types**:
  - BUY transactions (green indicators)
  - SELL transactions (red indicators)
  - Break-even exits (yellow indicators)
  - Profitable exits (bright green)

#### 2. Trade Events Display
Each calendar event shows:
- **Basic Event Info**
  - Trade date and time (e.g., "2020-09-07T09:33:57")
  - Event type (BUY/SELL)
  - Stock symbol (TATAMTRDVR, COALINDIA, etc.)
  - Trade amount

- **Event Details**
  - Quantity traded: `12,000 shares`
  - Price per share: `₹60.20`
  - Total transaction value: `₹722,400`
  - Trade outcome (profit/loss/break-even)

#### 3. Daily Trade Summary
- **Daily Aggregations**
  - Total trades executed on selected date
  - Net P&L for the day
  - Volume traded
  - Number of different securities

#### 4. Trade Execution Details
Clicking on calendar events reveals:
- **Complete Trade Lifecycle**
  - Entry timestamp, price, quantity
  - Exit timestamp, price, quantity
  - Holding period (days, hours, minutes)
  - Final P&L outcome

- **Execution Breakdown**
  - Order IDs and trade IDs
  - Broker information (e.g., ZERODHA)
  - Exchange details (NSE)
  - Auction vs regular trading

#### 5. Advanced Calendar Features
- **Common Filter Integration** *(See Common Filter Component above)*
  - Apply universal filters to calendar events
  - Dynamic event visibility based on filter criteria
  - Filtered trade statistics and summaries
  - Date range filtering with calendar navigation sync

- **Calendar-Specific Features**
  - **View Modes**: Month view, Week view, Day view
  - **Event Density Indicators**: Color-coded days by trade volume
  - **Quick Navigation**: Jump to specific months/years
  - **Event Clustering**: Group multiple trades on same day

- **Calendar Analytics** *(Applied to Filtered Data)*
  - Best performing days/months within filter scope
  - Trade frequency analysis for selected securities/sectors
  - Seasonal pattern identification for filtered data set
  - Volume analysis by time periods

---

## 5. DETAILED TRADE VIEW (Drill-down Feature)

### Individual Trade Analysis

#### 1. Trade Overview Card
- **Trade Identification**
  - Trade ID: `bfa832bd-2018-496b-9672-e095831f2732`
  - Portfolio ID: `8a57024c-05c2-475b-a2c4-0545865efa4a`
  - Trade Status: `BREAK_EVEN`/`PROFITABLE`/`LOSS`
  - Position Type: `LONG`/`SHORT`

#### 2. Instrument Information
- **Security Details**
  - Symbol: `TATAMTRDVR`
  - ISIN: `IN9155A01020`
  - Exchange: `NSE`
  - Segment: `EQUITY`
  - Series: `EQ`

#### 3. Trade Execution Timeline
- **Entry Information**
  - Entry timestamp: `2020-09-07T09:33:57`
  - Entry price: `₹60.20`
  - Quantity: `12,000 shares`
  - Total value: `₹722,400`
  - Fees: `₹0`

- **Exit Information**
  - Exit timestamp: `2020-09-07T09:53:56`
  - Exit price: `₹60.20`
  - Exit quantity: `12,000 shares`
  - Total value: `₹722,400`
  - Fees: `₹0`

#### 4. Performance Metrics
- **Profit/Loss Analysis**
  - Absolute P&L: `₹0.00`
  - P&L Percentage: `0.00%`
  - Return on Equity: `0.00%`

- **Risk Management Metrics**
  - Risk amount: `₹14,448`
  - Reward amount: `₹28,896`
  - Risk-reward ratio: `1:2`

- **Timing Analysis**
  - Holding time: `19 minutes`
  - Days held: `0`
  - Hours held: `0`

#### 5. Execution Details
- **Buy Order Execution**
  - Trade ID: `75454738`
  - Order ID: `1300000001825333`
  - Execution time: `2020-09-07T09:33:57`
  - Broker: `ZERODHA`
  - Quantity: `12,000`
  - Price: `₹60.20`

- **Sell Order Execution**
  - Trade ID: `75779695`
  - Order ID: `1300000002116713`
  - Execution time: `2020-09-07T09:53:56`
  - Broker: `ZERODHA`
  - Quantity: `12,000`
  - Price: `₹60.20`

---

## Technical Implementation Features

### 1. Data Visualization Components
- **Charts & Graphs**
  - Pie charts for sector allocation
  - Line charts for portfolio performance
  - Bar charts for trade performance comparison
  - Heatmaps for sector/stock performance
  - Candlestick charts for price movements

### 2. Interactive Features
- **Search & Filter**
  - Global search across all trades
  - Advanced filtering by multiple criteria
  - Sort functionality on all data tables
  - Date range pickers for historical analysis

### 3. Export & Reporting
- **Data Export Options**
  - PDF portfolio reports
  - CSV data exports
  - Excel formatted reports
  - Print-friendly views

### 4. Real-time Updates
- **Live Data Features**
  - Real-time price updates (when API connected)
  - Live P&L calculations
  - Market status indicators
  - Auto-refresh capabilities

### 5. Mobile Responsiveness
- **Adaptive UI Components**
  - Responsive dashboard cards
  - Mobile-optimized tables
  - Touch-friendly calendar interface
  - Swipe gestures for navigation

---

## Summary of Comprehensive Features

This trade module can support a **full-featured trading portfolio management system** with:

- **4 Main Pages**: Dashboard, Summary, Holdings, Calendar
- **30+ Individual Features** across all pages
- **Advanced Analytics** with risk management
- **Detailed Trade Tracking** with complete lifecycle
- **Interactive Visualizations** for better insights
- **Comprehensive Reporting** and export capabilities
- **Mobile-First Design** for accessibility

The mock data provides sufficient depth to build a **professional-grade trading application** with institutional-quality features and analytics.