import 'dart:convert';

import 'health_data_model.dart';

class HealthAsset {
  const HealthAsset({
    this.id,
    required this.filename,
    required this.path,
    this.mime,
    this.sizeBytes,
    this.hashSha256,
    required this.dataSource,
    this.dataType = HealthDataType.other,
    this.note,
    this.tags = const [],
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  final int? id;
  final String filename;
  final String path;
  final String? mime;
  final int? sizeBytes;
  final String? hashSha256;
  final DataSource dataSource;
  final HealthDataType dataType;
  final String? note;
  final List<String> tags;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  HealthAsset copyWith({
    int? id,
    String? filename,
    String? path,
    String? mime,
    int? sizeBytes,
    String? hashSha256,
    DataSource? dataSource,
    HealthDataType? dataType,
    String? note,
    List<String>? tags,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return HealthAsset(
      id: id ?? this.id,
      filename: filename ?? this.filename,
      path: path ?? this.path,
      mime: mime ?? this.mime,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      hashSha256: hashSha256 ?? this.hashSha256,
      dataSource: dataSource ?? this.dataSource,
      dataType: dataType ?? this.dataType,
      note: note ?? this.note,
      tags: tags ?? this.tags,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory HealthAsset.fromMap(Map<String, Object?> map) {
    final tagsString = (map['tags'] as String?) ?? '';
    final metadataJson = map['metadata_json'] as String?;
    return HealthAsset(
      id: map['id'] as int?,
      filename: map['filename'] as String,
      path: map['path'] as String,
      mime: map['mime'] as String?,
      sizeBytes: map['size_bytes'] as int?,
      hashSha256: map['hash_sha256'] as String?,
      dataSource: _dataSourceFromString(map['data_source'] as String?),
      dataType: _dataTypeFromString(map['data_type'] as String?),
      note: map['note'] as String?,
      tags: tagsString
          .split(',')
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList(),
      metadata: metadataJson?.isEmpty ?? true
          ? null
          : jsonDecode(metadataJson!) as Map<String, dynamic>?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, Object?> toMap() {
    return {
      if (id != null) 'id': id,
      'filename': filename,
      'path': path,
      'mime': mime,
      'size_bytes': sizeBytes,
      'hash_sha256': hashSha256,
      'data_source': dataSource.name,
      'data_type': dataType.name,
      'note': note,
      'tags': tags.join(','),
      'metadata_json': metadata == null ? null : jsonEncode(metadata),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  HealthDataRecord toRecord() {
    final metadataContent = metadata?['content'] as String?;
    final fallbackNote = note ?? metadata?['path'] as String? ?? path;
    return HealthDataRecord(
      id: (id ?? filename).toString(),
      type: dataType,
      content: metadataContent?.isNotEmpty == true
          ? metadataContent!
          : (note?.isNotEmpty == true ? note! : filename),
      dateTime: updatedAt,
      source: dataSource,
      tags: tags
          .map(
            (tag) => HealthTag(
              id: tag,
              name: tag,
            ),
          )
          .toList(),
      notes: fallbackNote,
      metadata: metadata,
    );
  }

  static DataSource _dataSourceFromString(String? value) {
    if (value == null) {
      return DataSource.manual;
    }
    return DataSource.values.firstWhere(
      (element) => element.name == value,
      orElse: () => DataSource.manual,
    );
  }

  static HealthDataType _dataTypeFromString(String? value) {
    if (value == null) {
      return HealthDataType.other;
    }
    return HealthDataType.values.firstWhere(
      (element) => element.name == value,
      orElse: () => HealthDataType.other,
    );
  }
}

class HealthAssetDraft {
  const HealthAssetDraft({
    required this.title,
    this.note,
    this.content,
    this.dataSource = DataSource.manual,
    this.dataType = HealthDataType.other,
    this.tags = const [],
    this.metadata,
  });

  final String title;
  final String? note;
  final String? content;
  final DataSource dataSource;
  final HealthDataType dataType;
  final List<String> tags;
  final Map<String, dynamic>? metadata;

  List<String> get normalizedTags => tags
      .map((tag) => tag.trim())
      .where((tag) => tag.isNotEmpty)
      .toList();

  HealthAssetDraft copyWith({
    String? title,
    String? note,
    String? content,
    DataSource? dataSource,
    HealthDataType? dataType,
    List<String>? tags,
    Map<String, dynamic>? metadata,
  }) {
    return HealthAssetDraft(
      title: title ?? this.title,
      note: note ?? this.note,
      content: content ?? this.content,
      dataSource: dataSource ?? this.dataSource,
      dataType: dataType ?? this.dataType,
      tags: tags ?? this.tags,
      metadata: metadata ?? this.metadata,
    );
  }
}
