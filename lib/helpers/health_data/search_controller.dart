import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:capsula_flutter/providers/health_data_view/health_data_view_provider.dart';

final healthDataSearchControllerProvider = Provider(
  (ref) => HealthDataSearchController(ref),
);

class HealthDataSearchController {
  HealthDataSearchController(this.ref);

  final Ref ref;

  Future<void> startSearch(BuildContext context) async {
    final initialKeyword = ref.read(healthDataViewProvider).searchKeyword;
    final controller = TextEditingController(text: initialKeyword);
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('搜索健康数据'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: '输入关键字'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(dialogContext, controller.text.trim()),
            child: const Text('确定'),
          ),
        ],
      ),
    );

    if (result != null) {
      ref.read(healthDataViewProvider.notifier).setSearchKeyword(result);
    }
  }
}
