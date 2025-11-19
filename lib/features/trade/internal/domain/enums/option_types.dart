import 'package:json_annotation/json_annotation.dart';

/// Option types for derivatives
@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum OptionTypes { call, put }

/// Extension for OptionTypes enum
extension OptionTypesExtension on OptionTypes {
  String get displayName {
    switch (this) {
      case OptionTypes.call:
        return 'Call';
      case OptionTypes.put:
        return 'Put';
    }
  }
}
