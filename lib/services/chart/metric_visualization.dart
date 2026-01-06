enum MetricVisualization {
  lineChart,
  barChart,
  valueList,
  singleValue,
  unknown,
}

extension MetricVisualizationParsing on MetricVisualization {
  static MetricVisualization fromApiValue(String? value) {
    switch (value) {
      case 'line_chart':
        return MetricVisualization.lineChart;
      case 'bar_chart':
        return MetricVisualization.barChart;
      case 'value_list':
        return MetricVisualization.valueList;
      case 'single_value':
        return MetricVisualization.singleValue;
      default:
        return MetricVisualization.unknown;
    }
  }

  String? get apiValue {
    return switch (this) {
      MetricVisualization.lineChart => 'line_chart',
      MetricVisualization.barChart => 'bar_chart',
      MetricVisualization.valueList => 'value_list',
      MetricVisualization.singleValue => 'single_value',
      MetricVisualization.unknown => null,
    };
  }

  bool get usesChart =>
      this == MetricVisualization.lineChart ||
      this == MetricVisualization.barChart;
}
