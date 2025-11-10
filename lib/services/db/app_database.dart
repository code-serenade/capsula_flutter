import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import '../storage/sandbox_service.dart';
import 'app_database_connection_stub.dart'
    if (dart.library.html) 'app_database_connection_web.dart'
    if (dart.library.io) 'app_database_connection_io.dart';
import 'tables/health_asset/health_asset_table.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [HealthAssetEntries])
class AppDatabase extends _$AppDatabase {
  AppDatabase._(super.executor);

  static AppDatabase? _instance;

  static AppDatabase? get instanceOrNull => _instance;

  static Future<AppDatabase> ensureInstance({
    SandboxService? sandboxService,
  }) async {
    final existing = _instance;
    if (existing != null) {
      return existing;
    }
    final executor = await _openConnection(sandboxService: sandboxService);
    final database = AppDatabase._(executor);
    _instance = database;
    return database;
  }

  @visibleForTesting
  static AppDatabase openForTesting(QueryExecutor executor) {
    final db = AppDatabase._(executor);
    _instance = db;
    return db;
  }

  static Future<QueryExecutor> _openConnection({
    SandboxService? sandboxService,
  }) => createDriftExecutor(sandboxService: sandboxService);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 1) {
        await m.createAll();
      }
    },
  );
}
