import 'dart:io';

import 'package:capsula_flutter/models/health_asset.dart';
import 'package:capsula_flutter/models/health_data_model.dart';
import 'package:capsula_flutter/services/db/app_database.dart';
import 'package:capsula_flutter/services/db/tables/health_asset/health_asset_table.dart';
import 'package:capsula_flutter/services/storage/sandbox_service_stub.dart';
import 'package:crypto/crypto.dart';
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
    final stats = await _statFile(copied);
    final relativePath = p.relative(copied.path, from: service.paths.root);
    final now = DateTime.now();
    final trimmedDisplayName = displayName?.trim();
    final asset = HealthAsset(
      filename: (trimmedDisplayName?.isNotEmpty == true)
          ? trimmedDisplayName!
          : p.basename(source.path),
      path: relativePath,
      mime: _inferMime(source.path),
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
