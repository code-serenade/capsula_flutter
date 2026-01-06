import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:capsula_flutter/services/chart/observation_chart_mapper.dart';

class ObservationBarChart extends StatelessWidget {
  const ObservationBarChart({
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
        painter: _ObservationBarChartPainter(
          series: series,
          barColor: theme.colorScheme.primary,
          gridColor: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
    );
  }
}

class _ObservationBarChartPainter extends CustomPainter {
  _ObservationBarChartPainter({
    required this.series,
    required this.barColor,
    required this.gridColor,
  });

  final ObservationChartSeries series;
  final Color barColor;
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

    var yMin = series.minValue;
    var yMax = series.maxValue;
    if (yMin > 0) {
      yMin = 0;
    }
    if (yMax < 0) {
      yMax = 0;
    }

    if (yMin == yMax) {
      yMin -= 1;
      yMax += 1;
    }

    final count = series.points.length;
    final step = chartRect.width / count;
    final barWidth = math.max(1, step * 0.6);

    final barPaint = Paint()
      ..color = barColor.withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;

    double yToCanvas(double value) {
      final t = (value - yMin) / (yMax - yMin);
      return chartRect.bottom - t * chartRect.height;
    }

    final zeroY = yToCanvas(0);

    for (var i = 0; i < count; i++) {
      final point = series.points[i];
      final cx = chartRect.left + step * (i + 0.5);
      final left = cx - barWidth / 2;
      final right = cx + barWidth / 2;

      final y = yToCanvas(point.value);
      final top = math.min(y, zeroY);
      final bottom = math.max(y, zeroY);

      final rect = Rect.fromLTRB(left, top, right, bottom);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(4)),
        barPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ObservationBarChartPainter oldDelegate) {
    return oldDelegate.series != series ||
        oldDelegate.barColor != barColor ||
        oldDelegate.gridColor != gridColor;
  }
}
