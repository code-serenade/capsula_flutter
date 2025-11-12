import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../l10n.dart';
import '../providers/locale/locale_provider.dart';

class LanguagePickerWidget extends ConsumerWidget {
  const LanguagePickerWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);
    return DropdownButtonHideUnderline(
      child: DropdownButton(
        value: currentLocale,
        icon: const Icon(Icons.language),
        items: L10n.all.map((locale) {
          final flag = L10n.getFlag(locale);
          return DropdownMenuItem(
            value: locale,
            child: Center(
              child: Text(flag, style: const TextStyle(fontSize: 32)),
            ),
          );
        }).toList(),
        onChanged: (value) {
          ref.read(localeProvider.notifier).setLocale(value!);
        },
      ),
    );
  }
}
