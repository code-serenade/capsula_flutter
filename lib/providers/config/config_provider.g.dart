// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'config_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(config)
const configProvider = ConfigProvider._();

final class ConfigProvider extends $FunctionalProvider<Config, Config, Config>
    with $Provider<Config> {
  const ConfigProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'configProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$configHash();

  @$internal
  @override
  $ProviderElement<Config> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Config create(Ref ref) {
    return config(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Config value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Config>(value),
    );
  }
}

String _$configHash() => r'982110a8d649dc083cdb46060bd37e86315aea23';
