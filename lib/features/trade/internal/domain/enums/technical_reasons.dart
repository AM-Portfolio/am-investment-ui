import 'package:json_annotation/json_annotation.dart';

/// Technical analysis reasons for trade entry/exit
@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum TechnicalReasons {
  breakout,
  supportBounce,
  resistanceBreak,
  trendFollowing,
  patternRecognition,
  indicatorSignal,
  movingAverageCross,
  rsiDivergence,
}

/// Extension for TechnicalReasons enum
extension TechnicalReasonsExtension on TechnicalReasons {
  String get displayName {
    switch (this) {
      case TechnicalReasons.breakout:
        return 'Breakout';
      case TechnicalReasons.supportBounce:
        return 'Support Bounce';
      case TechnicalReasons.resistanceBreak:
        return 'Resistance Break';
      case TechnicalReasons.trendFollowing:
        return 'Trend Following';
      case TechnicalReasons.patternRecognition:
        return 'Pattern Recognition';
      case TechnicalReasons.indicatorSignal:
        return 'Indicator Signal';
      case TechnicalReasons.movingAverageCross:
        return 'Moving Average Cross';
      case TechnicalReasons.rsiDivergence:
        return 'RSI Divergence';
    }
  }
}
