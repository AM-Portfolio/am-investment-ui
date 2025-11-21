import 'package:json_annotation/json_annotation.dart';

/// Trade statuses for filtering
enum TradeStatuses {
  @JsonValue('OPEN')
  open,
  @JsonValue('CLOSED')
  closed,
  @JsonValue('WIN')
  win,
  @JsonValue('LOSS')
  loss,
  @JsonValue('BREAKEVEN')
  breakeven,
  @JsonValue('CANCELLED')
  cancelled,
}

/// Custom converter for TradeStatuses to handle both BREAKEVEN and BREAK_EVEN
class TradeStatusesConverter implements JsonConverter<TradeStatuses, String> {
  const TradeStatusesConverter();

  @override
  TradeStatuses fromJson(String json) {
    // Handle both BREAK_EVEN and BREAKEVEN formats
    final normalized = json.replaceAll('_', '');
    switch (normalized.toUpperCase()) {
      case 'OPEN':
        return TradeStatuses.open;
      case 'CLOSED':
        return TradeStatuses.closed;
      case 'WIN':
        return TradeStatuses.win;
      case 'LOSS':
        return TradeStatuses.loss;
      case 'BREAKEVEN':
        return TradeStatuses.breakeven;
      case 'CANCELLED':
        return TradeStatuses.cancelled;
      default:
        throw ArgumentError('Invalid TradeStatuses value: $json');
    }
  }

  @override
  String toJson(TradeStatuses status) {
    switch (status) {
      case TradeStatuses.open:
        return 'OPEN';
      case TradeStatuses.closed:
        return 'CLOSED';
      case TradeStatuses.win:
        return 'WIN';
      case TradeStatuses.loss:
        return 'LOSS';
      case TradeStatuses.breakeven:
        return 'BREAKEVEN';
      case TradeStatuses.cancelled:
        return 'CANCELLED';
    }
  }
}

/// Extension for TradeStatuses enum
extension TradeStatusesExtension on TradeStatuses {
  String get displayName {
    switch (this) {
      case TradeStatuses.open:
        return 'Open';
      case TradeStatuses.closed:
        return 'Closed';
      case TradeStatuses.win:
        return 'Win';
      case TradeStatuses.loss:
        return 'Loss';
      case TradeStatuses.breakeven:
        return 'Breakeven';
      case TradeStatuses.cancelled:
        return 'Cancelled';
    }
  }
}
