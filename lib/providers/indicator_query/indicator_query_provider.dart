import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:capsula_flutter/api/medical.dart';
import 'package:capsula_flutter/models/medical/metric_models.dart';
import 'package:capsula_flutter/models/medical/observation_models.dart';

part 'indicator_query_provider.g.dart';

@riverpod
Future<List<SelectableMetricDto>> selectableMetrics(Ref ref) async {
  final response = await listSelectableMetrics();
  return response.metrics;
}

@immutable
class IndicatorQueryFormState {
  const IndicatorQueryFormState({
    this.subjectId = '',
    this.metricId = '',
    this.dateRange,
  });

  final String subjectId;
  final String metricId;
  final DateTimeRange? dateRange;

  IndicatorQueryFormState copyWith({
    String? subjectId,
    String? metricId,
    DateTimeRange? dateRange,
    bool clearDateRange = false,
  }) {
    return IndicatorQueryFormState(
      subjectId: subjectId ?? this.subjectId,
      metricId: metricId ?? this.metricId,
      dateRange: clearDateRange ? null : (dateRange ?? this.dateRange),
    );
  }
}

@immutable
class IndicatorQueryRequest {
  const IndicatorQueryRequest({
    required this.subjectId,
    required this.metricId,
    this.startAt,
    this.endAt,
  });

  final int subjectId;
  final int metricId;
  final DateTime? startAt;
  final DateTime? endAt;
}

@riverpod
class IndicatorQueryForm extends _$IndicatorQueryForm {
  @override
  IndicatorQueryFormState build() => const IndicatorQueryFormState();

  void setSubjectId(String value) {
    state = state.copyWith(subjectId: value);
  }

  void setMetricId(String value) {
    state = state.copyWith(metricId: value);
  }

  void setDateRange(DateTimeRange? range) {
    state = state.copyWith(dateRange: range, clearDateRange: range == null);
  }

  void reset() {
    state = const IndicatorQueryFormState();
  }
}

@riverpod
class IndicatorQueryApplied extends _$IndicatorQueryApplied {
  @override
  IndicatorQueryRequest? build() => null;

  void apply(IndicatorQueryRequest value) {
    state = value;
  }

  void reset() {
    state = null;
  }
}

@riverpod
class IndicatorQueryResults extends _$IndicatorQueryResults {
  @override
  Future<QueryObservationResponse?> build() async {
    final request = ref.watch(indicatorQueryAppliedProvider);
    if (request == null) {
      return null;
    }

    return queryObservations(
      subjectId: request.subjectId,
      metricId: request.metricId,
      startAt: request.startAt,
      endAt: request.endAt,
    );
  }

  Future<void> refresh() async {
    final request = ref.read(indicatorQueryAppliedProvider);
    if (request == null) {
      state = const AsyncData(null);
      return;
    }

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      return queryObservations(
        subjectId: request.subjectId,
        metricId: request.metricId,
        startAt: request.startAt,
        endAt: request.endAt,
      );
    });
  }
}
