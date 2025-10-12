import '../../domain/entities/trade_entities.dart';
import '../dtos/trade_dtos.dart';

class TradeMappers {
  // Portfolio List Mapping (same pattern as portfolio mappers)
  List<TradePortfolioSummary> portfolioListFromDtos(List<ApiTradePortfolioSummaryDto> dtos) {
    return dtos.map(portfolioSummaryFromDto).toList();
  }
  
  TradePortfolioSummary portfolioSummaryFromDto(ApiTradePortfolioSummaryDto dto) {
    return TradePortfolioSummary(
      portfolioId: dto.portfolioId,
      portfolioName: dto.portfolioName,
      ownerId: dto.ownerId,
      totalValue: dto.totalValue,
      totalReturn: dto.totalReturn,
      totalReturnPercentage: dto.totalReturnPercentage,
      totalTrades: dto.totalTrades,
      activeTrades: dto.activeTrades,
      lastUpdated: dto.lastUpdated,
    );
  }
  
  // Trade Holdings Mapping (following portfolio holdings pattern)
  List<TradeHolding> tradeHoldingsFromDtos(List<ApiTradeHoldingDto> dtos) {
    return dtos.map(_tradeHoldingFromDto).toList();
  }
  
  TradeHolding _tradeHoldingFromDto(ApiTradeHoldingDto dto) {
    return TradeHolding(
      tradeId: dto.tradeId,
      portfolioId: dto.portfolioId,
      symbol: dto.symbol,
      instrumentName: dto.instrumentName,
      tradeType: _getTradeType(dto.tradeType),
      quantity: dto.quantity,
      entryPrice: dto.entryPrice,
      exitPrice: dto.exitPrice,
      entryDate: dto.entryDate,
      exitDate: dto.exitDate,
      status: _getTradeStatus(dto.status),
      currentValue: dto.currentValue,
      unrealizedPnL: dto.unrealizedPnL,
      realizedPnL: dto.realizedPnL,
    );
  }

  TradeType _getTradeType(String type) {
    switch (type.toLowerCase()) {
      case 'buy': return TradeType.buy;
      case 'sell': return TradeType.sell;
      default: return TradeType.buy;
    }
  }

  TradeStatus _getTradeStatus(String status) {
    switch (status.toLowerCase()) {
      case 'open': return TradeStatus.open;
      case 'closed': return TradeStatus.closed;
      case 'pending': return TradeStatus.pending;
      default: return TradeStatus.open;
    }
  }
}
        profitFactor: map['profitFactor']?.toDouble() ?? 0.0,
      );

  RiskMetrics _riskMetricsFromMap(Map<String, dynamic> map) => RiskMetrics(
    var95: map['var95']?.toDouble() ?? 0.0,
    var99: map['var99']?.toDouble() ?? 0.0,
    cvar95: map['cvar95']?.toDouble() ?? 0.0,
    beta: map['beta']?.toDouble() ?? 0.0,
    correlationToMarket: map['correlationToMarket']?.toDouble() ?? 0.0,
    riskLevel: map['riskLevel']?.toString() ?? 'MEDIUM',
  );

  AssetAllocation _assetAllocationFromDto(ApiAssetAllocationDto dto) =>
      AssetAllocation(
        name: dto.name,
        value: dto.value,
        percentage: dto.percentage,
        category: _getAllocationCategory(dto.category),
        color: dto.color,
      );

  AllocationCategory _getAllocationCategory(String category) {
    switch (category.toLowerCase()) {
      case 'sector':
        return AllocationCategory.sector;
      case 'assetclass':
        return AllocationCategory.assetClass;
      case 'geography':
        return AllocationCategory.geography;
      case 'marketcap':
        return AllocationCategory.marketCap;
      default:
        return AllocationCategory.sector;
    }
  }

  // Trade Holdings Mapping
  List<TradeHolding> tradeHoldingsFromDto(List<ApiTradeHoldingDto> dtos) =>
      dtos.map(_tradeHoldingFromDto).toList();

  TradeHolding _tradeHoldingFromDto(ApiTradeHoldingDto dto) => TradeHolding(
    tradeId: dto.tradeId,
    portfolioId: dto.portfolioId,
    symbol: dto.symbol,
    instrumentName: dto.instrumentName,
    tradeType: _getTradeType(dto.tradeType),
    quantity: dto.quantity,
    entryPrice: dto.entryPrice,
    exitPrice: dto.exitPrice,
    entryDate: dto.entryDate,
    exitDate: dto.exitDate,
    status: _getTradeStatus(dto.status),
    currentValue: dto.currentValue,
    unrealizedPnL: dto.unrealizedPnL,
    realizedPnL: dto.realizedPnL,
    instrumentDetails: _instrumentDetailsFromMap(dto.instrumentDetails),
    executionDetails: _executionDetailsFromMap(dto.executionDetails),
  );

  TradeType _getTradeType(String type) {
    switch (type.toLowerCase()) {
      case 'buy':
        return TradeType.buy;
      case 'sell':
        return TradeType.sell;
      case 'short':
        return TradeType.short;
      case 'cover':
        return TradeType.cover;
      default:
        return TradeType.buy;
    }
  }

  TradeStatus _getTradeStatus(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return TradeStatus.open;
      case 'closed':
        return TradeStatus.closed;
      case 'pending':
        return TradeStatus.pending;
      case 'cancelled':
        return TradeStatus.cancelled;
      default:
        return TradeStatus.open;
    }
  }

  InstrumentDetails _instrumentDetailsFromMap(Map<String, dynamic> map) =>
      InstrumentDetails(
        symbol: map['symbol']?.toString() ?? '',
        name: map['name']?.toString() ?? '',
        sector: map['sector']?.toString() ?? '',
        exchange: map['exchange']?.toString() ?? '',
        currency: map['currency']?.toString() ?? '',
        instrumentType: _getInstrumentType(
          map['instrumentType']?.toString() ?? 'stock',
        ),
        marketData: _marketDataFromMap(
          map['marketData'] as Map<String, dynamic>? ?? {},
        ),
        fundamentalData: map['fundamentalData'] != null
            ? _fundamentalDataFromMap(
                map['fundamentalData'] as Map<String, dynamic>,
              )
            : null,
      );

  InstrumentType _getInstrumentType(String type) {
    switch (type.toLowerCase()) {
      case 'stock':
        return InstrumentType.stock;
      case 'bond':
        return InstrumentType.bond;
      case 'etf':
        return InstrumentType.etf;
      case 'option':
        return InstrumentType.option;
      case 'future':
        return InstrumentType.future;
      case 'crypto':
        return InstrumentType.crypto;
      default:
        return InstrumentType.stock;
    }
  }

  MarketData _marketDataFromMap(Map<String, dynamic> map) => MarketData(
    currentPrice: map['currentPrice']?.toDouble() ?? 0.0,
    dayChange: map['dayChange']?.toDouble() ?? 0.0,
    dayChangePercentage: map['dayChangePercentage']?.toDouble() ?? 0.0,
    volume: map['volume']?.toDouble() ?? 0.0,
    marketCap: map['marketCap']?.toDouble() ?? 0.0,
    lastUpdated:
        DateTime.tryParse(map['lastUpdated']?.toString() ?? '') ??
        DateTime.now(),
  );

  FundamentalData? _fundamentalDataFromMap(Map<String, dynamic> map) =>
      FundamentalData(
        peRatio: map['peRatio']?.toDouble(),
        pbRatio: map['pbRatio']?.toDouble(),
        dividendYield: map['dividendYield']?.toDouble(),
        epsGrowth: map['epsGrowth']?.toDouble(),
        debtToEquity: map['debtToEquity']?.toDouble(),
      );

  List<ExecutionDetail> _executionDetailsFromMap(Map<String, dynamic> map) {
    final executionList = map['executions'] as List<dynamic>? ?? [];
    return executionList
        .cast<Map<String, dynamic>>()
        .map(_executionDetailFromMap)
        .toList();
  }

  ExecutionDetail _executionDetailFromMap(Map<String, dynamic> map) =>
      ExecutionDetail(
        executionId: map['executionId']?.toString() ?? '',
        tradeId: map['tradeId']?.toString() ?? '',
        executionDate:
            DateTime.tryParse(map['executionDate']?.toString() ?? '') ??
            DateTime.now(),
        executionType: _getExecutionType(
          map['executionType']?.toString() ?? 'buy',
        ),
        quantity: map['quantity']?.toDouble() ?? 0.0,
        price: map['price']?.toDouble() ?? 0.0,
        commission: map['commission']?.toDouble() ?? 0.0,
        fees: map['fees']?.toDouble() ?? 0.0,
        venue: map['venue']?.toString() ?? '',
        executionMetadata: map['executionMetadata'] as Map<String, dynamic>?,
      );

  ExecutionType _getExecutionType(String type) {
    switch (type.toLowerCase()) {
      case 'buy':
        return ExecutionType.buy;
      case 'sell':
        return ExecutionType.sell;
      case 'partialfill':
        return ExecutionType.partialFill;
      case 'fullfill':
        return ExecutionType.fullFill;
      default:
        return ExecutionType.buy;
    }
  }

  // Trade Details Mapping
  List<TradeHolding> tradeDetailsFromDto(List<ApiTradeDetailsResponse> dtos) =>
      dtos.map(_tradeHoldingFromDetailsDto).toList();

  TradeHolding _tradeHoldingFromDetailsDto(ApiTradeDetailsResponse dto) =>
      TradeHolding(
        tradeId: dto.tradeId,
        portfolioId: dto.portfolioId,
        symbol: dto.basicInfo.symbol,
        instrumentName: dto.instrumentInfo.name,
        tradeType: _getTradeType(dto.basicInfo.tradeType),
        quantity: dto.basicInfo.totalQuantity,
        entryPrice: dto.basicInfo.averageEntryPrice,
        exitPrice: dto.basicInfo.averageExitPrice,
        entryDate: dto.basicInfo.openDate,
        exitDate: dto.basicInfo.closeDate,
        status: _getTradeStatus(dto.basicInfo.status),
        currentValue: _calculateCurrentValue(dto),
        unrealizedPnL:
            dto.performanceMetrics['unrealizedPnL']?.toDouble() ?? 0.0,
        realizedPnL: dto.performanceMetrics['realizedPnL']?.toDouble() ?? 0.0,
        instrumentDetails: _instrumentDetailsFromDto(dto.instrumentInfo),
        executionDetails: dto.executionDetails
            .map(_executionDetailFromDto)
            .toList(),
      );

  double _calculateCurrentValue(ApiTradeDetailsResponse dto) {
    final currentPrice =
        dto.instrumentInfo.marketData['currentPrice']?.toDouble() ??
        dto.basicInfo.averageEntryPrice;
    return dto.basicInfo.totalQuantity * currentPrice;
  }

  InstrumentDetails _instrumentDetailsFromDto(ApiInstrumentInfoDto dto) =>
      InstrumentDetails(
        symbol: dto.symbol,
        name: dto.name,
        sector: dto.sector,
        exchange: dto.exchange,
        currency: dto.currency,
        instrumentType: _getInstrumentType(dto.instrumentType),
        marketData: _marketDataFromMap(dto.marketData),
        fundamentalData: _fundamentalDataFromMap(dto.fundamentalData),
      );

  ExecutionDetail _executionDetailFromDto(ApiExecutionDetailDto dto) =>
      ExecutionDetail(
        executionId: dto.executionId,
        tradeId: dto.tradeId,
        executionDate: dto.executionDate,
        executionType: _getExecutionType(dto.executionType),
        quantity: dto.quantity,
        price: dto.price,
        commission: dto.commission,
        fees: dto.fees,
        venue: dto.venue,
        executionMetadata: dto.executionMetadata,
      );

  // Calendar Data Mapping
  CalendarData calendarDataFromDto(ApiCalendarResponse dto) => CalendarData(
    portfolioTrades: dto.portfolioTrades.map(
      (key, value) => MapEntry(key, value.map(_calendarTradeFromDto).toList()),
    ),
    startDate: dto.startDate,
    endDate: dto.endDate,
    viewType: _getCalendarViewType(dto.viewType),
    summary: _calendarSummaryFromMap(dto.summary),
  );

  CalendarTrade _calendarTradeFromDto(ApiCalendarTradeDto dto) => CalendarTrade(
    tradeId: dto.tradeId,
    date: dto.date,
    symbol: dto.symbol,
    type: _getTradeType(dto.type),
    quantity: dto.quantity,
    price: dto.price,
    status: _getTradeStatus(dto.status),
    metadata: dto.metadata,
  );

  CalendarViewType _getCalendarViewType(String viewType) {
    switch (viewType.toLowerCase()) {
      case 'month':
        return CalendarViewType.month;
      case 'day':
        return CalendarViewType.day;
      case 'quarter':
        return CalendarViewType.quarter;
      case 'financial-year':
        return CalendarViewType.financialYear;
      default:
        return CalendarViewType.month;
    }
  }

  CalendarSummary _calendarSummaryFromMap(Map<String, dynamic> map) =>
      CalendarSummary(
        totalTrades: map['totalTrades']?.toInt() ?? 0,
        totalVolume: map['totalVolume']?.toDouble() ?? 0.0,
        averageTradeSize: map['averageTradeSize']?.toDouble() ?? 0.0,
        tradingDays: map['tradingDays']?.toInt() ?? 0,
        dailyAverageVolume: map['dailyAverageVolume']?.toDouble() ?? 0.0,
      );
}
