# Trade System Data Schemas & API Specifications

## 📊 **Complete Data Schema Reference**

### **1. Portfolio Summary Schema**
**Reference**: `trade_portfolio_summary.json`

**Key Properties**:
- Portfolio identification (`portfolioId`, `name`, `ownerId`)
- Financial metrics (`initialCapital`, `currentCapital`, `netProfitLoss`)
- Trade statistics (`totalTrades`, `winRate`, `lossRate`)
- Performance metrics (`winningTrades`, `losingTrades`, `breakEvenTrades`)

### **2. Trade Holdings Schema**
**Reference**: `trade_holdings.json` (1796 lines)

**Key Properties**:
- Trade identification (`tradeId`, `portfolioId`)
- Instrument details (`symbol`, `isin`, `exchange`, `segment`)
- Entry/Exit information (`timestamp`, `price`, `quantity`, `totalValue`, `fees`)
- Performance metrics (`profitLoss`, `profitLossPercentage`, `riskRewardRatio`)
- Trade execution history array

### **3. Detailed Trade Execution Schema**
**Reference**: `trade_details_by_id.json`

**Key Properties**:
- Basic info (`tradeId`, `orderId`, `tradeDate`, `brokerType`)
- Instrument information (complete symbol and exchange details)
- Execution details (`tradeType`, `quantity`, `price`, `auction`)

### **4. Calendar Response Schema**
**Reference**: `calender-response.json` (887 lines)

**Structure**: Portfolio ID as key with array of simplified trade objects
**Key Properties**: Condensed trade information optimized for calendar display

---

## 🔌 **API Endpoint Specifications**

### **Step 1: User Portfolio Discovery**

#### **GET /api/v1/portfolio-summary/by-owner/{ownerId}**
**Purpose**: Initial endpoint - Retrieve list of all portfolios for authenticated user
**Usage Flow**: First call after user authentication

**Request:**
```http
GET /api/v1/portfolio-summary/by-owner/64d5f6c9-9516-4eca-ac45-c73cfff7a8ec
Accept: application/json
Authorization: Bearer {jwt_token}
```

**Response**: Array of portfolio objects with `portfolioId` and `name`

---

### **Step 2: Portfolio Analysis**

#### **GET /api/v1/portfolio-summary/{portfolioId}**
**Purpose**: Get detailed portfolio summary with comprehensive metrics
**Usage Flow**: Called when user selects a specific portfolio from the list

**Request:**
```http
GET /api/v1/portfolio-summary/8a57024c-05c2-475b-a2c4-0545865efa4a
Accept: application/json
Authorization: Bearer {jwt_token}
```

**Response**: Complete portfolio summary matching `trade_portfolio_summary.json` schema

#### **GET /api/v1/trades/portfolio-details/{portfolioId}**
**Purpose**: Retrieve all trades within the selected portfolio with pagination
**Usage Flow**: Called to display trade holdings table/list for the portfolio

**Request Parameters:**
- `page` (required): Page number (0-based indexing)
- `size` (required): Number of records per page (default: 50)
- `sort` (optional): Sort criteria (e.g., tradeDate,desc)

**Request:**
```http
GET /api/v1/trades/portfolio-details/8a57024c-05c2-475b-a2c4-0545865efa4a?page=0&size=50&sort=tradeDate%2Cdesc
Accept: application/json
Authorization: Bearer {jwt_token}
```

**Response**: Paginated response with `content` array matching `trade_holdings.json` schema

---

### **Step 3: Detailed Trade Information**

#### **POST /api/v1/trades/details/by-ids**
**Purpose**: Get detailed execution information for specific trades
**Usage Flow**: Called when user clicks on individual trades for detailed view

**Request:**
```http
POST /api/v1/trades/details/by-ids
Content-Type: application/json
Accept: application/json
Authorization: Bearer {jwt_token}

["bfa832bd-2018-496b-9672-e095831f2732", "TRADE002", "TRADE003"]
```

**Response**: Array of detailed trade data matching `trade_details_by_id.json` schema

---

### **Step 4: Calendar & Analytics Views**

#### **GET /api/v1/trades/calendar/month**
**Purpose**: Get calendar view data for portfolio trades by month
**Usage Flow**: Called for monthly calendar visualization

**Request Parameters:**
- `portfolioId` (required): Portfolio identifier
- `year` (required): Year for calendar data
- `month` (required): Specific month (1-12)

**Request:**
```http
GET /api/v1/trades/calendar/month?portfolioId=8a57024c-05c2-475b-a2c4-0545865efa4a&year=2020&month=9
Accept: application/json
Authorization: Bearer {jwt_token}
```

#### **GET /api/v1/trades/calendar/day**
**Purpose**: Get calendar view data for a specific day
**Usage Flow**: Called when user clicks on a specific date in calendar

**Request Parameters:**
- `portfolioId` (required): Portfolio identifier  
- `date` (required): Specific date (YYYY-MM-DD)

**Request:**
```http
GET /api/v1/trades/calendar/day?date=2020-12-15&portfolioId=8a57024c-05c2-475b-a2c4-0545865efa4a
Accept: application/json
Authorization: Bearer {jwt_token}
```

#### **GET /api/v1/trades/calendar/quarter**
**Purpose**: Get calendar view data for a specific quarter
**Usage Flow**: Called for quarterly performance analysis

**Request Parameters:**
- `portfolioId` (required): Portfolio identifier
- `year` (required): Year for calendar data
- `quarter` (required): Quarter number (1-4)

**Request:**
```http
GET /api/v1/trades/calendar/quarter?portfolioId=8a57024c-05c2-475b-a2c4-0545865efa4a&year=2020&quarter=4
Accept: application/json
Authorization: Bearer {jwt_token}
```

#### **GET /api/v1/trades/calendar/financial-year**
**Purpose**: Get calendar view data for financial year
**Usage Flow**: Called for annual performance analysis

**Request Parameters:**
- `portfolioId` (required): Portfolio identifier
- `financialYear` (required): Financial year (e.g., 2021)

**Request:**
```http
GET /api/v1/trades/calendar/financial-year?portfolioId=8a57024c-05c2-475b-a2c4-0545865efa4a&financialYear=2021
Accept: application/json
Authorization: Bearer {jwt_token}
```

**Response for All Calendar APIs**: Data matching `calender-response.json` schema organized by portfolio ID

---

## 📋 **Typical User Flow Sequence**

1. **Authentication & Discovery**: `GET /by-owner/{ownerId}` → Get user's portfolios
2. **Portfolio Selection**: `GET /portfolio-summary/{portfolioId}` → Get portfolio metrics
3. **Holdings View**: `GET /portfolio-details/{portfolioId}` → List all trades with pagination
4. **Trade Details**: `POST /details/by-ids` → Get specific trade execution details
5. **Analytics**: Calendar endpoints → Time-based analysis and visualization