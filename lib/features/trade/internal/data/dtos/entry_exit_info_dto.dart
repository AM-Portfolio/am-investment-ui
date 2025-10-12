import 'package:freezed_annotation/freezed_annotation.dart';

part 'entry_exit_info_dto.freezed.dart';
part 'entry_exit_info_dto.g.dart';

@freezed
class EntryExitInfoDto with _$EntryExitInfoDto {
  const factory EntryExitInfoDto({
    String? timestamp,
    double? price,
    int? quantity,
    double? totalValue,
    @Default(0) double fees,
  }) = _EntryExitInfoDto;

  factory EntryExitInfoDto.fromJson(Map<String, dynamic> json) =>
      _$EntryExitInfoDtoFromJson(json);
}
