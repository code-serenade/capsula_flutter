import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../models/health_asset.dart';
import '../../models/health_data_model.dart';
import 'health_asset_detail_row.dart';

class HealthAssetDetailSheet extends StatelessWidget {
  const HealthAssetDetailSheet({
    super.key,
    required this.asset,
    required this.onPreview,
  });

  final HealthAsset asset;
  final VoidCallback onPreview;

  static Future<void> show({
    required BuildContext context,
    required HealthAsset asset,
    required VoidCallback onPreview,
  }) {
    return showModalBottomSheet(
      context: context,
      builder: (context) => HealthAssetDetailSheet(
        asset: asset,
        onPreview: onPreview,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            asset.filename,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          HealthAssetDetailRow(
            label: '来源',
            value: asset.dataSource.displayName,
          ),
          HealthAssetDetailRow(
            label: '类型',
            value: asset.dataType.displayName,
          ),
          HealthAssetDetailRow(
            label: '更新时间',
            value: _formatDateTime(asset.updatedAt),
          ),
          HealthAssetDetailRow(label: '文件路径', value: asset.path),
          if (asset.tags.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              children: asset.tags
                  .map(
                    (tag) => Chip(
                      label: Text(tag),
                      backgroundColor:
                          theme.colorScheme.primaryContainer.withValues(
                        alpha: 0.4,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
          if (asset.note?.isNotEmpty == true) ...[
            const SizedBox(height: 12),
            Text(asset.note!, style: theme.textTheme.bodyMedium),
          ],
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              onPreview();
            },
            icon: const Icon(Iconsax.eye),
            label: const Text('打开文件'),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime value) {
    final date =
        '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
    final time =
        '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
    return '$date $time';
  }
}
