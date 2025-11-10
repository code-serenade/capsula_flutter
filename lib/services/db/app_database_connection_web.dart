import 'package:drift/drift.dart';
import 'package:drift/web.dart';

import '../storage/sandbox_service.dart';

Future<QueryExecutor> createDriftExecutor({
  SandboxService? sandboxService,
}) async {
  return WebDatabase('capsula_app_data');
}
