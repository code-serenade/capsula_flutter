import 'dart:async';

import 'package:capsula_flutter/models/medical/observation_models.dart';
import 'package:capsula_flutter/models/medical/metric_models.dart';
import 'package:capsula_flutter/models/medical/markdown_models.dart';
import 'package:capsula_flutter/services/http/api_service.dart';

Future<QueryObservationResponse> queryObservations({
  required int subjectId,
  required int metricId,
  DateTime? startAt,
  DateTime? endAt,
}) async {
  final response = await httpClient
      .get(
        '/medical/observations',
        queryParameters: {
          'subject_id': subjectId,
          'metric_id': metricId,
          if (startAt != null) 'start_at': startAt.toUtc().toIso8601String(),
          if (endAt != null) 'end_at': endAt.toUtc().toIso8601String(),
        },
      )
      .timeout(
        const Duration(seconds: 12),
        onTimeout: () => throw Exception('连接超时，请重试'),
      );

  final body = response.data;
  if (body is! Map) {
    throw const FormatException('Invalid response payload');
  }

  return QueryObservationResponse.fromJson(Map<String, dynamic>.from(body));
}

Future<ListSelectableMetricsResponse> listSelectableMetrics() async {
  final response = await httpClient
      .get('/medical/metrics/selectable')
      .timeout(
        const Duration(seconds: 12),
        onTimeout: () => throw Exception('连接超时，请重试'),
      );

  final body = response.data;
  if (body is! Map) {
    throw const FormatException('Invalid response payload');
  }

  return ListSelectableMetricsResponse.fromJson(
    Map<String, dynamic>.from(body),
  );
}

Future<UploadMarkdownTaskResponse> uploadMarkdownDataSource({
  required int subjectId,
  required String sourceType,
  required String sourceName,
  required String fileContent,
}) async {
  final response = await httpClient
      .post(
        '/medical/data-source/markdown',
        data: {
          'subject_id': subjectId,
          'source_type': sourceType,
          'source_name': sourceName,
          'file_content': fileContent,
        },
      )
      .timeout(
        const Duration(seconds: 12),
        onTimeout: () => throw Exception('连接超时，请重试'),
      );

  final body = response.data;
  if (body is! Map) {
    throw const FormatException('Invalid response payload');
  }

  return UploadMarkdownTaskResponse.fromJson(Map<String, dynamic>.from(body));
}

Future<MarkdownTaskStatusResponse> getMarkdownTaskStatus({
  required String taskId,
}) async {
  final response = await httpClient
      .get('/medical/data-source/markdown/tasks/$taskId')
      .timeout(
        const Duration(seconds: 12),
        onTimeout: () => throw Exception('连接超时，请重试'),
      );

  final body = response.data;
  if (body is! Map) {
    throw const FormatException('Invalid response payload');
  }

  return MarkdownTaskStatusResponse.fromJson(Map<String, dynamic>.from(body));
}
