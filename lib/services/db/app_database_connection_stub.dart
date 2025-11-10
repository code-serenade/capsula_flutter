import 'package:drift/drift.dart';

import '../storage/sandbox_service.dart';

Future<QueryExecutor> createDriftExecutor({
  SandboxService? sandboxService,
}) =>
    Future.error(
      UnsupportedError('Local database is not supported on this platform.'),
    );
