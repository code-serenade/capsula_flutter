import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../models/health_asset.dart';
import '../storage/sandbox_service.dart';

class HealthAssetDatabase {
  HealthAssetDatabase._();

  static final HealthAssetDatabase instance = HealthAssetDatabase._();

  Database? _database;

  Future<void> initialize({SandboxService? sandboxService}) async {
    if (_database != null) {
      return;
    }

    final service = sandboxService ?? SandboxService.instance;
    final paths = service.isInitialized ? service.paths : await service.initialize();
    final dbPath = p.join(paths.db, 'app_data.db');

    if (!kIsWeb && (Platform.isLinux || Platform.isWindows || Platform.isMacOS)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    _database = await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(_createHealthAssetTableSql);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 1) {
          await db.execute(_createHealthAssetTableSql);
        }
      },
    );
  }

  static const _createHealthAssetTableSql = '''
  CREATE TABLE IF NOT EXISTS health_asset (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    filename TEXT NOT NULL,
    path TEXT NOT NULL,
    mime TEXT,
    size_bytes INTEGER,
    hash_sha256 TEXT,
    data_source TEXT,
    data_type TEXT NOT NULL DEFAULT 'other',
    note TEXT,
    tags TEXT,
    metadata_json TEXT,
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL
  );
  ''';

  Future<Database> _requireDb() async {
    final db = _database;
    if (db != null) {
      return db;
    }
    await initialize();
    final initialized = _database;
    if (initialized == null) {
      throw StateError('HealthAssetDatabase failed to initialize');
    }
    return initialized;
  }

  Future<int> insertAsset(HealthAsset asset) async {
    final db = await _requireDb();
    return db.insert('health_asset', asset.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> updateAsset(HealthAsset asset) async {
    if (asset.id == null) {
      throw ArgumentError('Cannot update HealthAsset without an id');
    }
    final db = await _requireDb();
    return db.update(
      'health_asset',
      asset.toMap(),
      where: 'id = ?',
      whereArgs: [asset.id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> deleteAsset(int id) async {
    final db = await _requireDb();
    return db.delete('health_asset', where: 'id = ?', whereArgs: [id]);
  }

  Future<HealthAsset?> getAsset(int id) async {
    final db = await _requireDb();
    final rows = await db.query('health_asset', where: 'id = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) {
      return null;
    }
    return HealthAsset.fromMap(rows.first);
  }

  Future<List<HealthAsset>> fetchAssets({String? keyword, List<String>? tags}) async {
    final db = await _requireDb();
    final whereClauses = <String>[];
    final whereArgs = <Object?>[];

    if (keyword != null && keyword.trim().isNotEmpty) {
      final pattern = '%${keyword.trim()}%';
      whereClauses.add('('
          'filename LIKE ? OR '
          'note LIKE ? OR '
          'tags LIKE ?'
          ')');
      whereArgs..add(pattern)..add(pattern)..add(pattern);
    }

    if (tags != null && tags.isNotEmpty) {
      for (final tag in tags) {
        whereClauses.add('tags LIKE ?');
        whereArgs.add('%$tag%');
      }
    }

    final rows = await db.query(
      'health_asset',
      where: whereClauses.isEmpty ? null : whereClauses.join(' AND '),
      whereArgs: whereClauses.isEmpty ? null : whereArgs,
      orderBy: 'updated_at DESC',
    );

    return rows.map(HealthAsset.fromMap).toList();
  }
}
