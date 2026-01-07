// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'indicator_query_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(selectableMetrics)
const selectableMetricsProvider = SelectableMetricsProvider._();

final class SelectableMetricsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SelectableMetricDto>>,
          List<SelectableMetricDto>,
          FutureOr<List<SelectableMetricDto>>
        >
    with
        $FutureModifier<List<SelectableMetricDto>>,
        $FutureProvider<List<SelectableMetricDto>> {
  const SelectableMetricsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectableMetricsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectableMetricsHash();

  @$internal
  @override
  $FutureProviderElement<List<SelectableMetricDto>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<SelectableMetricDto>> create(Ref ref) {
    return selectableMetrics(ref);
  }
}

String _$selectableMetricsHash() => r'94325365bd04457dd93d07f7ab0aeb4767e77ad4';

@ProviderFor(IndicatorQueryForm)
const indicatorQueryFormProvider = IndicatorQueryFormProvider._();

final class IndicatorQueryFormProvider
    extends $NotifierProvider<IndicatorQueryForm, IndicatorQueryFormState> {
  const IndicatorQueryFormProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'indicatorQueryFormProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$indicatorQueryFormHash();

  @$internal
  @override
  IndicatorQueryForm create() => IndicatorQueryForm();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(IndicatorQueryFormState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<IndicatorQueryFormState>(value),
    );
  }
}

String _$indicatorQueryFormHash() =>
    r'6feb6685433c8e452504981b6ba0fbdb30a3e0c1';

abstract class _$IndicatorQueryForm extends $Notifier<IndicatorQueryFormState> {
  IndicatorQueryFormState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref as $Ref<IndicatorQueryFormState, IndicatorQueryFormState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<IndicatorQueryFormState, IndicatorQueryFormState>,
              IndicatorQueryFormState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(IndicatorQueryApplied)
const indicatorQueryAppliedProvider = IndicatorQueryAppliedProvider._();

final class IndicatorQueryAppliedProvider
    extends $NotifierProvider<IndicatorQueryApplied, IndicatorQueryRequest?> {
  const IndicatorQueryAppliedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'indicatorQueryAppliedProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$indicatorQueryAppliedHash();

  @$internal
  @override
  IndicatorQueryApplied create() => IndicatorQueryApplied();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(IndicatorQueryRequest? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<IndicatorQueryRequest?>(value),
    );
  }
}

String _$indicatorQueryAppliedHash() =>
    r'b8a8e1e9edd10c751fbe429a4333ed60138b23fe';

abstract class _$IndicatorQueryApplied
    extends $Notifier<IndicatorQueryRequest?> {
  IndicatorQueryRequest? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref as $Ref<IndicatorQueryRequest?, IndicatorQueryRequest?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<IndicatorQueryRequest?, IndicatorQueryRequest?>,
              IndicatorQueryRequest?,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(IndicatorQueryResults)
const indicatorQueryResultsProvider = IndicatorQueryResultsProvider._();

final class IndicatorQueryResultsProvider
    extends
        $AsyncNotifierProvider<
          IndicatorQueryResults,
          QueryObservationResponse?
        > {
  const IndicatorQueryResultsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'indicatorQueryResultsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$indicatorQueryResultsHash();

  @$internal
  @override
  IndicatorQueryResults create() => IndicatorQueryResults();
}

String _$indicatorQueryResultsHash() =>
    r'9c6c5430f0a4768c3416f83d7925c24890adeee4';

abstract class _$IndicatorQueryResults
    extends $AsyncNotifier<QueryObservationResponse?> {
  FutureOr<QueryObservationResponse?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref
            as $Ref<
              AsyncValue<QueryObservationResponse?>,
              QueryObservationResponse?
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<QueryObservationResponse?>,
                QueryObservationResponse?
              >,
              AsyncValue<QueryObservationResponse?>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
