import 'package:capsula_flutter/models/medical/observation_models.dart';
import 'package:capsula_flutter/services/http/api_service.dart';

Future<QueryObservationResponse> queryObservations({
  required int subjectId,
  required int metricId,
  DateTime? startAt,
  DateTime? endAt,
}) async {
  final response = await httpClient.get(
    '/medical/observations',
    queryParameters: {
      'subject_id': subjectId,
      'metric_id': metricId,
      if (startAt != null) 'start_at': startAt.toUtc().toIso8601String(),
      if (endAt != null) 'end_at': endAt.toUtc().toIso8601String(),
    },
  );

  final body = response.data;
  if (body is! Map) {
    throw const FormatException('Invalid response payload');
  }

  final envelope = Map<String, dynamic>.from(body);
  final code = envelope['code'];
  if (code != 0) {
    throw Exception(envelope['message']?.toString() ?? 'Request failed');
  }

  final data = envelope['data'];
  if (data is! Map) {
    throw const FormatException('Invalid response data payload');
  }

  return QueryObservationResponse.fromJson(Map<String, dynamic>.from(data));
}

