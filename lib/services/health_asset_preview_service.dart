import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../models/health_asset.dart';
import '../providers/sandbox/sandbox_provider.dart';
import '../utils/file_viewer.dart';
import '../widgets/health_data/unsupported_file_view.dart';

final healthAssetPreviewServiceProvider = Provider<HealthAssetPreviewService>(
  (ref) => HealthAssetPreviewService(ref: ref),
);

class HealthAssetPreviewService {
  HealthAssetPreviewService({required this.ref});

  final Ref ref;

  Future<void> preview(
    BuildContext context,
    HealthAsset asset,
  ) async {
    try {
      final sandbox = ref.read(sandboxServiceProvider);
      final file = sandbox.fileFor(asset.path) as File;
      if (!await file.exists()) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('文件不存在或已被删除')),
          );
        }
        return;
      }

      final handledBySystem = await _tryOpenWithSystemExplorer(file);
      if (handledBySystem) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('已在系统中打开 ${file.path}')),
          );
        }
        return;
      }

      final supported = FileViewerUtils.isSupported(file.path);
      if (!supported) {
        if (!context.mounted) return;
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('暂不支持预览'),
            content: Text('请通过系统文件管理器查看文件:\n${file.path}'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('知道了'),
              ),
            ],
          ),
        );
        return;
      }

      if (!context.mounted) return;
      await showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          final size = MediaQuery.of(context).size;
          return Dialog(
            insetPadding: const EdgeInsets.all(16),
            child: SizedBox(
              width: size.width * 0.9,
              height: size.height * 0.8,
              child: FileViewerUtils.viewer(
                filePath: file.path,
                onOpen: (success) {
                  if (!success && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('文件预览失败')),
                    );
                  }
                },
                loadingWidget:
                    const Center(child: CircularProgressIndicator()),
                unsupportedWidget: UnsupportedFileView(path: file.path),
              ),
            ),
          );
        },
      );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('无法打开文件: $error')),
      );
    }
  }

  Future<bool> _tryOpenWithSystemExplorer(File file) async {
    try {
      if (Platform.isMacOS) {
        final reveal = await Process.run('open', ['-R', file.path]);
        if (reveal.exitCode == 0) {
          await Process.run('open', [file.path]);
          return true;
        }
        final openDirect = await Process.run('open', [file.path]);
        return openDirect.exitCode == 0;
      }
      if (Platform.isWindows) {
        final result =
            await Process.run('explorer', ['/select,${file.path}']);
        return result.exitCode == 0;
      }
      if (Platform.isLinux) {
        final result = await Process.run('xdg-open', [file.path]);
        return result.exitCode == 0;
      }
    } catch (_) {
      // 系统调用失败时回退到内置预览。
    }
    return false;
  }
}
