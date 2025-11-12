import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'theme_provider.g.dart';

/// 主题模式状态管理 using Riverpod 3.0 Notifier pattern
@riverpod
class ThemeModeNotifier extends _$ThemeModeNotifier {
  @override
  ThemeMode build() {
    // 不能在 build 时调用 logThemeInfo，因为 state 还未初始化
    // 延迟到下一帧打印
    Future.microtask(() => logThemeInfo());
    return ThemeMode.system;
  }

  /// 切换到 Light 模式
  void setLightMode() {
    state = ThemeMode.light;
    logThemeInfo();
  }

  /// 切换到 Dark 模式
  void setDarkMode() {
    state = ThemeMode.dark;
    logThemeInfo();
  }

  /// 切换到系统模式
  void setSystemMode() {
    state = ThemeMode.system;
    logThemeInfo();
  }

  /// 切换主题（循环切换）
  void toggleTheme() {
    switch (state) {
      case ThemeMode.light:
        setDarkMode();
        break;
      case ThemeMode.dark:
        setSystemMode();
        break;
      case ThemeMode.system:
        setLightMode();
        break;
    }
  }

  /// 获取当前系统主题
  Brightness getSystemBrightness() {
    return SchedulerBinding.instance.platformDispatcher.platformBrightness;
  }

  /// 获取实际使用的主题
  Brightness getEffectiveBrightness() {
    if (state == ThemeMode.system) {
      return getSystemBrightness();
    }
    return state == ThemeMode.light ? Brightness.light : Brightness.dark;
  }

  /// 打印主题调试信息
  void logThemeInfo() {
    final systemBrightness = getSystemBrightness();
    final effectiveBrightness = getEffectiveBrightness();

    // ignore: avoid_print
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    // ignore: avoid_print
    print('🎨 主题状态调试信息');
    // ignore: avoid_print
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    // ignore: avoid_print
    print('📱 系统主题: ${systemBrightness == Brightness.light ? "☀️ Light" : "🌙 Dark"}');
    // ignore: avoid_print
    print('⚙️  应用主题模式: ${_themeModeToString(state)}');
    // ignore: avoid_print
    print('✨ 实际使用主题: ${effectiveBrightness == Brightness.light ? "☀️ Light" : "🌙 Dark"}');
    // ignore: avoid_print
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
  }

  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return '☀️ Light (强制)';
      case ThemeMode.dark:
        return '🌙 Dark (强制)';
      case ThemeMode.system:
        return '🔄 System (自动)';
    }
  }
}

/// 获取当前有效主题的 Provider
@riverpod
Brightness effectiveBrightness(Ref ref) {
  ref.watch(themeModeProvider);
  final notifier = ref.read(themeModeProvider.notifier);
  return notifier.getEffectiveBrightness();
}
