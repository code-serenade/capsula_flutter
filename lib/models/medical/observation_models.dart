import 'package:json_annotation/json_annotation.dart';

part 'observation_models.g.dart';

@JsonSerializable()
class MetricDto {
  const MetricDto({
    required this.id,
    required this.code,
    required this.name,
    this.unit,
  });

  final int id;
  final String code;
  final String name;
  final String? unit;

  factory MetricDto.fromJson(Map<String, dynamic> json) =>
      _$MetricDtoFromJson(json);
  Map<String, dynamic> toJson() => _$MetricDtoToJson(this);
}

@JsonSerializable()
class ObservationPointDto {
  const ObservationPointDto({
    required this.value,
    this.valueNum,
    required this.observedAt,
  });

  final String value;

  @JsonKey(name: 'value_num')
  final double? valueNum;

  @JsonKey(name: 'observed_at')
  final DateTime observedAt;

  factory ObservationPointDto.fromJson(Map<String, dynamic> json) =>
      _$ObservationPointDtoFromJson(json);
  Map<String, dynamic> toJson() => _$ObservationPointDtoToJson(this);
}

@JsonSerializable()
class QueryObservationResponse {
  const QueryObservationResponse({
    required this.subjectId,
    required this.metric,
    required this.points,
  });

  @JsonKey(name: 'subject_id')
  final int subjectId;

  final MetricDto metric;
  final List<ObservationPointDto> points;

  factory QueryObservationResponse.fromJson(Map<String, dynamic> json) =>
      _$QueryObservationResponseFromJson(json);
  Map<String, dynamic> toJson() => _$QueryObservationResponseToJson(this);
}
