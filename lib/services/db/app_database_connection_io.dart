import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;

import '../storage/sandbox_service.dart';

Future<QueryExecutor> createDriftExecutor({
  SandboxService? sandboxService,
}) async {
  final service = sandboxService ?? SandboxService.instance;
  final paths = service.isInitialized ? service.paths : await service.initialize();
  final dbPath = p.join(paths.db, 'app_data.db');
  return NativeDatabase.createInBackground(File(dbPath));
}
