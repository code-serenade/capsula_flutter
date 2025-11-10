// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sandbox_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(sandboxService)
const sandboxServiceProvider = SandboxServiceProvider._();

final class SandboxServiceProvider
    extends $FunctionalProvider<SandboxService, SandboxService, SandboxService>
    with $Provider<SandboxService> {
  const SandboxServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sandboxServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sandboxServiceHash();

  @$internal
  @override
  $ProviderElement<SandboxService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SandboxService create(Ref ref) {
    return sandboxService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SandboxService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SandboxService>(value),
    );
  }
}

String _$sandboxServiceHash() => r'66c357350e7d9945f4bb6be1a759f9b24812d5fd';

@ProviderFor(sandboxPaths)
const sandboxPathsProvider = SandboxPathsProvider._();

final class SandboxPathsProvider
    extends
        $FunctionalProvider<
          AsyncValue<SandboxPaths>,
          SandboxPaths,
          FutureOr<SandboxPaths>
        >
    with $FutureModifier<SandboxPaths>, $FutureProvider<SandboxPaths> {
  const SandboxPathsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sandboxPathsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sandboxPathsHash();

  @$internal
  @override
  $FutureProviderElement<SandboxPaths> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SandboxPaths> create(Ref ref) {
    return sandboxPaths(ref);
  }
}

String _$sandboxPathsHash() => r'0658434812e07a881c0e8f19a54bcffef5a5daa3';
