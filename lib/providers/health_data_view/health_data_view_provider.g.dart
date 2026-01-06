// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health_data_view_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(HealthDataView)
const healthDataViewProvider = HealthDataViewProvider._();

final class HealthDataViewProvider
    extends $NotifierProvider<HealthDataView, HealthDataViewState> {
  const HealthDataViewProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'healthDataViewProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$healthDataViewHash();

  @$internal
  @override
  HealthDataView create() => HealthDataView();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HealthDataViewState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HealthDataViewState>(value),
    );
  }
}

String _$healthDataViewHash() => r'4ba8344755aea13b4216cfb6c12025ddf2e01dfc';

abstract class _$HealthDataView extends $Notifier<HealthDataViewState> {
  HealthDataViewState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<HealthDataViewState, HealthDataViewState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<HealthDataViewState, HealthDataViewState>,
              HealthDataViewState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
