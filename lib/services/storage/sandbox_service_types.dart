class SandboxPaths {
  const SandboxPaths({
    required this.root,
    required this.db,
    required this.files,
    required this.images,
    required this.audio,
    required this.doc,
    required this.docPdf,
    required this.docWord,
    required this.docExcel,
    required this.config,
    required this.secure,
    required this.keyStore,
    required this.settingsFile,
  });

  final String root;
  final String db;
  final String files;
  final String images;
  final String audio;
  final String doc;
  final String docPdf;
  final String docWord;
  final String docExcel;
  final String config;
  final String secure;
  final String keyStore;
  final String settingsFile;
}
