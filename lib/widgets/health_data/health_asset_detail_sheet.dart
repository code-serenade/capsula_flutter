import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import 'package:capsula_flutter/models/health_asset.dart';
import 'package:capsula_flutter/models/health_data_model.dart';
import 'package:capsula_flutter/services/storage/sandbox_service.dart';
import 'package:capsula_flutter/utils/file_viewer.dart';
import 'health_asset_detail_row.dart';

class HealthAssetDetailSheet extends StatelessWidget {
  const HealthAssetDetailSheet({
    super.key,
    required this.asset,
    required this.onPreview,
    required this.onDelete,
  });

  final HealthAsset asset;
  final VoidCallback onPreview;
  final Future<void> Function() onDelete;

  static Future<void> show({
    required BuildContext context,
    required HealthAsset asset,
    required VoidCallback onPreview,
    required Future<void> Function() onDelete,
  }) {
    return showModalBottomSheet(
      context: context,
      builder: (context) =>
          HealthAssetDetailSheet(
            asset: asset,
            onPreview: onPreview,
            onDelete: onDelete,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final markdownPath = _resolveMarkdownPath(asset);
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
          HealthAssetDetailRow(label: '类型', value: asset.dataType.displayName),
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
                      backgroundColor: theme.colorScheme.primaryContainer
                          .withValues(alpha: 0.4),
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
          if (markdownPath != null)
            OutlinedButton.icon(
              onPressed: () => _openMarkdown(context, markdownPath),
              icon: const Icon(Iconsax.document_text),
              label: const Text('打开Markdown'),
            ),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              onPreview();
            },
            icon: const Icon(Iconsax.eye),
            label: const Text('打开文件'),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () => _confirmDelete(context),
            icon: Icon(Iconsax.trash, color: theme.colorScheme.error),
            label: Text(
              '删除文件',
              style: TextStyle(color: theme.colorScheme.error),
            ),
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

  String? _resolveMarkdownPath(HealthAsset asset) {
    final value = asset.metadata?['markdownPath'];
    if (value is String && value.trim().isNotEmpty) {
      return value;
    }
    return null;
  }

  Future<void> _openMarkdown(BuildContext context, String relativePath) async {
    try {
      final sandbox = SandboxService.instance;
      if (!sandbox.isInitialized) {
        await sandbox.initialize();
      }
      final file = sandbox.fileFor(relativePath);
      if (!await file.exists()) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Markdown文件不存在')));
        return;
      }
      final success = await FileViewerUtils.openFile(file.path);
      if (!success && context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('无法打开Markdown文件')));
      }
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('无法打开Markdown: $error')));
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除文件'),
        content: const Text('将删除上传文件及其转换的Markdown，且无法恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirm != true) {
      return;
    }

    if (!context.mounted) return;
    Navigator.of(context).pop();
    try {
      await onDelete();
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('删除失败: $error')));
    }
  }
}
