import 'package:freezed_annotation/freezed_annotation.dart';

part 'instrument_info_dto.freezed.dart';
part 'instrument_info_dto.g.dart';

@freezed
class InstrumentInfoDto with _$InstrumentInfoDto {
  const factory InstrumentInfoDto({
    required String symbol,
    String? isin,
    String? rawSymbol,
    String? exchange,
    String? segment,
    String? series,
    String? description,
    String? baseSymbol,
    String? formattedDescription,
    @Default(false) bool derivative,
    @Default(false) bool index,
  }) = _InstrumentInfoDto;

  factory InstrumentInfoDto.fromJson(Map<String, dynamic> json) =>
      _$InstrumentInfoDtoFromJson(json);
}
