import 'package:json_annotation/json_annotation.dart';

/// Fundamental analysis reasons for trade entry/exit
@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum FundamentalReasons { earningsBeat, sectorStrength, marketSentiment, newsCatalyst, valuation, growthProspects }

/// Extension for FundamentalReasons enum
extension FundamentalReasonsExtension on FundamentalReasons {
  String get displayName {
    switch (this) {
      case FundamentalReasons.earningsBeat:
        return 'Earnings Beat';
      case FundamentalReasons.sectorStrength:
        return 'Sector Strength';
      case FundamentalReasons.marketSentiment:
        return 'Market Sentiment';
      case FundamentalReasons.newsCatalyst:
        return 'News Catalyst';
      case FundamentalReasons.valuation:
        return 'Valuation';
      case FundamentalReasons.growthProspects:
        return 'Growth Prospects';
    }
  }
}
