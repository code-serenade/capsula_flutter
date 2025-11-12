// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health_asset_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(healthAssetRepository)
const healthAssetRepositoryProvider = HealthAssetRepositoryProvider._();

final class HealthAssetRepositoryProvider
    extends
        $FunctionalProvider<
          HealthAssetRepository,
          HealthAssetRepository,
          HealthAssetRepository
        >
    with $Provider<HealthAssetRepository> {
  const HealthAssetRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'healthAssetRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$healthAssetRepositoryHash();

  @$internal
  @override
  $ProviderElement<HealthAssetRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  HealthAssetRepository create(Ref ref) {
    return healthAssetRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HealthAssetRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HealthAssetRepository>(value),
    );
  }
}

String _$healthAssetRepositoryHash() =>
    r'd5174bbb88ac8a2f071be8dff12adcb1e5ab0613';

@ProviderFor(HealthAssets)
const healthAssetsProvider = HealthAssetsFamily._();

final class HealthAssetsProvider
    extends $AsyncNotifierProvider<HealthAssets, List<HealthAsset>> {
  const HealthAssetsProvider._({
    required HealthAssetsFamily super.from,
    required ({String query, List<String> tags}) super.argument,
  }) : super(
         retry: null,
         name: r'healthAssetsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$healthAssetsHash();

  @override
  String toString() {
    return r'healthAssetsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  HealthAssets create() => HealthAssets();

  @override
  bool operator ==(Object other) {
    return other is HealthAssetsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$healthAssetsHash() => r'6cf0fc951986643de07b9218f727eb703aa2762b';

final class HealthAssetsFamily extends $Family
    with
        $ClassFamilyOverride<
          HealthAssets,
          AsyncValue<List<HealthAsset>>,
          List<HealthAsset>,
          FutureOr<List<HealthAsset>>,
          ({String query, List<String> tags})
        > {
  const HealthAssetsFamily._()
    : super(
        retry: null,
        name: r'healthAssetsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  HealthAssetsProvider call({
    String query = '',
    List<String> tags = const [],
  }) =>
      HealthAssetsProvider._(argument: (query: query, tags: tags), from: this);

  @override
  String toString() => r'healthAssetsProvider';
}

abstract class _$HealthAssets extends $AsyncNotifier<List<HealthAsset>> {
  late final _$args = ref.$arg as ({String query, List<String> tags});
  String get query => _$args.query;
  List<String> get tags => _$args.tags;

  FutureOr<List<HealthAsset>> build({
    String query = '',
    List<String> tags = const [],
  });
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(query: _$args.query, tags: _$args.tags);
    final ref =
        this.ref as $Ref<AsyncValue<List<HealthAsset>>, List<HealthAsset>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<HealthAsset>>, List<HealthAsset>>,
              AsyncValue<List<HealthAsset>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
