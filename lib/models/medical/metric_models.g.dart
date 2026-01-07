// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'metric_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SelectableMetricDto _$SelectableMetricDtoFromJson(Map<String, dynamic> json) =>
    SelectableMetricDto(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      unit: json['unit'] as String?,
    );

Map<String, dynamic> _$SelectableMetricDtoToJson(
  SelectableMetricDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'unit': instance.unit,
};

ListSelectableMetricsResponse _$ListSelectableMetricsResponseFromJson(
  Map<String, dynamic> json,
) => ListSelectableMetricsResponse(
  metrics: (json['metrics'] as List<dynamic>)
      .map((e) => SelectableMetricDto.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$ListSelectableMetricsResponseToJson(
  ListSelectableMetricsResponse instance,
) => <String, dynamic>{'metrics': instance.metrics};
