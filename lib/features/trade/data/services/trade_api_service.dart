import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/trade_portfolio.dart';
import '../models/trade_holding.dart';
import '../models/paginated_response.dart';
import '../models/calendar_data.dart';

class TradeApiService {
  final String baseUrl;
  final http.Client httpClient;

  const TradeApiService({
    required this.baseUrl,
    required this.httpClient,
  });

  Future<List<TradePortfolio>> getPortfoliosByOwner(String ownerId) async {
    final response = await httpClient.get(
      Uri.parse('$baseUrl/portfolio-summary/by-owner/$ownerId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => TradePortfolio.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load portfolios: ${response.statusCode}');
    }
  }

  Future<TradePortfolio> getPortfolioSummary(String portfolioId) async {
    final response = await httpClient.get(
      Uri.parse('$baseUrl/portfolio-summary/$portfolioId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return TradePortfolio.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load portfolio summary: ${response.statusCode}');
    }
  }

  Future<PaginatedResponse<TradeHolding>> getPortfolioHoldings(
    String portfolioId, {
    int page = 0,
    int size = 50,
    String? sort,
  }) async {
    final queryParams = {
      'page': page.toString(),
      'size': size.toString(),
      if (sort != null) 'sort': sort,
    };

    final uri = Uri.parse('$baseUrl/trades/portfolio-details/$portfolioId')
        .replace(queryParameters: queryParams);

    final response = await httpClient.get(
      uri,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return PaginatedResponse.fromJson(
        data,
        (json) => TradeHolding.fromJson(json as Map<String, dynamic>),
      );
    } else {
      throw Exception('Failed to load holdings: ${response.statusCode}');
    }
  }

  Future<List<TradeExecution>> getTradeDetailsByIds(List<String> tradeIds) async {
    final response = await httpClient.post(
      Uri.parse('$baseUrl/trades/details/by-ids'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(tradeIds),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => TradeExecution.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load trade details: ${response.statusCode}');
    }
  }

  Future<CalendarData> getMonthlyCalendar(
    String portfolioId,
    int year,
    int month,
  ) async {
    final queryParams = {
      'portfolioId': portfolioId,
      'year': year.toString(),
      'month': month.toString(),
    };

    final uri = Uri.parse('$baseUrl/trades/calendar/month')
        .replace(queryParameters: queryParams);

    final response = await httpClient.get(
      uri,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return CalendarData.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load calendar data: ${response.statusCode}');
    }
  }

  Future<CalendarData> getDayCalendar(
    String portfolioId,
    DateTime date,
  ) async {
    final queryParams = {
      'portfolioId': portfolioId,
      'date': '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
    };

    final uri = Uri.parse('$baseUrl/trades/calendar/day')
        .replace(queryParameters: queryParams);

    final response = await httpClient.get(
      uri,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return CalendarData.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load calendar data: ${response.statusCode}');
    }
  }

  Future<CalendarData> getQuarterCalendar(
    String portfolioId,
    int year,
    int quarter,
  ) async {
    final queryParams = {
      'portfolioId': portfolioId,
      'year': year.toString(),
      'quarter': quarter.toString(),
    };

    final uri = Uri.parse('$baseUrl/trades/calendar/quarter')
        .replace(queryParameters: queryParams);

    final response = await httpClient.get(
      uri,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return CalendarData.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load calendar data: ${response.statusCode}');
    }
  }

  Future<CalendarData> getFinancialYearCalendar(
    String portfolioId,
    int financialYear,
  ) async {
    final queryParams = {
      'portfolioId': portfolioId,
      'financialYear': financialYear.toString(),
    };

    final uri = Uri.parse('$baseUrl/trades/calendar/financial-year')
        .replace(queryParameters: queryParams);

    final response = await httpClient.get(
      uri,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return CalendarData.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load calendar data: ${response.statusCode}');
    }
  }
}
