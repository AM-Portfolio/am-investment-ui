import 'package:json_annotation/json_annotation.dart';

/// Market segments for trade filtering
@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum MarketSegments { equity, indexSegment, equityFutures, indexFutures, equityOptions, indexOptions }

/// Extension for MarketSegments enum
extension MarketSegmentsExtension on MarketSegments {
  String get displayName {
    switch (this) {
      case MarketSegments.equity:
        return 'Equity';
      case MarketSegments.indexSegment:
        return 'Index';
      case MarketSegments.equityFutures:
        return 'Equity Futures';
      case MarketSegments.indexFutures:
        return 'Index Futures';
      case MarketSegments.equityOptions:
        return 'Equity Options';
      case MarketSegments.indexOptions:
        return 'Index Options';
    }
  }
}
