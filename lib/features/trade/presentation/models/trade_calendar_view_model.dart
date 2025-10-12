import '../../internal/domain/entities/trade_calendar.dart';
import '../../internal/domain/entities/trade_holding.dart';

/// View model for trade calendar event presentation
class TradeCalendarEventViewModel {
  const TradeCalendarEventViewModel({
    required this.id,
    required this.title,
    required this.date,
    required this.type,
    this.description,
    this.symbol,
    this.amount,
    this.status,
    this.profitLoss,
    this.profitLossPercentage,
  });

  final String id;
  final String title;
  final DateTime date;
  final String type;
  final String? description;
  final String? symbol;
  final double? amount;
  final String? status;
  final double? profitLoss;
  final double? profitLossPercentage;

  /// Computed properties
  String get displayDate => '${date.month}/${date.day}/${date.year}';
  String get displayAmount => amount != null ? '\$${amount!.toStringAsFixed(2)}' : 'N/A';
  String get displayProfitLoss => profitLoss != null ? '\$${profitLoss!.toStringAsFixed(2)}' : 'N/A';
  bool get isProfit => (profitLoss ?? 0) >= 0;

  /// Factory from domain entity
  factory TradeCalendarEventViewModel.fromEntity(TradeCalendarEvent entity) {
    // Generate title from available data
    String title = entity.symbol ?? 'Trade Event';
    if (entity.status != null) {
      title = '$title - ${entity.status}';
    }

    // Generate type from status or default
    String type = entity.status ?? 'TRADE';

    // Generate description
    String? description;
    if (entity.profitLoss != null && entity.profitLossPercentage != null) {
      description = 'P&L: \$${entity.profitLoss!.toStringAsFixed(2)} (${entity.profitLossPercentage!.toStringAsFixed(2)}%)';
    }

    return TradeCalendarEventViewModel(
      id: entity.tradeId,
      title: title,
      date: entity.tradeDate,
      type: type,
      description: description,
      symbol: entity.symbol,
      amount: entity.profitLoss,
      status: entity.status,
      profitLoss: entity.profitLoss,
      profitLossPercentage: entity.profitLossPercentage,
    );
  }

  /// Convert from TradeHolding to calendar event (for calendar view)
  factory TradeCalendarEventViewModel.fromTradeHolding(TradeHolding holding) {
    final instrument = holding.instrumentInfo;
    final metrics = holding.metrics;
    
    String title = instrument?.symbol ?? 'Trade';
    if (holding.status != null) {
      title = '$title - ${holding.status}';
    }

    String? description;
    if (metrics?.profitLoss != null && metrics?.profitLossPercentage != null) {
      description = 'P&L: \$${metrics!.profitLoss!.toStringAsFixed(2)} (${metrics.profitLossPercentage!.toStringAsFixed(2)}%)';
    }

    return TradeCalendarEventViewModel(
      id: holding.tradeId,
      title: title,
      date: holding.tradeDate ?? holding.tradeEndDate ?? DateTime.now(),
      type: holding.status ?? 'TRADE',
      description: description,
      symbol: instrument?.symbol,
      amount: metrics?.profitLoss,
      status: holding.status,
      profitLoss: metrics?.profitLoss,
      profitLossPercentage: metrics?.profitLossPercentage,
    );
  }

  static List<TradeCalendarEventViewModel> fromEntityList(
      List<TradeCalendarEvent> entities) {
    return entities.map((e) => TradeCalendarEventViewModel.fromEntity(e)).toList();
  }

  static List<TradeCalendarEventViewModel> fromTradeHoldingList(
      List<TradeHolding> holdings) {
    return holdings.map((h) => TradeCalendarEventViewModel.fromTradeHolding(h)).toList();
  }
}

/// View model for trade calendar
class TradeCalendarViewModel {
  const TradeCalendarViewModel({
    required this.userId,
    required this.portfolioId,
    required this.events,
    this.totalEvents = 0,
    this.startDate,
    this.endDate,
  });

  final String userId;
  final String portfolioId;
  final List<TradeCalendarEventViewModel> events;
  final int totalEvents;
  final DateTime? startDate;
  final DateTime? endDate;

  /// Computed properties
  int get displayCount => events.length;
  String get displayDateRange {
    if (startDate != null && endDate != null) {
      return '${startDate!.month}/${startDate!.day} - ${endDate!.month}/${endDate!.day}';
    }
    return 'All Time';
  }

  /// Factory from domain entity
  factory TradeCalendarViewModel.fromEntity(TradeCalendar entity) {
    // Combine events from both sources
    final allEvents = <TradeCalendarEventViewModel>[];
    
    // Add events from events list
    allEvents.addAll(TradeCalendarEventViewModel.fromEntityList(entity.events));
    
    // Add events from tradesByPortfolio map
    entity.tradesByPortfolio.forEach((portfolioId, holdings) {
      allEvents.addAll(
        TradeCalendarEventViewModel.fromTradeHoldingList(holdings),
      );
    });

    return TradeCalendarViewModel(
      userId: entity.userId,
      portfolioId: entity.portfolioId,
      events: allEvents,
      totalEvents: allEvents.length,
      startDate: entity.startDate,
      endDate: entity.endDate,
    );
  }

  /// Empty state
  factory TradeCalendarViewModel.empty(String userId, String portfolioId) {
    return TradeCalendarViewModel(
      userId: userId,
      portfolioId: portfolioId,
      events: [],
    );
  }
}
