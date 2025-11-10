import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'sandbox_service_types.dart';

class SandboxService {
  SandboxService._();

  static final SandboxService instance = SandboxService._();

  SandboxPaths? _paths;

  bool get isInitialized => _paths != null;

  SandboxPaths get paths {
    final current = _paths;
    if (current == null) {
      throw StateError('SandboxService has not been initialized');
    }
    return current;
  }

  Future<SandboxPaths> initialize() async {
    if (_paths != null) {
      return _paths!;
    }

    final supportDir = await _resolveBaseDirectory();
    final rootDir = await _ensureDirectory(p.join(supportDir.path, 'AppSandbox'));
    final dbDir = await _ensureDirectory(p.join(rootDir.path, 'db'));
    final filesDir = await _ensureDirectory(p.join(rootDir.path, 'files'));
    final imagesDir = await _ensureDirectory(p.join(filesDir.path, 'images'));
    final audioDir = await _ensureDirectory(p.join(filesDir.path, 'audio'));
    final docDir = await _ensureDirectory(p.join(filesDir.path, 'doc'));
    final pdfDir = await _ensureDirectory(p.join(docDir.path, 'pdf'));
    final wordDir = await _ensureDirectory(p.join(docDir.path, 'word'));
    final excelDir = await _ensureDirectory(p.join(docDir.path, 'excel'));
    final configDir = await _ensureDirectory(p.join(rootDir.path, 'config'));
    final secureDir = await _ensureDirectory(p.join(rootDir.path, 'secure'));
    final keyStoreDir = await _ensureDirectory(p.join(secureDir.path, 'key_store'));

    final settingsFile = File(p.join(configDir.path, 'settings.json'));
    if (!settingsFile.existsSync()) {
      await settingsFile.writeAsString('{}');
    }

    _paths = SandboxPaths(
      root: rootDir.path,
      db: dbDir.path,
      files: filesDir.path,
      images: imagesDir.path,
      audio: audioDir.path,
      doc: docDir.path,
      docPdf: pdfDir.path,
      docWord: wordDir.path,
      docExcel: excelDir.path,
      config: configDir.path,
      secure: secureDir.path,
      keyStore: keyStoreDir.path,
      settingsFile: settingsFile.path,
    );
    return _paths!;
  }

  Future<Directory> _resolveBaseDirectory() async {
    try {
      return await getApplicationSupportDirectory();
    } catch (_) {
      return await getTemporaryDirectory();
    }
  }

  Future<Directory> _ensureDirectory(String path) async {
    final dir = Directory(path);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  String resolvePath(String relativePath) {
    return p.join(paths.root, relativePath);
  }

  File fileFor(String relativePath) {
    return File(resolvePath(relativePath));
  }

  Future<File> writeTextFile({
    required String relativeDirectory,
    required String fileName,
    required String contents,
  }) async {
    final targetDirectory = Directory(p.join(paths.root, relativeDirectory));
    if (!await targetDirectory.exists()) {
      await targetDirectory.create(recursive: true);
    }
    final targetFile = File(p.join(targetDirectory.path, fileName));
    await targetFile.writeAsString(contents);
    return targetFile;
  }

  Future<File> copyIntoSandbox({
    required File source,
    required String relativeDirectory,
    String? fileName,
  }) async {
    final targetDirectory = Directory(p.join(paths.root, relativeDirectory));
    if (!await targetDirectory.exists()) {
      await targetDirectory.create(recursive: true);
    }
    final destination = File(p.join(targetDirectory.path, fileName ?? p.basename(source.path)));
    return source.copy(destination.path);
  }
}
