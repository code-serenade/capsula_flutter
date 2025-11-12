import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../models/health_asset.dart';
import '../models/health_data_model.dart';
import '../providers/health_asset/health_asset_provider.dart';
import '../providers/health_data_view/health_data_view_provider.dart';
import '../services/health_asset_preview_service.dart';
import '../widgets/health_data/health_asset_detail_sheet.dart';
import '../widgets/health_data/data_import_dialog.dart';

class HealthDataActions {
  HealthDataActions({required this.context, required this.ref});

  final BuildContext context;
  final WidgetRef ref;

  Future<void> startImport({DataCollectionMethod? method}) async {
    final searchKeyword = ref.read(healthDataViewProvider).searchKeyword;
    return DataImportDialog.show(
      context,
      method: method,
      onSubmit: (draft, {File? attachment}) async {
        try {
          final notifier =
              ref.read(healthAssetsProvider(query: searchKeyword).notifier);
          if (attachment != null) {
            await notifier.addFileAsset(file: attachment, draft: draft);
          } else {
            await notifier.addManualAsset(draft);
          }
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                attachment != null
                    ? '文件已导入到本地沙盒'
                    : '健康数据已保存到本地沙盒',
              ),
            ),
          );
        } catch (error) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('保存失败: $error')),
            );
          }
          rethrow;
        }
      },
    );
  }

  Future<void> startSearch() async {
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

  Future<void> showAssetDetails(HealthAsset asset) {
    return HealthAssetDetailSheet.show(
      context: context,
      asset: asset,
      onPreview: () => previewAsset(asset),
    );
  }

  Future<void> previewAsset(HealthAsset asset) {
    final previewService = ref.read(healthAssetPreviewServiceProvider);
    return previewService.preview(context, asset);
  }
}
