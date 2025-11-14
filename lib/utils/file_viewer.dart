import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';

/// Supported document categories for the universal file reader.
enum DocumentKind { pdf, word, excel, ppt, text, image, other }

/// Utilities for opening files with system default applications using `open_filex`.
class FileViewerUtils {
  const FileViewerUtils._();

  /// Opens a file with the system's default application.
  ///
  /// Returns a [Future<bool>] indicating whether the file was opened successfully.
  /// This works on all platforms (Android, iOS, macOS, Windows, Linux, etc.)
  static Future<bool> openFile(String filePath) async {
    try {
      final result = await OpenFilex.open(filePath);
      // OpenResultType: done, fileNotFound, noAppToOpen, permissionDenied, error
      return result.type == ResultType.done;
    } catch (e) {
      return false;
    }
  }

  /// Returns a simple widget for backward compatibility.
  ///
  /// Note: This now opens files with system default apps instead of in-app preview.
  /// The widget shown is just a placeholder that opens the file when displayed.
  static Widget viewer({
    required String filePath,
    Function(bool success)? onOpen,
    Widget? loadingWidget,
    Widget? unsupportedWidget,
  }) {
    return FutureBuilder<bool>(
      future: openFile(filePath),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return loadingWidget ??
              const Center(child: CircularProgressIndicator());
        }

        final success = snapshot.data ?? false;

        // Call the onOpen callback
        if (onOpen != null) {
          Future.microtask(() => onOpen(success));
        }

        if (success) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    size: 48,
                    color: Colors.green,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '文件已在系统默认应用中打开',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '文件路径: $filePath',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return unsupportedWidget ??
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.orange,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '无法打开文件',
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '文件路径: $filePath',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '请确保已安装可以打开此类型文件的应用',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
      },
    );
  }

  /// Determines the [DocumentKind] based on the file extension.
  static DocumentKind inferKind(String path) {
    final ext = _extension(path);
    if (ext == null) return DocumentKind.other;
    if (_wordExtensions.contains(ext)) return DocumentKind.word;
    if (_excelExtensions.contains(ext)) return DocumentKind.excel;
    if (_pptExtensions.contains(ext)) return DocumentKind.ppt;
    if (_pdfExtensions.contains(ext)) return DocumentKind.pdf;
    if (_textExtensions.contains(ext)) return DocumentKind.text;
    if (_imageExtensions.contains(ext)) return DocumentKind.image;
    return DocumentKind.other;
  }

  /// Whether the plugin can open files with the given extension.
  ///
  /// Note: open_filex can attempt to open any file type, so this returns true
  /// for common document types. The actual opening depends on installed apps.
  static bool isSupported(String path) {
    final ext = _extension(path);
    if (ext == null) return false;
    return _supportedExtensions.contains(ext);
  }

  static String? _extension(String path) {
    final parts = path.split('.');
    if (parts.length < 2) return null;
    return parts.last.toLowerCase();
  }

  static const Set<String> _pdfExtensions = {'pdf'};
  static const Set<String> _wordExtensions = {'doc', 'docx'};
  static const Set<String> _excelExtensions = {'xls', 'xlsx', 'xlsm'};
  static const Set<String> _pptExtensions = {'ppt', 'pptx'};
  static const Set<String> _textExtensions = {'txt', 'rtf'};
  static const Set<String> _imageExtensions = {
    'png',
    'jpg',
    'jpeg',
    'bmp',
    'gif',
  };

  static const Set<String> _supportedExtensions = {
    ..._pdfExtensions,
    ..._wordExtensions,
    ..._excelExtensions,
    ..._pptExtensions,
    ..._textExtensions,
    ..._imageExtensions,
  };
}
