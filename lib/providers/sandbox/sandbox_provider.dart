import 'package:capsula_flutter/services/storage/sandbox_service_stub.dart';
import 'package:capsula_flutter/services/storage/sandbox_service_types.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

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
