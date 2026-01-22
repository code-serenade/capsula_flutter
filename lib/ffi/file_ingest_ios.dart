import 'dart:ffi' as ffi;
import 'dart:io' show Platform;

import 'package:ffi/ffi.dart';

class FileIngestIos {
  FileIngestIos._(this._lib)
      : _convert = _lib.lookupFunction<_ConvertNative, _ConvertDart>(
          'file_ingest_md_convert',
        ),
        _free = _lib.lookupFunction<_FreeNative, _FreeDart>(
          'file_ingest_md_free',
        );

  static FileIngestIos? _instance;

  static FileIngestIos instance() {
    if (!Platform.isIOS) {
      throw UnsupportedError('FileIngestIos only supports iOS');
    }
    return _instance ??= FileIngestIos._(ffi.DynamicLibrary.process());
  }

  final ffi.DynamicLibrary _lib;
  final _ConvertDart _convert;
  final _FreeDart _free;

  String convertToMarkdown({
    required String fileType,
    required String inputPath,
    required String outputDir,
  }) {
    final fileTypePtr = fileType.toNativeUtf8();
    final inputPtr = inputPath.toNativeUtf8();
    final outputPtr = outputDir.toNativeUtf8();
    final outPathPtr = calloc<ffi.Pointer<Utf8>>();
    final outErrPtr = calloc<ffi.Pointer<Utf8>>();

    try {
      final code = _convert(fileTypePtr, inputPtr, outputPtr, outPathPtr, outErrPtr);
      if (code == 0) {
        final pathPtr = outPathPtr.value;
        final path = pathPtr == ffi.nullptr ? '' : pathPtr.toDartString();
        if (pathPtr != ffi.nullptr) {
          _free(pathPtr.cast());
        }
        return path;
      }

      final errPtr = outErrPtr.value;
      final message = errPtr == ffi.nullptr ? 'unknown error' : errPtr.toDartString();
      if (errPtr != ffi.nullptr) {
        _free(errPtr.cast());
      }
      throw Exception('file_ingest_ios error ($code): $message');
    } finally {
      malloc.free(fileTypePtr);
      malloc.free(inputPtr);
      malloc.free(outputPtr);
      calloc.free(outPathPtr);
      calloc.free(outErrPtr);
    }
  }
}

typedef _ConvertNative = ffi.Int32 Function(
  ffi.Pointer<Utf8>,
  ffi.Pointer<Utf8>,
  ffi.Pointer<Utf8>,
  ffi.Pointer<ffi.Pointer<Utf8>>,
  ffi.Pointer<ffi.Pointer<Utf8>>,
);

typedef _ConvertDart = int Function(
  ffi.Pointer<Utf8>,
  ffi.Pointer<Utf8>,
  ffi.Pointer<Utf8>,
  ffi.Pointer<ffi.Pointer<Utf8>>,
  ffi.Pointer<ffi.Pointer<Utf8>>,
);

typedef _FreeNative = ffi.Void Function(ffi.Pointer<ffi.Char>);

typedef _FreeDart = void Function(ffi.Pointer<ffi.Char>);
