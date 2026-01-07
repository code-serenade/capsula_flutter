import 'package:json_annotation/json_annotation.dart';

part 'metric_models.g.dart';

@JsonSerializable()
class SelectableMetricDto {
  const SelectableMetricDto({required this.id, required this.name, this.unit});

  final int id;
  final String name;
  final String? unit;

  factory SelectableMetricDto.fromJson(Map<String, dynamic> json) =>
      _$SelectableMetricDtoFromJson(json);
  Map<String, dynamic> toJson() => _$SelectableMetricDtoToJson(this);
}

@JsonSerializable()
class ListSelectableMetricsResponse {
  const ListSelectableMetricsResponse({required this.metrics});

  final List<SelectableMetricDto> metrics;

  factory ListSelectableMetricsResponse.fromJson(Map<String, dynamic> json) =>
      _$ListSelectableMetricsResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ListSelectableMetricsResponseToJson(this);
}
