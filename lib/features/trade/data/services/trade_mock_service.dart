import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/trade_portfolio.dart';
import '../models/trade_holding.dart';
import '../models/paginated_response.dart';
import '../models/calendar_data.dart';

class TradeMockService {
  Future<List<TradePortfolio>> getPortfoliosByOwner(String ownerId) async {
    final jsonString = await rootBundle.loadString(
      'lib/assets/mock_data/trade/trade_portfolio_list.json',
    );
    final List<dynamic> data = jsonDecode(jsonString);
    return data.map((json) => TradePortfolio.fromJson(json)).toList();
  }

  Future<TradePortfolio> getPortfolioSummary(String portfolioId) async {
    final jsonString = await rootBundle.loadString(
      'lib/assets/mock_data/trade/trade_portfolio_summary.json',
    );
    return TradePortfolio.fromJson(jsonDecode(jsonString));
  }

  Future<PaginatedResponse<TradeHolding>> getPortfolioHoldings(
    String portfolioId, {
    int page = 0,
    int size = 50,
    String? sort,
  }) async {
    final jsonString = await rootBundle.loadString(
      'lib/assets/mock_data/trade/holdings/trade_holdings.json',
    );
    final data = jsonDecode(jsonString) as Map<String, dynamic>;
    
    final content = (data['content'] as List<dynamic>)
        .map((json) => TradeHolding.fromJson(json))
        .toList();
    
    final start = page * size;
    final end = (start + size).clamp(0, content.length);
    final pagedContent = content.sublist(start, end);
    
    return PaginatedResponse(
      content: pagedContent,
      page: page,
      size: size,
      totalElements: content.length,
      totalPages: (content.length / size).ceil(),
      last: end >= content.length,
      first: page == 0,
    );
  }

  Future<List<TradeExecution>> getTradeDetailsByIds(List<String> tradeIds) async {
    final jsonString = await rootBundle.loadString(
      'lib/assets/mock_data/trade/details/trade_details_by_id.json',
    );
    final List<dynamic> data = jsonDecode(jsonString);
    return data.map((json) => TradeExecution.fromJson(json)).toList();
  }

  Future<CalendarData> getMonthlyCalendar(
    String portfolioId,
    int year,
    int month,
  ) async {
    final jsonString = await rootBundle.loadString(
      'lib/assets/mock_data/trade/calander/calender-response.json',
    );
    return CalendarData.fromJson(jsonDecode(jsonString));
  }

  Future<CalendarData> getDayCalendar(
    String portfolioId,
    DateTime date,
  ) async {
    return getMonthlyCalendar(portfolioId, date.year, date.month);
  }

  Future<CalendarData> getQuarterCalendar(
    String portfolioId,
    int year,
    int quarter,
  ) async {
    final jsonString = await rootBundle.loadString(
      'lib/assets/mock_data/trade/calander/calender-response.json',
    );
    return CalendarData.fromJson(jsonDecode(jsonString));
  }

  Future<CalendarData> getFinancialYearCalendar(
    String portfolioId,
    int financialYear,
  ) async {
    final jsonString = await rootBundle.loadString(
      'lib/assets/mock_data/trade/calander/calender-response.json',
    );
    return CalendarData.fromJson(jsonDecode(jsonString));
  }
}
