import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:iconsax/iconsax.dart';

import 'package:capsula_flutter/api/medical.dart';
import 'package:capsula_flutter/models/health_asset.dart';
import 'package:capsula_flutter/models/health_data_model.dart';
import 'package:capsula_flutter/models/medical/markdown_models.dart';
import 'package:capsula_flutter/services/storage/sandbox_service.dart';
import 'package:capsula_flutter/utils/file_viewer.dart';
import 'health_asset_detail_row.dart';

class HealthAssetDetailSheet extends StatefulWidget {
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
  State<HealthAssetDetailSheet> createState() => _HealthAssetDetailSheetState();
}

class _HealthAssetDetailSheetState extends State<HealthAssetDetailSheet> {
  String? _lastTaskId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final markdownPath = _resolveMarkdownPath(widget.asset);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.asset.filename,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          HealthAssetDetailRow(
            label: '来源',
            value: widget.asset.dataSource.displayName,
          ),
          HealthAssetDetailRow(
            label: '类型',
            value: widget.asset.dataType.displayName,
          ),
          HealthAssetDetailRow(
            label: '更新时间',
            value: _formatDateTime(widget.asset.updatedAt),
          ),
          HealthAssetDetailRow(label: '文件路径', value: widget.asset.path),
          if (widget.asset.tags.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              children: widget.asset.tags
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
          if (widget.asset.note?.isNotEmpty == true) ...[
            const SizedBox(height: 12),
            Text(widget.asset.note!, style: theme.textTheme.bodyMedium),
          ],
          const SizedBox(height: 16),
          if (markdownPath != null)
            OutlinedButton.icon(
              onPressed: () => _openMarkdown(context, markdownPath),
              icon: const Icon(Iconsax.document_text),
              label: const Text('打开Markdown'),
            ),
          if (markdownPath != null) const SizedBox(height: 8),
          if (markdownPath != null)
            FilledButton.icon(
              onPressed: () =>
                  _uploadMarkdown(context, widget.asset, markdownPath),
              icon: const Icon(Iconsax.document_upload),
              label: const Text('上传Markdown'),
            ),
          if (markdownPath != null) const SizedBox(height: 8),
          if (markdownPath != null)
            OutlinedButton.icon(
              onPressed: () => _promptTaskStatus(context),
              icon: const Icon(Iconsax.search_normal),
              label: const Text('查询任务'),
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

  String _resolveMarkdownSourceType(HealthAsset asset) {
    if (asset.dataSource == DataSource.upload) {
      return 'import';
    }
    return asset.dataSource.name;
  }

  int? _resolveSubjectId(HealthAsset asset) {
    return 1;
  }

  Future<void> _uploadMarkdown(
    BuildContext context,
    HealthAsset asset,
    String relativePath,
  ) async {
    final rootNavigator = Navigator.of(context, rootNavigator: true);
    var dialogShown = false;
    try {
      final subjectId = _resolveSubjectId(asset);
      if (subjectId == null) {
        _showMessage(context, '缺少subject_id，无法上传');
        return;
      }

      dialogShown = true;
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      final sandbox = SandboxService.instance;
      if (!sandbox.isInitialized) {
        await sandbox.initialize();
      }
      final file = sandbox.fileFor(relativePath);
      if (!await file.exists()) {
        if (!context.mounted) return;
        if (dialogShown && rootNavigator.canPop()) {
          rootNavigator.pop();
        }
        _showMessage(context, 'Markdown文件不存在');
        return;
      }
      final content = await file.readAsString();
      if (content.trim().isEmpty) {
        if (!context.mounted) return;
        if (dialogShown && rootNavigator.canPop()) {
          rootNavigator.pop();
        }
        _showMessage(context, 'Markdown内容为空');
        return;
      }

      final sourceType = _resolveMarkdownSourceType(asset);
      final task = await uploadMarkdownDataSource(
        subjectId: subjectId,
        sourceType: sourceType,
        sourceName: asset.filename,
        fileContent: content,
      );

      if (mounted) {
        setState(() {
          _lastTaskId = task.taskId;
        });
      }

      MarkdownTaskStatusResponse? taskStatus;
      const maxAttempts = 5;
      for (var attempt = 0; attempt < maxAttempts; attempt += 1) {
        taskStatus = await getMarkdownTaskStatus(taskId: task.taskId);
        if (taskStatus.status == 'succeeded' ||
            taskStatus.status == 'failed') {
          break;
        }
        await Future.delayed(const Duration(seconds: 1));
      }

      if (!context.mounted) return;
      if (dialogShown && rootNavigator.canPop()) {
        rootNavigator.pop();
      }

      if (taskStatus == null || taskStatus.status.isEmpty) {
        _showMessage(context, '任务已提交: ${task.taskId}');
        return;
      }

      if (taskStatus.status == 'succeeded') {
        final inserted = taskStatus.result?.recordsInserted ?? 0;
        _showMessage(context, '上传完成，写入$inserted条记录');
        return;
      }

      if (taskStatus.status == 'failed') {
        final error = taskStatus.error?.trim();
        _showMessage(
          context,
          '任务失败: ${error?.isNotEmpty == true ? error : task.taskId}',
        );
        return;
      }

      _showMessage(context, '任务处理中: ${task.taskId}');
    } catch (error) {
      if (!context.mounted) return;
      if (dialogShown && rootNavigator.canPop()) {
        rootNavigator.pop();
      }
      final message = _formatUploadError(error);
      _showMessage(context, '上传Markdown失败: $message');
    }
  }

  void _showMessage(BuildContext context, String message) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) {
      return;
    }
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  String _formatUploadError(Object error) {
    if (error is DioException) {
      final message = error.error?.toString();
      if (message != null && message.trim().isNotEmpty) {
        return message;
      }
      final data = error.response?.data;
      if (data is Map) {
        final rawMessage = data['message']?.toString();
        if (rawMessage != null && rawMessage.trim().isNotEmpty) {
          return rawMessage;
        }
        final errorObj = data['error'];
        if (errorObj != null) {
          final errorMessage = errorObj.toString();
          if (errorMessage.trim().isNotEmpty) {
            return errorMessage;
          }
        }
      }
      return error.message ?? '请求失败';
    }
    return error.toString();
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

  Future<void> _promptTaskStatus(BuildContext context) async {
    final controller = TextEditingController(text: _lastTaskId ?? '');
    final taskId = await showDialog<String?>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('查询任务'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: '输入 task_id'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('查询'),
          ),
        ],
      ),
    );

    if (taskId == null || taskId.isEmpty) {
      return;
    }

    await _fetchTaskStatus(context, taskId);
  }

  Future<void> _fetchTaskStatus(BuildContext context, String taskId) async {
    final rootNavigator = Navigator.of(context, rootNavigator: true);
    var dialogShown = false;
    try {
      dialogShown = true;
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      final taskStatus = await getMarkdownTaskStatus(taskId: taskId);
      if (!context.mounted) return;
      if (dialogShown && rootNavigator.canPop()) {
        rootNavigator.pop();
      }

      if (taskStatus.status == 'succeeded') {
        final inserted = taskStatus.result?.recordsInserted ?? 0;
        _showMessage(context, '任务完成，写入$inserted条记录');
        return;
      }

      if (taskStatus.status == 'failed') {
        final error = taskStatus.error?.trim();
        _showMessage(
          context,
          '任务失败: ${error?.isNotEmpty == true ? error : taskId}',
        );
        return;
      }

      _showMessage(context, '任务状态: ${taskStatus.status}');
    } catch (error) {
      if (!context.mounted) return;
      if (dialogShown && rootNavigator.canPop()) {
        rootNavigator.pop();
      }
      final message = _formatUploadError(error);
      _showMessage(context, '查询任务失败: $message');
    }
  }
}
