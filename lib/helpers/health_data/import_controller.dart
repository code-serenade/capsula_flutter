import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:capsula_flutter/models/health_data_model.dart';
import 'package:capsula_flutter/providers/health_asset/health_asset_provider.dart';
import 'package:capsula_flutter/providers/health_data_view/health_data_view_provider.dart';
import 'package:capsula_flutter/widgets/health_data/data_import_dialog.dart';

final healthDataImportControllerProvider = Provider(
  (ref) => HealthDataImportController(ref),
);

class HealthDataImportController {
  HealthDataImportController(this.ref);

  final Ref ref;

  Future<void> startImport(
    BuildContext context, {
    DataCollectionMethod? method,
  }) async {
    final searchKeyword = ref.read(healthDataViewProvider).searchKeyword;
    return DataImportDialog.show(
      context,
      method: method,
      onSubmit: (draft, {File? attachment}) async {
        try {
          final notifier = ref.read(
            healthAssetsProvider(query: searchKeyword).notifier,
          );
          if (attachment != null) {
            await notifier.addFileAsset(file: attachment, draft: draft);
          } else {
            await notifier.addManualAsset(draft);
          }
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(attachment != null ? '文件已导入到本地沙盒' : '健康数据已保存到本地沙盒'),
            ),
          );
        } catch (error) {
          if (context.mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('保存失败: $error')));
          }
          rethrow;
        }
      },
    );
  }
}
