import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

import 'package:capsula_flutter/ffi/file_ingest_ios.dart';

class FileIngestTestPage extends StatefulWidget {
  const FileIngestTestPage({super.key});

  @override
  State<FileIngestTestPage> createState() => _FileIngestTestPageState();
}

class _FileIngestTestPageState extends State<FileIngestTestPage> {
  String? _inputPath;
  String? _outputPath;
  String? _error;
  bool _busy = false;

  Future<void> _pickPdf() async {
    setState(() {
      _error = null;
      _outputPath = null;
    });
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    final path = result?.files.single.path;
    if (path == null || path.isEmpty) {
      return;
    }
    setState(() {
      _inputPath = path;
    });
  }

  Future<void> _convert() async {
    if (_inputPath == null) {
      setState(() => _error = 'Pick a PDF first.');
      return;
    }
    if (!Platform.isIOS) {
      setState(() => _error = 'This test only works on iOS.');
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
      _outputPath = null;
    });

    try {
      final docs = await getApplicationDocumentsDirectory();
      final outDir = Directory('${docs.path}/md');
      final output = FileIngestIos.instance().convertToMarkdown(
        fileType: 'pdf',
        inputPath: _inputPath!,
        outputDir: outDir.path,
      );
      setState(() {
        _outputPath = output;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _busy = false);
    }
  }

  Future<void> _openOutput() async {
    final path = _outputPath;
    if (path == null || path.isEmpty) {
      return;
    }
    await OpenFilex.open(path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PDF -> Markdown (iOS FFI)')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Input: ${_inputPath ?? "-"}'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ElevatedButton(
                  onPressed: _busy ? null : _pickPdf,
                  child: const Text('Pick PDF'),
                ),
                ElevatedButton(
                  onPressed: _busy ? null : _convert,
                  child: const Text('Convert'),
                ),
                OutlinedButton(
                  onPressed: _busy ? null : _openOutput,
                  child: const Text('Open Output'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_busy) const LinearProgressIndicator(),
            const SizedBox(height: 12),
            Text('Output: ${_outputPath ?? "-"}'),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],
          ],
        ),
      ),
    );
  }
}
