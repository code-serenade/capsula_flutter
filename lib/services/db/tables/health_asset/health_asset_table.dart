import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../../models/health_asset.dart';
import '../../app_database.dart';

part 'health_asset_table.g.dart';

class HealthAssetEntries extends Table {
  @override
  String get tableName => 'health_asset';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get filename => text()();
  TextColumn get path => text()();
  TextColumn get mime => text().nullable()();
  IntColumn get sizeBytes => integer().named('size_bytes').nullable()();
  TextColumn get hashSha256 => text().named('hash_sha256').nullable()();
  TextColumn get dataSource => text().named('data_source')();
  TextColumn get dataType =>
      text().named('data_type').withDefault(const Constant('other'))();
  TextColumn get note => text().nullable()();
  TextColumn get tags => text().nullable()();
  TextColumn get metadataJson => text().named('metadata_json').nullable()();
  TextColumn get createdAt => text().named('created_at')();
  TextColumn get updatedAt => text().named('updated_at')();
}

@DriftAccessor(tables: [HealthAssetEntries])
class HealthAssetDao extends DatabaseAccessor<AppDatabase>
    with _$HealthAssetDaoMixin {
  HealthAssetDao(super.db);

  HealthAssetEntriesCompanion _toCompanion(
    HealthAsset asset, {
    bool includeId = false,
  }) {
    return HealthAssetEntriesCompanion(
      id: includeId && asset.id != null
          ? Value(asset.id!)
          : const Value.absent(),
      filename: Value(asset.filename),
      path: Value(asset.path),
      mime: Value(asset.mime),
      sizeBytes: Value(asset.sizeBytes),
      hashSha256: Value(asset.hashSha256),
      dataSource: Value(asset.dataSource.name),
      dataType: Value(asset.dataType.name),
      note: Value(asset.note),
      tags: Value(asset.tags.join(',')),
      metadataJson: Value(
        asset.metadata == null ? null : jsonEncode(asset.metadata),
      ),
      createdAt: Value(asset.createdAt.toIso8601String()),
      updatedAt: Value(asset.updatedAt.toIso8601String()),
    );
  }

  HealthAsset _fromEntry(HealthAssetEntry entry) {
    return HealthAsset.fromMap({
      'id': entry.id,
      'filename': entry.filename,
      'path': entry.path,
      'mime': entry.mime,
      'size_bytes': entry.sizeBytes,
      'hash_sha256': entry.hashSha256,
      'data_source': entry.dataSource,
      'data_type': entry.dataType,
      'note': entry.note,
      'tags': entry.tags,
      'metadata_json': entry.metadataJson,
      'created_at': entry.createdAt,
      'updated_at': entry.updatedAt,
    });
  }

  Future<int> insertAsset(HealthAsset asset) {
    return into(healthAssetEntries).insert(_toCompanion(asset));
  }

  Future<int> updateAsset(HealthAsset asset) {
    final assetId = asset.id;
    if (assetId == null) {
      throw ArgumentError('Cannot update HealthAsset without an id');
    }
    return (update(
      healthAssetEntries,
    )..where((tbl) => tbl.id.equals(assetId))).write(_toCompanion(asset));
  }

  Future<int> deleteAsset(int id) {
    return (delete(healthAssetEntries)..where((tbl) => tbl.id.equals(id))).go();
  }

  Future<HealthAsset?> getAsset(int id) async {
    final query = select(healthAssetEntries)
      ..where((tbl) => tbl.id.equals(id))
      ..limit(1);
    final entry = await query.getSingleOrNull();
    if (entry == null) {
      return null;
    }
    return _fromEntry(entry);
  }

  Future<List<HealthAsset>> fetchAssets({
    String? keyword,
    List<String>? tags,
  }) async {
    final query = select(healthAssetEntries);

    final trimmedKeyword = keyword?.trim();
    if (trimmedKeyword != null && trimmedKeyword.isNotEmpty) {
      final pattern = '%$trimmedKeyword%';
      query.where(
        (tbl) =>
            tbl.filename.like(pattern) |
            tbl.note.like(pattern) |
            tbl.tags.like(pattern),
      );
    }

    if (tags != null && tags.isNotEmpty) {
      for (final tag in tags) {
        final normalized = tag.trim();
        if (normalized.isEmpty) {
          continue;
        }
        final pattern = '%$normalized%';
        query.where((tbl) => tbl.tags.like(pattern));
      }
    }

    query.orderBy([
      (tbl) => OrderingTerm(expression: tbl.updatedAt, mode: OrderingMode.desc),
    ]);

    final rows = await query.get();
    return rows.map(_fromEntry).toList();
  }
}
