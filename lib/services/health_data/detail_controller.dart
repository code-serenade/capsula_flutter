import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:capsula_flutter/models/health_asset.dart';
import 'package:capsula_flutter/services/health_asset_preview_service.dart';
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
    );
  }

  Future<void> previewAsset(BuildContext context, HealthAsset asset) {
    final previewService = ref.read(healthAssetPreviewServiceProvider);
    return previewService.preview(context, asset);
  }
}
