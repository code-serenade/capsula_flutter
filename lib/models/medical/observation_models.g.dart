// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'observation_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MetricDto _$MetricDtoFromJson(Map<String, dynamic> json) => MetricDto(
  id: (json['id'] as num).toInt(),
  code: json['metric_code'] as String,
  name: json['metric_name'] as String,
  visualization: json['visualization'] as String,
  valueType: json['value_type'] as String?,
  unit: json['unit'] as String?,
);

Map<String, dynamic> _$MetricDtoToJson(MetricDto instance) => <String, dynamic>{
  'id': instance.id,
  'metric_code': instance.code,
  'metric_name': instance.name,
  'visualization': instance.visualization,
  'value_type': instance.valueType,
  'unit': instance.unit,
};

ObservationPointDto _$ObservationPointDtoFromJson(Map<String, dynamic> json) =>
    ObservationPointDto(
      value: json['value'] as String,
      valueNum: (json['value_num'] as num?)?.toDouble(),
      observedAt: DateTime.parse(json['observed_at'] as String),
    );

Map<String, dynamic> _$ObservationPointDtoToJson(
  ObservationPointDto instance,
) => <String, dynamic>{
  'value': instance.value,
  'value_num': instance.valueNum,
  'observed_at': instance.observedAt.toIso8601String(),
};

QueryObservationResponse _$QueryObservationResponseFromJson(
  Map<String, dynamic> json,
) => QueryObservationResponse(
  subjectId: (json['subject_id'] as num).toInt(),
  metric: MetricDto.fromJson(json['metric'] as Map<String, dynamic>),
  points: (json['points'] as List<dynamic>)
      .map((e) => ObservationPointDto.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$QueryObservationResponseToJson(
  QueryObservationResponse instance,
) => <String, dynamic>{
  'subject_id': instance.subjectId,
  'metric': instance.metric,
  'points': instance.points,
};
