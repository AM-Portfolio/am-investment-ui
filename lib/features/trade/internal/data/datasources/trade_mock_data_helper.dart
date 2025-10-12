import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../../../../../core/utils/logger.dart';
import '../dtos/trade_portfolio_dto.dart';
import '../dtos/trade_holding_dto.dart';
import '../dtos/trade_summary_dto.dart';
import '../dtos/trade_calendar_dto.dart';

/// Helper class to load mock trade data from JSON files
class TradeMockDataHelper {
  /// Get mock trade portfolios from JSON file
  static Future<TradePortfolioListDto> getMockTradePortfolios() async {
    try {
      AppLogger.info(
        'Loading mock trade portfolios from assets',
        tag: 'TradeMockDataHelper',
      );

      final jsonString = await rootBundle.loadString(
        'lib/assets/mock_data/trade/trade_portfolios.json',
      );
      final jsonData = json.decode(jsonString) as Map<String, dynamic>;

      return TradePortfolioListDto.fromJson(jsonData);
    } catch (e) {
      AppLogger.error(
        'Failed to load mock trade portfolios',
        tag: 'TradeMockDataHelper',
        error: e,
      );
      rethrow;
    }
  }

  /// Get mock trade holdings from JSON file
  static Future<TradeHoldingsDto> getMockTradeHoldings() async {
    try {
      AppLogger.info(
        'Loading mock trade holdings from assets',
        tag: 'TradeMockDataHelper',
      );

      final jsonString = await rootBundle.loadString(
        'lib/assets/mock_data/trade/trade_holdings.json',
      );
      final jsonData = json.decode(jsonString) as Map<String, dynamic>;

      return TradeHoldingsDto.fromJson(jsonData);
    } catch (e) {
      AppLogger.error(
        'Failed to load mock trade holdings',
        tag: 'TradeMockDataHelper',
        error: e,
      );
      rethrow;
    }
  }

  /// Get mock trade summary from JSON file
  static Future<TradeSummaryDto> getMockTradeSummary() async {
    try {
      AppLogger.info(
        'Loading mock trade summary from assets',
        tag: 'TradeMockDataHelper',
      );

      final jsonString = await rootBundle.loadString(
        'lib/assets/mock_data/trade/trade_summary.json',
      );
      final jsonData = json.decode(jsonString) as Map<String, dynamic>;

      return TradeSummaryDto.fromJson(jsonData);
    } catch (e) {
      AppLogger.error(
        'Failed to load mock trade summary',
        tag: 'TradeMockDataHelper',
        error: e,
      );
      rethrow;
    }
  }

  /// Get mock trade calendar from JSON file
  static Future<TradeCalendarDto> getMockTradeCalendar() async {
    try {
      AppLogger.info(
        'Loading mock trade calendar from assets',
        tag: 'TradeMockDataHelper',
      );

      final jsonString = await rootBundle.loadString(
        'lib/assets/mock_data/trade/trade_calendar.json',
      );
      final jsonData = json.decode(jsonString) as Map<String, dynamic>;

      return TradeCalendarDto.fromJson(jsonData);
    } catch (e) {
      AppLogger.error(
        'Failed to load mock trade calendar',
        tag: 'TradeMockDataHelper',
        error: e,
      );
      rethrow;
    }
  }
}
