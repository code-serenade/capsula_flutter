import 'package:capsula_flutter/models/medical/observation_models.dart';

class ObservationChartPoint {
  const ObservationChartPoint({required this.time, required this.value});

  final DateTime time;
  final double value;
}

class ObservationChartSeries {
  const ObservationChartSeries({
    required this.points,
    required this.minValue,
    required this.maxValue,
    required this.minTime,
    required this.maxTime,
  });

  final List<ObservationChartPoint> points;
  final double minValue;
  final double maxValue;
  final DateTime minTime;
  final DateTime maxTime;

  bool get isEmpty => points.isEmpty;
}

class ObservationChartMapper {
  const ObservationChartMapper();

  ObservationChartSeries? tryMap(List<ObservationPointDto> points) {
    final numericPoints = <ObservationChartPoint>[];

    for (final point in points) {
      final valueNum = point.valueNum;
      if (valueNum == null) {
        continue;
      }

      numericPoints.add(
        ObservationChartPoint(time: point.observedAt, value: valueNum),
      );
    }

    if (numericPoints.isEmpty) {
      return null;
    }

    numericPoints.sort((a, b) => a.time.compareTo(b.time));

    var minValue = numericPoints.first.value;
    var maxValue = numericPoints.first.value;
    var minTime = numericPoints.first.time;
    var maxTime = numericPoints.first.time;

    for (final point in numericPoints) {
      if (point.value < minValue) {
        minValue = point.value;
      }
      if (point.value > maxValue) {
        maxValue = point.value;
      }
      if (point.time.isBefore(minTime)) {
        minTime = point.time;
      }
      if (point.time.isAfter(maxTime)) {
        maxTime = point.time;
      }
    }

    return ObservationChartSeries(
      points: List.unmodifiable(numericPoints),
      minValue: minValue,
      maxValue: maxValue,
      minTime: minTime,
      maxTime: maxTime,
    );
  }
}
