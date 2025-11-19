import 'package:json_annotation/json_annotation.dart';

/// Trade directions for filtering
@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum TradeDirections { long, short }

/// Extension for TradeDirections enum
extension TradeDirectionsExtension on TradeDirections {
  String get displayName {
    switch (this) {
      case TradeDirections.long:
        return 'Long';
      case TradeDirections.short:
        return 'Short';
    }
  }
}
