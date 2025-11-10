// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 主题模式状态管理 using Riverpod 3.0 Notifier pattern

@ProviderFor(ThemeModeNotifier)
const themeModeProvider = ThemeModeNotifierProvider._();

/// 主题模式状态管理 using Riverpod 3.0 Notifier pattern
final class ThemeModeNotifierProvider
    extends $NotifierProvider<ThemeModeNotifier, ThemeMode> {
  /// 主题模式状态管理 using Riverpod 3.0 Notifier pattern
  const ThemeModeNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'themeModeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$themeModeNotifierHash();

  @$internal
  @override
  ThemeModeNotifier create() => ThemeModeNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ThemeMode value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ThemeMode>(value),
    );
  }
}

String _$themeModeNotifierHash() => r'052f04454d07124de1fa9abcb1e210650b2ebf02';

/// 主题模式状态管理 using Riverpod 3.0 Notifier pattern

abstract class _$ThemeModeNotifier extends $Notifier<ThemeMode> {
  ThemeMode build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<ThemeMode, ThemeMode>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ThemeMode, ThemeMode>,
              ThemeMode,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// 获取当前有效主题的 Provider

@ProviderFor(effectiveBrightness)
const effectiveBrightnessProvider = EffectiveBrightnessProvider._();

/// 获取当前有效主题的 Provider

final class EffectiveBrightnessProvider
    extends $FunctionalProvider<Brightness, Brightness, Brightness>
    with $Provider<Brightness> {
  /// 获取当前有效主题的 Provider
  const EffectiveBrightnessProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'effectiveBrightnessProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$effectiveBrightnessHash();

  @$internal
  @override
  $ProviderElement<Brightness> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Brightness create(Ref ref) {
    return effectiveBrightness(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Brightness value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Brightness>(value),
    );
  }
}

String _$effectiveBrightnessHash() =>
    r'500b45855f37b4ecdd14d19b7a2db211127f6203';
