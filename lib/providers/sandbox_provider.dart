import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../services/storage/sandbox_service.dart';

part 'sandbox_provider.g.dart';

@riverpod
SandboxService sandboxService(Ref ref) {
  return SandboxService.instance;
}

@riverpod
Future<SandboxPaths> sandboxPaths(Ref ref) async {
  final service = ref.watch(sandboxServiceProvider);
  return service.initialize();
}
