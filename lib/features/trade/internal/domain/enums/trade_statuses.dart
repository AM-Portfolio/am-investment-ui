import 'package:json_annotation/json_annotation.dart';

/// Trade statuses for filtering
@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum TradeStatuses {
  open,
  closed,
  win,
  loss,
  breakeven,
  cancelled,
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
