import 'package:json_annotation/json_annotation.dart';

/// Entry psychology factors
@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum EntryPsychologyFactors {
  fearOfMissingOut,
  overconfidence,
  revengeTrading,
  greed,
  patience,
  discipline,
  calmAnalysis,
  emotionalControl,
}

/// Extension for EntryPsychologyFactors enum
extension EntryPsychologyFactorsExtension on EntryPsychologyFactors {
  String get displayName {
    switch (this) {
      case EntryPsychologyFactors.fearOfMissingOut:
        return 'Fear of Missing Out';
      case EntryPsychologyFactors.overconfidence:
        return 'Overconfidence';
      case EntryPsychologyFactors.revengeTrading:
        return 'Revenge Trading';
      case EntryPsychologyFactors.greed:
        return 'Greed';
      case EntryPsychologyFactors.patience:
        return 'Patience';
      case EntryPsychologyFactors.discipline:
        return 'Discipline';
      case EntryPsychologyFactors.calmAnalysis:
        return 'Calm Analysis';
      case EntryPsychologyFactors.emotionalControl:
        return 'Emotional Control';
    }
  }
}

/// Exit psychology factors
@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum ExitPsychologyFactors {
  fear,
  greed,
  panic,
  targetAchieved,
  stopLossHit,
  planFollowed,
  emotionalExit,
  rationalExit,
}

/// Extension for ExitPsychologyFactors enum
extension ExitPsychologyFactorsExtension on ExitPsychologyFactors {
  String get displayName {
    switch (this) {
      case ExitPsychologyFactors.fear:
        return 'Fear';
      case ExitPsychologyFactors.greed:
        return 'Greed';
      case ExitPsychologyFactors.panic:
        return 'Panic';
      case ExitPsychologyFactors.targetAchieved:
        return 'Target Achieved';
      case ExitPsychologyFactors.stopLossHit:
        return 'Stop Loss Hit';
      case ExitPsychologyFactors.planFollowed:
        return 'Plan Followed';
      case ExitPsychologyFactors.emotionalExit:
        return 'Emotional Exit';
      case ExitPsychologyFactors.rationalExit:
        return 'Rational Exit';
    }
  }
}

/// Behavior patterns
@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum BehaviorPatterns { overtrading, lossAversion, confirmationBias, disciplinedTrading, planAdherence, ruleFollowing }

/// Extension for BehaviorPatterns enum
extension BehaviorPatternsExtension on BehaviorPatterns {
  String get displayName {
    switch (this) {
      case BehaviorPatterns.overtrading:
        return 'Overtrading';
      case BehaviorPatterns.lossAversion:
        return 'Loss Aversion';
      case BehaviorPatterns.confirmationBias:
        return 'Confirmation Bias';
      case BehaviorPatterns.disciplinedTrading:
        return 'Disciplined Trading';
      case BehaviorPatterns.planAdherence:
        return 'Plan Adherence';
      case BehaviorPatterns.ruleFollowing:
        return 'Rule Following';
    }
  }
}
