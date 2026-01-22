import 'dart:io';

import 'package:capsula_flutter/models/health_asset.dart';
import 'package:capsula_flutter/models/health_data_model.dart';
import 'package:capsula_flutter/services/db/app_database.dart';
import 'package:capsula_flutter/services/db/tables/health_asset/health_asset_table.dart';
import 'package:capsula_flutter/services/storage/sandbox_service.dart';
import 'package:capsula_flutter/ffi/file_ingest_ios.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

class HealthAssetRepository {
  HealthAssetRepository({
    HealthAssetDao? dao,
    AppDatabase? database,
    SandboxService? sandboxService,
  }) : _dao = dao,
       _database = database,
       _sandboxService = sandboxService ?? SandboxService.instance;

  HealthAssetDao? _dao;
  final AppDatabase? _database;
  final SandboxService _sandboxService;

  Future<HealthAssetDao> _requireDao() async {
    final existing = _dao;
    if (existing != null) {
      return existing;
    }
    final db = _database ?? await AppDatabase.ensureInstance();
    final dao = HealthAssetDao(db);
    _dao = dao;
    return dao;
  }

  Future<List<HealthAsset>> fetchAssets({
    String? keyword,
    List<String>? tags,
  }) async {
    final dao = await _requireDao();
    return dao.fetchAssets(keyword: keyword, tags: tags);
  }

  Future<HealthAsset> createManualEntry(HealthAssetDraft draft) async {
    final service = _sandboxService;
    if (!service.isInitialized) {
      await service.initialize();
    }
    final now = DateTime.now();
    final relativeDir = p.join('files', 'doc', 'manual');
    final sanitizedTitle = _sanitizeFileName(draft.title);
    final fileBaseName = sanitizedTitle.isEmpty ? 'note' : sanitizedTitle;
    final fileName = '${_formatTimestamp(now)}_$fileBaseName.txt';
    final buffer = StringBuffer()
      ..writeln('# ${draft.title}')
      ..writeln('Created: ${now.toIso8601String()}')
      ..writeln('Source: ${draft.dataSource.name}')
      ..writeln()
      ..writeln(draft.content ?? '')
      ..writeln();

    final file = await service.writeTextFile(
      relativeDirectory: relativeDir,
      fileName: fileName,
      contents: buffer.toString(),
    );

    final stats = await _statFile(file);
    final relativePath = p.relative(file.path, from: service.paths.root);
    final asset = HealthAsset(
      filename: draft.title.isEmpty ? fileName : draft.title,
      path: relativePath,
      mime: 'text/plain',
      sizeBytes: stats.size,
      hashSha256: stats.sha256,
      dataSource: draft.dataSource,
      dataType: draft.dataType,
      note: draft.note ?? draft.content,
      tags: draft.normalizedTags,
      metadata: {
        ...?draft.metadata,
        'path': relativePath,
        'fileName': fileName,
        'createdBy': 'manual_entry',
        if (draft.content != null && draft.content!.isNotEmpty)
          'content': draft.content,
      },
      createdAt: now,
      updatedAt: now,
    );

    final dao = await _requireDao();
    final id = await dao.insertAsset(asset);
    return asset.copyWith(id: id);
  }

  Future<HealthAsset> importFile(
    File source, {
    required DataSource dataSource,
    HealthDataType dataType = HealthDataType.other,
    List<String> tags = const [],
    String? note,
    Map<String, dynamic>? metadata,
    String? displayName,
  }) async {
    final service = _sandboxService;
    if (!service.isInitialized) {
      await service.initialize();
    }

    final relativeDir = _resolveDirectoryForMime(_inferMime(source.path));
    final copied = await service.copyIntoSandbox(
      source: source,
      relativeDirectory: relativeDir,
    );
    final mime = _inferMime(source.path);
    final stats = await _statFile(copied);
    final relativePath = p.relative(copied.path, from: service.paths.root);
    final markdownRelativePath = await _convertToMarkdownIfSupported(
      file: copied,
      mime: mime,
      service: service,
    );
    final now = DateTime.now();
    final trimmedDisplayName = displayName?.trim();
    final asset = HealthAsset(
      filename: (trimmedDisplayName?.isNotEmpty == true)
          ? trimmedDisplayName!
          : p.basename(source.path),
      path: relativePath,
      mime: mime,
      sizeBytes: stats.size,
      hashSha256: stats.sha256,
      dataSource: dataSource,
      dataType: dataType,
      note: note,
      tags: tags,
      metadata: {
        ...?metadata,
        'path': relativePath,
        'originalPath': source.path,
        'copiedAt': now.toIso8601String(),
        if (markdownRelativePath != null) 'markdownPath': markdownRelativePath,
      },
      createdAt: now,
      updatedAt: now,
    );

    final dao = await _requireDao();
    final id = await dao.insertAsset(asset);
    return asset.copyWith(id: id);
  }

  Future<void> deleteAsset(int id) async {
    final dao = await _requireDao();
    await dao.deleteAsset(id);
  }

  Future<void> deleteAssetWithFiles(HealthAsset asset) async {
    final service = _sandboxService;
    if (!service.isInitialized) {
      await service.initialize();
    }

    final markdownPath = asset.metadata?['markdownPath'];
    final paths = <String>[
      asset.path,
      if (markdownPath is String && markdownPath.trim().isNotEmpty) markdownPath,
    ];

    final failures = <String>[];
    for (final relativePath in paths) {
      try {
        final file = service.fileFor(relativePath);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (_) {
        failures.add(relativePath);
      }
    }

    if (failures.isNotEmpty) {
      throw Exception('删除文件失败: ${failures.join(", ")}');
    }

    final id = asset.id;
    if (id != null) {
      final dao = await _requireDao();
      await dao.deleteAsset(id);
    }
  }

  String _sanitizeFileName(String value) {
    final sanitized = value.toLowerCase().replaceAll(
      RegExp(r'[^a-z0-9]+'),
      '_',
    );
    return sanitized
        .replaceAll(RegExp('_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
  }

  String _formatTimestamp(DateTime time) {
    final y = time.year.toString().padLeft(4, '0');
    final m = time.month.toString().padLeft(2, '0');
    final d = time.day.toString().padLeft(2, '0');
    final h = time.hour.toString().padLeft(2, '0');
    final min = time.minute.toString().padLeft(2, '0');
    final s = time.second.toString().padLeft(2, '0');
    return '$y$m${d}_$h$min$s';
  }

  String _resolveDirectoryForMime(String mime) {
    if (mime.startsWith('image/')) {
      return p.join('files', 'images');
    }
    if (mime.startsWith('audio/')) {
      return p.join('files', 'audio');
    }
    if (mime == 'application/pdf') {
      return p.join('files', 'doc', 'pdf');
    }
    if (mime.contains('word') ||
        mime == 'application/msword' ||
        mime ==
            'application/vnd.openxmlformats-officedocument.wordprocessingml.document') {
      return p.join('files', 'doc', 'word');
    }
    if (mime.contains('excel') ||
        mime == 'application/vnd.ms-excel' ||
        mime ==
            'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet') {
      return p.join('files', 'doc', 'excel');
    }
    return p.join('files', 'doc');
  }

  String _inferMime(String filePath) {
    final extension = p.extension(filePath).toLowerCase();
    switch (extension) {
      case '.png':
        return 'image/png';
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.heic':
        return 'image/heic';
      case '.gif':
        return 'image/gif';
      case '.mp3':
        return 'audio/mpeg';
      case '.wav':
        return 'audio/wav';
      case '.aac':
        return 'audio/aac';
      case '.pdf':
        return 'application/pdf';
      case '.doc':
      case '.docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case '.xls':
      case '.xlsx':
        return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      case '.txt':
        return 'text/plain';
      default:
        return 'application/octet-stream';
    }
  }

  Future<String?> _convertToMarkdownIfSupported({
    required File file,
    required String mime,
    required SandboxService service,
  }) async {
    if (!Platform.isIOS) {
      return null;
    }
    if (mime != 'application/pdf') {
      return null;
    }

    final outputDir = Directory(p.join(service.paths.doc, 'md'));
    if (!await outputDir.exists()) {
      await outputDir.create(recursive: true);
    }

    try {
      final outputPath = FileIngestIos.instance().convertToMarkdown(
        fileType: 'pdf',
        inputPath: file.path,
        outputDir: outputDir.path,
      );
      if (outputPath.isEmpty) {
        return null;
      }
      return p.relative(outputPath, from: service.paths.root);
    } catch (error) {
      debugPrint('Markdown conversion failed: $error');
      return null;
    }
  }

  Future<_FileStats> _statFile(File file) async {
    final bytes = await file.readAsBytes();
    final digest = sha256.convert(bytes).toString();
    return _FileStats(bytes.length, digest);
  }
}

class _FileStats {
  const _FileStats(this.size, this.sha256);

  final int size;
  final String sha256;
}
