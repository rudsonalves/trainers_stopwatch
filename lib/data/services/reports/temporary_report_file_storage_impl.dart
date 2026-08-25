import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '/core/result/result.dart';
import '/domain/common/report/services/temporary_report_file_storage.dart';

class TemporaryReportFileStorageImpl implements TemporaryReportFileStorage {
  final Future<Directory> Function() _directoryProvider;
  final String Function() _uniqueSuffix;

  TemporaryReportFileStorageImpl({
    Future<Directory> Function()? directoryProvider,
    String Function()? uniqueSuffix,
  })  : _directoryProvider = directoryProvider ?? getTemporaryDirectory,
        _uniqueSuffix = uniqueSuffix ?? _defaultUniqueSuffix;

  @override
  AsyncResult<TemporaryReportFile> write({
    required String suggestedName,
    required String mimeType,
    required Uint8List bytes,
  }) async {
    final safeName = path.basename(suggestedName.trim());

    if (safeName.isEmpty || safeName == '.' || safeName == '..') {
      return Failure(
        AppError(
          code: AppErrorCode.invalidData,
          message: 'A temporary report file requires a valid name.',
          details: suggestedName,
        ),
      );
    }

    if (mimeType.trim().isEmpty) {
      return const Failure(
        AppError(
          code: AppErrorCode.invalidData,
          message: 'A temporary report file requires a MIME type.',
        ),
      );
    }

    try {
      final directory = await _directoryProvider();
      final extension = path.extension(safeName);
      final baseName = path.basenameWithoutExtension(safeName);
      final uniqueName = '${baseName}_${_uniqueSuffix()}$extension';
      final output = File(path.join(directory.path, uniqueName));

      await output.writeAsBytes(bytes, flush: true);

      return Success(
        TemporaryReportFile(
          path: output.path,
          name: uniqueName,
          mimeType: mimeType,
        ),
      );
    } catch (error) {
      return Failure(
        AppError(
          code: AppErrorCode.storageWriteFailed,
          message: 'Temporary report file could not be written.',
          details: error,
        ),
      );
    }
  }

  @override
  AsyncResult<Unit> delete(TemporaryReportFile file) async {
    try {
      final output = File(file.path);

      if (await output.exists()) {
        await output.delete();
      }

      return const Success(unit);
    } catch (error) {
      return Failure(
        AppError(
          code: AppErrorCode.storageWriteFailed,
          message: 'Temporary report file could not be deleted.',
          details: error,
        ),
      );
    }
  }
}

var _temporaryFileSequence = 0;

String _defaultUniqueSuffix() {
  final timestamp = DateTime.now().microsecondsSinceEpoch;
  final sequence = _temporaryFileSequence++;
  return '${timestamp}_$sequence';
}
