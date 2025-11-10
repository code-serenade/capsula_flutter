import 'sandbox_service_types.dart';

class SandboxService {
  SandboxService._();

  static final SandboxService instance = SandboxService._();

  SandboxPaths get paths => throw UnsupportedError(
        'SandboxService is not supported on this platform.',
      );

  bool get isInitialized => false;

  Future<SandboxPaths> initialize() async {
    throw UnsupportedError('SandboxService is not supported on this platform.');
  }

  String resolvePath(String relativePath) {
    throw UnsupportedError('SandboxService is not supported on this platform.');
  }

  Never _unsupported() => throw UnsupportedError(
        'SandboxService is not supported on this platform.',
      );

  dynamic fileFor(String relativePath) => _unsupported();

  Future<dynamic> writeTextFile({
    required String relativeDirectory,
    required String fileName,
    required String contents,
  }) async => _unsupported();

  Future<dynamic> copyIntoSandbox({
    required dynamic source,
    required String relativeDirectory,
    String? fileName,
  }) async => _unsupported();
}
