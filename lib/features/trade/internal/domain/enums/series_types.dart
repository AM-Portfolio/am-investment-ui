import 'package:json_annotation/json_annotation.dart';

/// Series types for equity instruments
@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum SeriesTypes { eq, be, bz, sm, st }

/// Extension for SeriesTypes enum
extension SeriesTypesExtension on SeriesTypes {
  String get displayName {
    switch (this) {
      case SeriesTypes.eq:
        return 'EQ - Equity';
      case SeriesTypes.be:
        return 'BE - Book Entry';
      case SeriesTypes.bz:
        return 'BZ - B Series';
      case SeriesTypes.sm:
        return 'SM - SME';
      case SeriesTypes.st:
        return 'ST - Spot Trade';
    }
  }
}
