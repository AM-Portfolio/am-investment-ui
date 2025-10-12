import 'package:freezed_annotation/freezed_annotation.dart';

part 'trade_dtos.freezed.dart';
part 'trade_dtos.g.dart';

// Trade Portfolio Summary DTO (from trade_portfolio_summary.json)
@freezed
class ApiTradePortfolioSummaryResponse with _$ApiTradePortfolioSummaryResponse {
  const factory ApiTradePortfolioSummaryResponse({
    required String portfolioId,
    required String portfolioName,
    required String ownerId,
    required double totalValue,
    required double totalReturn,
    required double totalReturnPercentage,
    required int totalTrades,
    required int activeTrades,
    required Map<String, dynamic> performanceMetrics,
    required Map<String, dynamic> riskMetrics,
    required List<ApiAssetAllocationDto> assetAllocation,
    required DateTime lastUpdated,
  }) = _ApiTradePortfolioSummaryResponse;

  factory ApiTradePortfolioSummaryResponse.fromJson(
    Map<String, dynamic> json,
  ) => _$ApiTradePortfolioSummaryResponseFromJson(json);
}

// Asset Allocation DTO
@freezed
class ApiAssetAllocationDto with _$ApiAssetAllocationDto {
  const factory ApiAssetAllocationDto({
    required String name,
    required double value,
    required double percentage,
    required String category,
    String? color,
  }) = _ApiAssetAllocationDto;

  factory ApiAssetAllocationDto.fromJson(Map<String, dynamic> json) =>
      _$ApiAssetAllocationDtoFromJson(json);
}

// Trade Holdings Response DTO (from trade_holdings.json - 1796 lines)
@freezed
class ApiTradeHoldingsResponse with _$ApiTradeHoldingsResponse {
  const factory ApiTradeHoldingsResponse({
    required List<ApiTradeHoldingDto> trades,
    required int totalCount,
    required int currentPage,
    required bool hasMore,
    required Map<String, dynamic> pagination,
  }) = _ApiTradeHoldingsResponse;

  factory ApiTradeHoldingsResponse.fromJson(Map<String, dynamic> json) =>
      _$ApiTradeHoldingsResponseFromJson(json);
}

// Individual Trade Holding DTO
@freezed
class ApiTradeHoldingDto with _$ApiTradeHoldingDto {
  const factory ApiTradeHoldingDto({
    required String tradeId,
    required String portfolioId,
    required String symbol,
    required String instrumentName,
    required String tradeType, // BUY, SELL
    required double quantity,
    required double entryPrice,
    required DateTime entryDate,
    required String status,
    required double
    unrealizedPnL, // OPEN, CLOSED, PENDING, required double currentValue, required double unrealizedPnL, required double realizedPnL, required Map<String, dynamic> instrumentDetails, required Map<String, dynamic> executionDetails, double? exitPrice,
    DateTime? exitDate,
  }) = _ApiTradeHoldingDto;

  factory ApiTradeHoldingDto.fromJson(Map<String, dynamic> json) =>
      _$ApiTradeHoldingDtoFromJson(json);
}

// Trade Details DTO (from trade_details_by_id.json)
@freezed
class ApiTradeDetailsResponse with _$ApiTradeDetailsResponse {
  const factory ApiTradeDetailsResponse({
    required String tradeId,
    required String portfolioId,
    required ApiTradeBasicInfoDto basicInfo,
    required ApiInstrumentInfoDto instrumentInfo,
    required List<ApiExecutionDetailDto> executionDetails,
    required Map<String, dynamic> performanceMetrics,
    required Map<String, dynamic> riskAnalysis,
  }) = _ApiTradeDetailsResponse;

  factory ApiTradeDetailsResponse.fromJson(Map<String, dynamic> json) =>
      _$ApiTradeDetailsResponseFromJson(json);
}

// Trade Basic Info DTO
@freezed
class ApiTradeBasicInfoDto with _$ApiTradeBasicInfoDto {
  const factory ApiTradeBasicInfoDto({
    required String tradeId,
    required String symbol,
    required String tradeType,
    required String status,
    required DateTime openDate,
    required double totalQuantity,
    required double averageEntryPrice,
    DateTime? closeDate,
    double? averageExitPrice,
  }) = _ApiTradeBasicInfoDto;

  factory ApiTradeBasicInfoDto.fromJson(Map<String, dynamic> json) =>
      _$ApiTradeBasicInfoDtoFromJson(json);
}

// Instrument Information DTO
@freezed
class ApiInstrumentInfoDto with _$ApiInstrumentInfoDto {
  const factory ApiInstrumentInfoDto({
    required String symbol,
    required String name,
    required String sector,
    required String exchange,
    required String currency,
    required String instrumentType,
    required Map<String, dynamic> marketData,
    required Map<String, dynamic> fundamentalData,
  }) = _ApiInstrumentInfoDto;

  factory ApiInstrumentInfoDto.fromJson(Map<String, dynamic> json) =>
      _$ApiInstrumentInfoDtoFromJson(json);
}

// Execution Detail DTO
@freezed
class ApiExecutionDetailDto with _$ApiExecutionDetailDto {
  const factory ApiExecutionDetailDto({
    required String executionId,
    required String tradeId,
    required DateTime executionDate,
    required String executionType, // BUY, SELL, PARTIAL_FILL
    required double quantity,
    required double price,
    required double commission,
    required double fees,
    required String venue,
    required Map<String, dynamic> executionMetadata,
  }) = _ApiExecutionDetailDto;

  factory ApiExecutionDetailDto.fromJson(Map<String, dynamic> json) =>
      _$ApiExecutionDetailDtoFromJson(json);
}

// Calendar Response DTO (from calender-response.json - 887 lines)
@freezed
class ApiCalendarResponse with _$ApiCalendarResponse {
  const factory ApiCalendarResponse({
    required Map<String, List<ApiCalendarTradeDto>> portfolioTrades,
    required DateTime startDate,
    required DateTime endDate,
    required String viewType, // month, day, quarter, financial-year
    required Map<String, dynamic> summary,
  }) = _ApiCalendarResponse;

  factory ApiCalendarResponse.fromJson(Map<String, dynamic> json) =>
      _$ApiCalendarResponseFromJson(json);
}

// Calendar Trade DTO (simplified trade object for calendar)
@freezed
class ApiCalendarTradeDto with _$ApiCalendarTradeDto {
  const factory ApiCalendarTradeDto({
    required String tradeId,
    required DateTime date,
    required String symbol,
    required String type,
    required double quantity,
    required double price,
    required String status,
    Map<String, dynamic>? metadata,
  }) = _ApiCalendarTradeDto;

  factory ApiCalendarTradeDto.fromJson(Map<String, dynamic> json) =>
      _$ApiCalendarTradeDto.fromJson(json);
}

// Portfolio List Response DTO (for Step 1: Portfolio Discovery)
@freezed
class ApiPortfolioListResponse with _$ApiPortfolioListResponse {
  const factory ApiPortfolioListResponse({
    required List<ApiPortfolioSummaryDto> portfolios,
    required int totalCount,
    required String ownerId,
    required Map<String, dynamic> aggregateMetrics,
  }) = _ApiPortfolioListResponse;

  factory ApiPortfolioListResponse.fromJson(Map<String, dynamic> json) =>
      _$ApiPortfolioListResponseFromJson(json);
}

// Portfolio Summary DTO (for portfolio discovery)
@freezed
class ApiPortfolioSummaryDto with _$ApiPortfolioSummaryDto {
  const factory ApiPortfolioSummaryDto({
    required String portfolioId,
    required String portfolioName,
    required String description,
    required double totalValue,
    required double totalReturn,
    required double totalReturnPercentage,
    required int tradeCount,
    required DateTime lastTradeDate,
    required String riskLevel,
    required Map<String, dynamic> keyMetrics,
  }) = _ApiPortfolioSummaryDto;

  factory ApiPortfolioSummaryDto.fromJson(Map<String, dynamic> json) =>
      _$ApiPortfolioSummaryDtoFromJson(json);
}

// Request DTOs for POST endpoints
@freezed
class ApiTradeDetailsByIdsRequest with _$ApiTradeDetailsByIdsRequest {
  const factory ApiTradeDetailsByIdsRequest({
    required List<String> tradeIds,
    bool? includeExecutions,
    bool? includePerformanceMetrics,
  }) = _ApiTradeDetailsByIdsRequest;

  factory ApiTradeDetailsByIdsRequest.fromJson(Map<String, dynamic> json) =>
      _$ApiTradeDetailsByIdsRequestFromJson(json);
}

// Trade Portfolio Summary DTO (following portfolio DTO pattern)
@freezed
class ApiTradePortfolioSummaryDto with _$ApiTradePortfolioSummaryDto {
  const factory ApiTradePortfolioSummaryDto({
    required String portfolioId,
    required String portfolioName,
    required String ownerId,
    required double totalValue,
    required double totalReturn,
    required double totalReturnPercentage,
    required int totalTrades,
    required int activeTrades,
    required DateTime lastUpdated,
  }) = _ApiTradePortfolioSummaryDto;

  factory ApiTradePortfolioSummaryDto.fromJson(Map<String, dynamic> json) =>
      _$ApiTradePortfolioSummaryDtoFromJson(json);
}

// Trade Holdings DTO (following portfolio holdings pattern)
@freezed
class ApiTradeHoldingDto with _$ApiTradeHoldingDto {
  const factory ApiTradeHoldingDto({
    required String tradeId,
    required String portfolioId,
    required String symbol,
    required String instrumentName,
    required String tradeType,
    required double quantity,
    required double entryPrice,
    double? exitPrice,
    required DateTime entryDate,
    DateTime? exitDate,
    required String status,
    required double currentValue,
    required double unrealizedPnL,
    required double realizedPnL,
  }) = _ApiTradeHoldingDto;

  factory ApiTradeHoldingDto.fromJson(Map<String, dynamic> json) =>
      _$ApiTradeHoldingDtoFromJson(json);
}
