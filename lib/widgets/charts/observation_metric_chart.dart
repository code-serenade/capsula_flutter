import 'package:flutter/material.dart';

import 'package:capsula_flutter/models/medical/observation_models.dart';
import 'package:capsula_flutter/services/chart/chart.dart';
import 'package:capsula_flutter/widgets/charts/observation_bar_chart.dart';
import 'package:capsula_flutter/widgets/charts/observation_line_chart.dart';

class ObservationMetricChart extends StatelessWidget {
  const ObservationMetricChart({
    super.key,
    required this.metric,
    required this.points,
    this.margin = const EdgeInsets.only(bottom: 12),
    this.height = 220,
  });

  final MetricDto metric;
  final List<ObservationPointDto> points;
  final EdgeInsetsGeometry margin;
  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final visualization = MetricVisualizationParsing.fromApiValue(
      metric.visualization,
    );

    if (!visualization.usesChart) {
      return const SizedBox.shrink();
    }

    final series = const ObservationChartMapper().tryMap(points);
    final Widget chart;
    if (series == null || series.isEmpty) {
      chart = _ChartPlaceholder(
        height: height,
        label: '暂无可绘制数值',
        labelStyle: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );
    } else {
      chart = switch (visualization) {
        MetricVisualization.lineChart => ObservationLineChart(
          series: series,
          height: height,
        ),
        MetricVisualization.barChart => ObservationBarChart(
          series: series,
          height: height,
        ),
        _ => _ChartPlaceholder(
          height: height,
          label: '图表类型不支持',
          labelStyle: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      };
    }

    return Card(
      margin: margin,
      clipBehavior: Clip.antiAlias,
      child: Padding(padding: const EdgeInsets.all(12), child: chart),
    );
  }
}

class _ChartPlaceholder extends StatelessWidget {
  const _ChartPlaceholder({
    required this.height,
    required this.label,
    this.labelStyle,
  });

  final double height;
  final String label;
  final TextStyle? labelStyle;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Center(child: Text(label, style: labelStyle)),
    );
  }
}
