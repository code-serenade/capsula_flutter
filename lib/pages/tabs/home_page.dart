import 'package:auto_route/auto_route.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:capsula_flutter/gen/app_localizations.dart';
import 'package:capsula_flutter/models/medical/metric_models.dart';
import 'package:capsula_flutter/models/medical/observation_models.dart';
import 'package:capsula_flutter/providers/indicator_query/indicator_query_provider.dart';
import 'package:capsula_flutter/services/chart/chart.dart';
import 'package:capsula_flutter/widgets/charts/charts.dart';
import 'package:capsula_flutter/widgets/health_data/page_header.dart';

@RoutePage()
class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    final formState = ref.watch(indicatorQueryFormProvider);
    final appliedRequest = ref.watch(indicatorQueryAppliedProvider);
    final results = ref.watch(indicatorQueryResultsProvider);
    final selectableMetrics = ref.watch(selectableMetricsProvider);

    final formNotifier = ref.read(indicatorQueryFormProvider.notifier);
    final appliedNotifier = ref.read(indicatorQueryAppliedProvider.notifier);

    ref.listen<AsyncValue<QueryObservationResponse?>>(
      indicatorQueryResultsProvider,
      (previous, next) {
        final hadError = previous?.hasError ?? false;
        final hasError = next.hasError;
        if (!hasError || hadError) {
          return;
        }

        final message = _formatRequestError(next.error!);
        if (!context.mounted) {
          return;
        }

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      },
    );

    final subjectController = useTextEditingController(
      text: formState.subjectId,
    );

    useEffect(() {
      if (subjectController.text != formState.subjectId) {
        subjectController.text = formState.subjectId;
        subjectController.selection = TextSelection.collapsed(
          offset: subjectController.text.length,
        );
      }
      return null;
    }, [formState.subjectId]);

    final subjectId = int.tryParse(formState.subjectId.trim());
    final metricId = int.tryParse(formState.metricId.trim());
    final canSubmit = subjectId != null && metricId != null;

    void reset() {
      formNotifier.reset();
      appliedNotifier.reset();
    }

    void submit() {
      final parsedSubjectId = int.tryParse(formState.subjectId.trim());
      final parsedMetricId = int.tryParse(formState.metricId.trim());
      if (parsedSubjectId == null || parsedMetricId == null) {
        return;
      }

      final range = formState.dateRange;
      final startAt = range == null
          ? null
          : DateTime.utc(range.start.year, range.start.month, range.start.day);
      final endAt = range == null
          ? null
          : DateTime.utc(
              range.end.year,
              range.end.month,
              range.end.day,
              23,
              59,
              59,
              999,
            );

      appliedNotifier.apply(
        IndicatorQueryRequest(
          subjectId: parsedSubjectId,
          metricId: parsedMetricId,
          startAt: startAt,
          endAt: endAt,
        ),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: PageHeader(
              title: l10n.home,
              subtitle: 'GET /medical/observations',
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: _IndicatorQueryFormCard(
                state: formState,
                subjectController: subjectController,
                selectableMetrics: selectableMetrics,
                canSubmit: canSubmit,
                onSubjectChanged: formNotifier.setSubjectId,
                onMetricChanged: formNotifier.setMetricId,
                onReloadMetrics: () =>
                    ref.invalidate(selectableMetricsProvider),
                onPickDateRange: () async {
                  final now = DateTime.now();
                  final initialRange =
                      formState.dateRange ??
                      DateTimeRange(
                        start: now.subtract(const Duration(days: 30)),
                        end: now,
                      );

                  final picked = await showDateRangePicker(
                    context: context,
                    initialDateRange: initialRange,
                    firstDate: DateTime(2020),
                    lastDate: now.add(const Duration(days: 365)),
                  );

                  formNotifier.setDateRange(picked);
                },
                onClearDateRange: () => formNotifier.setDateRange(null),
                onSubmit: submit,
                onReset: reset,
              ),
            ),
          ),
          if (appliedRequest != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: _AppliedQuerySummary(request: appliedRequest),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          results.when(
            skipLoadingOnReload: results.hasError,
            data: (data) {
              if (appliedRequest == null) {
                return const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 32),
                    child: _EmptyIndicatorQueryState(),
                  ),
                );
              }

              if (data == null) {
                return const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 32),
                    child: _EmptyIndicatorQueryState(),
                  ),
                );
              }

              return _ObservationResultSlivers(response: data);
            },
            loading: () => const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, _) => SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 36),
                    const SizedBox(height: 12),
                    const Text('请求失败'),
                    const SizedBox(height: 8),
                    Text(
                      _formatRequestError(error),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () => ref
                          .read(indicatorQueryResultsProvider.notifier)
                          .refresh(),
                      child: const Text('重试'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }
}

String _formatRequestError(Object error) {
  if (error is DioException) {
    final message = error.error?.toString();
    if (message != null && message.trim().isNotEmpty) {
      return message;
    }
    if (error.message != null && error.message!.trim().isNotEmpty) {
      return error.message!;
    }
  }

  final text = error.toString();
  const exceptionPrefix = 'Exception: ';
  if (text.startsWith(exceptionPrefix)) {
    return text.substring(exceptionPrefix.length);
  }

  return text;
}

class _IndicatorQueryFormCard extends StatelessWidget {
  const _IndicatorQueryFormCard({
    required this.state,
    required this.subjectController,
    required this.selectableMetrics,
    required this.canSubmit,
    required this.onSubjectChanged,
    required this.onMetricChanged,
    required this.onReloadMetrics,
    required this.onPickDateRange,
    required this.onClearDateRange,
    required this.onSubmit,
    required this.onReset,
  });

  final IndicatorQueryFormState state;
  final TextEditingController subjectController;
  final AsyncValue<List<SelectableMetricDto>> selectableMetrics;
  final bool canSubmit;

  final ValueChanged<String> onSubjectChanged;
  final ValueChanged<String> onMetricChanged;
  final VoidCallback onReloadMetrics;
  final Future<void> Function() onPickDateRange;
  final VoidCallback onClearDateRange;
  final VoidCallback onSubmit;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final range = state.dateRange;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Query Params',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: subjectController,
                    onChanged: onSubjectChanged,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'subject_id',
                      hintText: 'e.g. 1',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: selectableMetrics.when(
                    data: (metrics) {
                      final currentId = int.tryParse(state.metricId.trim());
                      final hasCurrent =
                          currentId != null &&
                          metrics.any((metric) => metric.id == currentId);
                      final value = hasCurrent ? currentId : null;

                      if (metrics.isEmpty) {
                        return DropdownButtonFormField<int>(
                          items: const [],
                          onChanged: null,
                          decoration: const InputDecoration(
                            labelText: 'metric_id',
                            hintText: '暂无可选指标',
                          ),
                        );
                      }

                      return DropdownButtonFormField<int>(
                        value: value,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'metric_id',
                        ),
                        hint: const Text('请选择指标'),
                        items: metrics
                            .map(
                              (metric) => DropdownMenuItem<int>(
                                value: metric.id,
                                child: Text(
                                  metric.unit == null ||
                                          metric.unit!.trim().isEmpty
                                      ? metric.name
                                      : '${metric.name} (${metric.unit})',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (selected) {
                          onMetricChanged(selected?.toString() ?? '');
                        },
                      );
                    },
                    loading: () => DropdownButtonFormField<int>(
                      items: const [],
                      onChanged: null,
                      decoration: const InputDecoration(
                        labelText: 'metric_id',
                        hintText: '加载中...',
                      ),
                    ),
                    error: (error, _) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DropdownButtonFormField<int>(
                          items: const [],
                          onChanged: null,
                          decoration: const InputDecoration(
                            labelText: 'metric_id',
                            hintText: '加载失败',
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                _formatRequestError(error),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.error,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: onReloadMetrics,
                              child: const Text('重试'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onPickDateRange,
                    icon: const Icon(Icons.date_range),
                    label: Text(
                      range == null
                          ? 'start_at / end_at (optional)'
                          : _formatDateRange(range),
                    ),
                  ),
                ),
                if (range != null) ...[
                  const SizedBox(width: 12),
                  IconButton(
                    onPressed: onClearDateRange,
                    icon: const Icon(Icons.close_rounded),
                    tooltip: 'Clear',
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onReset,
                    child: const Text('重置'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: canSubmit ? onSubmit : null,
                    child: const Text('查询'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateRange(DateTimeRange range) {
    final start = _formatDate(range.start);
    final end = _formatDate(range.end);
    return '$start ~ $end';
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

class _AppliedQuerySummary extends StatelessWidget {
  const _AppliedQuerySummary({required this.request});

  final IndicatorQueryRequest request;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final chips = <Widget>[
      _SummaryChip(label: 'subject_id: ${request.subjectId}'),
      _SummaryChip(label: 'metric_id: ${request.metricId}'),
      if (request.startAt != null)
        _SummaryChip(label: 'start_at: ${_formatUtc(request.startAt!)}'),
      if (request.endAt != null)
        _SummaryChip(label: 'end_at: ${_formatUtc(request.endAt!)}'),
    ];

    return Card(
      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Wrap(spacing: 8, runSpacing: 8, children: chips),
      ),
    );
  }

  String _formatUtc(DateTime value) => value.toUtc().toIso8601String();
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Text(
        label,
        style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _EmptyIndicatorQueryState extends StatelessWidget {
  const _EmptyIndicatorQueryState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.query_stats, size: 48, color: theme.colorScheme.primary),
        const SizedBox(height: 12),
        const Text('暂无查询结果'),
      ],
    );
  }
}

class _ObservationResultSlivers extends StatelessWidget {
  const _ObservationResultSlivers({required this.response});

  final QueryObservationResponse response;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final metric = response.metric;
    final visualization = MetricVisualizationParsing.fromApiValue(
      metric.visualization,
    );
    final showsChart = visualization.usesChart;
    final showsSingleValue = visualization == MetricVisualization.singleValue;

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index == 0) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        metric.name,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _SummaryChip(
                            label: 'subject_id: ${response.subjectId}',
                          ),
                          _SummaryChip(label: 'metric_id: ${metric.id}'),
                          _SummaryChip(label: 'code: ${metric.code}'),
                          _SummaryChip(
                            label: 'vazualization: ${metric.visualization}',
                          ),
                          if (metric.unit != null &&
                              metric.unit!.trim().isNotEmpty)
                            _SummaryChip(label: 'unit: ${metric.unit}'),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }

            if (response.points.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('暂无数据'),
              );
            }

            if (showsSingleValue) {
              if (index == 1) {
                final point = response.points.last;
                return _ObservationPointCard(point: point, unit: metric.unit);
              }

              return const SizedBox.shrink();
            }

            final pointOffset = showsChart ? 2 : 1;
            if (showsChart && index == 1) {
              return ObservationMetricChart(
                metric: metric,
                points: response.points,
              );
            }

            final pointIndex = index - pointOffset;
            final point = response.points[pointIndex];
            return _ObservationPointCard(point: point, unit: metric.unit);
          },
          childCount: response.points.isEmpty
              ? 2
              : showsSingleValue
              ? 2
              : showsChart
              ? response.points.length + 2
              : response.points.length + 1,
        ),
      ),
    );
  }
}

class _ObservationPointCard extends StatelessWidget {
  const _ObservationPointCard({required this.point, required this.unit});

  final ObservationPointDto point;
  final String? unit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final observedAt = point.observedAt.toUtc().toIso8601String();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              point.value,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (unit != null && unit!.trim().isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                unit!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: 12),
            Text(
              'observed_at: $observedAt',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (point.valueNum != null) ...[
              const SizedBox(height: 4),
              Text(
                'value_num: ${point.valueNum}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
