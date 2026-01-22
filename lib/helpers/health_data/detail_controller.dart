import 'package:capsula_flutter/helpers/health_asset/health_asset_preview_service.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:capsula_flutter/models/health_asset.dart';
import 'package:capsula_flutter/providers/health_asset/health_asset_provider.dart';
import 'package:capsula_flutter/providers/health_data_view/health_data_view_provider.dart';

import 'package:capsula_flutter/widgets/health_data/health_asset_detail_sheet.dart';

final healthAssetDetailControllerProvider = Provider(
  (ref) => HealthAssetDetailController(ref),
);

class HealthAssetDetailController {
  HealthAssetDetailController(this.ref);

  final Ref ref;

  Future<void> showDetails(BuildContext context, HealthAsset asset) {
    return HealthAssetDetailSheet.show(
      context: context,
      asset: asset,
      onPreview: () => previewAsset(context, asset),
      onDelete: () => deleteAsset(context, asset),
    );
  }

  Future<void> previewAsset(BuildContext context, HealthAsset asset) {
    final previewService = ref.read(healthAssetPreviewServiceProvider);
    return previewService.preview(context, asset);
  }

  Future<void> deleteAsset(BuildContext context, HealthAsset asset) async {
    final searchKeyword = ref.read(healthDataViewProvider).searchKeyword;
    final notifier = ref.read(
      healthAssetsProvider(query: searchKeyword).notifier,
    );
    await notifier.deleteAssetWithFiles(asset);
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('已删除文件及记录')));
  }
}
