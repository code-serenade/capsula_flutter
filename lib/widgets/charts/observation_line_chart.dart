import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:capsula_flutter/services/chart/observation_chart_mapper.dart';

class ObservationLineChart extends StatelessWidget {
  const ObservationLineChart({
    super.key,
    required this.series,
    this.height = 220,
  });

  final ObservationChartSeries series;
  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _ObservationLineChartPainter(
          series: series,
          lineColor: theme.colorScheme.primary,
          gridColor: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
    );
  }
}

class _ObservationLineChartPainter extends CustomPainter {
  _ObservationLineChartPainter({
    required this.series,
    required this.lineColor,
    required this.gridColor,
  });

  final ObservationChartSeries series;
  final Color lineColor;
  final Color gridColor;

  static const _padding = EdgeInsets.fromLTRB(12, 12, 12, 16);

  @override
  void paint(Canvas canvas, Size size) {
    if (series.points.isEmpty) {
      return;
    }

    final chartRect = Rect.fromLTWH(
      _padding.left,
      _padding.top,
      math.max(0, size.width - _padding.left - _padding.right),
      math.max(0, size.height - _padding.top - _padding.bottom),
    );

    if (chartRect.width <= 0 || chartRect.height <= 0) {
      return;
    }

    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;

    for (var i = 0; i <= 3; i++) {
      final y = chartRect.top + chartRect.height * (i / 3);
      canvas.drawLine(
        Offset(chartRect.left, y),
        Offset(chartRect.right, y),
        gridPaint,
      );
    }

    final points = series.points;
    final minMs = series.minTime.millisecondsSinceEpoch;
    final maxMs = series.maxTime.millisecondsSinceEpoch;
    final xRange = math.max(1, maxMs - minMs);

    var yMin = series.minValue;
    var yMax = series.maxValue;

    if (yMin == yMax) {
      yMin -= 1;
      yMax += 1;
    } else {
      final padding = (yMax - yMin) * 0.1;
      yMin -= padding;
      yMax += padding;
    }

    double xToCanvas(DateTime time) {
      final ms = time.millisecondsSinceEpoch;
      final t = (ms - minMs) / xRange;
      return chartRect.left + t * chartRect.width;
    }

    double yToCanvas(double value) {
      final t = (value - yMin) / (yMax - yMin);
      return chartRect.bottom - t * chartRect.height;
    }

    final path = Path();

    for (var i = 0; i < points.length; i++) {
      final point = points[i];
      final x = xToCanvas(point.time);
      final y = yToCanvas(point.value);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    final linePaint = Paint()
      ..color = lineColor.withValues(alpha: 0.85)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, linePaint);

    final pointPaint = Paint()
      ..color = lineColor.withValues(alpha: 0.95)
      ..style = PaintingStyle.fill;

    for (final point in points) {
      final x = xToCanvas(point.time);
      final y = yToCanvas(point.value);
      canvas.drawCircle(Offset(x, y), 3, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ObservationLineChartPainter oldDelegate) {
    return oldDelegate.series != series ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.gridColor != gridColor;
  }
}
