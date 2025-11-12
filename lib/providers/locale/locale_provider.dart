import 'dart:ui';
import 'package:capsula_flutter/l10n.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'locale_provider.g.dart';

/// Locale state management using Riverpod 3.0 Notifier pattern
@riverpod
class LocaleNotifier extends _$LocaleNotifier {
  @override
  Locale build() {
    // Get system locale and find the best match from supported locales
    final systemLocale = PlatformDispatcher.instance.locale;
    // return systemLocale;
    return _findBestMatchLocale(systemLocale);
  }

  /// Find the best matching locale from supported locales
  Locale _findBestMatchLocale(Locale systemLocale) {
    // Check if exact match exists
    for (final locale in L10n.all) {
      if (locale.languageCode == systemLocale.languageCode &&
          locale.countryCode == systemLocale.countryCode) {
        return locale;
      }
    }

    // Check if language code matches (ignore country)
    for (final locale in L10n.all) {
      if (locale.languageCode == systemLocale.languageCode) {
        return locale;
      }
    }

    // Fallback to first supported locale (en_US)
    return L10n.all.first;
  }

  /// Set the app locale
  void setLocale(Locale locale) {
    state = locale;
  }
}
