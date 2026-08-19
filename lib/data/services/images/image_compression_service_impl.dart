import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '/common/constants.dart';
import '/core/result/result.dart';
import 'image_compression_service.dart';
import 'models/image_selection.dart';
import 'models/prepared_user_image.dart';

typedef TemporaryDirectoryProvider = Future<Directory> Function();
typedef CompressImage = Future<XFile?> Function(
  String sourceReference,
  String targetReference, {
  required int quality,
  required int minHeight,
});

final class ImageCompressionServiceImpl implements ImageCompressionService {
  final TemporaryDirectoryProvider _temporaryDirectoryProvider;
  final CompressImage _compressImage;
  final DateTime Function() _clock;

  ImageCompressionServiceImpl({
    required TemporaryDirectoryProvider temporaryDirectoryProvider,
    required CompressImage compressImage,
    required DateTime Function() clock,
  })  : _temporaryDirectoryProvider = temporaryDirectoryProvider,
        _compressImage = compressImage,
        _clock = clock;

  factory ImageCompressionServiceImpl.platform() => ImageCompressionServiceImpl(
        temporaryDirectoryProvider: getTemporaryDirectory,
        compressImage: _compressWithPlugin,
        clock: DateTime.now,
      );

  @override
  AsyncResult<PreparedUserImage> compress(ImageSelected image) async {
    final Directory preparedDirectory;
    try {
      final temporaryDirectory = await _temporaryDirectoryProvider();
      preparedDirectory = Directory(
        path.join(temporaryDirectory.path, 'trainers_stopwatch_user_images'),
      );
      await preparedDirectory.create(recursive: true);
    } catch (error, stackTrace) {
      return Failure(
        AppError(
          code: AppErrorCode.imageStorageWriteFailed,
          message: 'Could not prepare temporary image storage.',
          details: (error: error, stackTrace: stackTrace),
        ),
      );
    }

    final String targetReference;
    try {
      targetReference = await _availableReference(
        directory: preparedDirectory,
        fileName:
            '${_clock().microsecondsSinceEpoch}-${path.basename(image.fileName)}',
      );
    } catch (error, stackTrace) {
      return Failure(
        AppError(
          code: AppErrorCode.imageStorageReadFailed,
          message: 'Could not inspect temporary image storage.',
          details: (error: error, stackTrace: stackTrace),
        ),
      );
    }

    try {
      final compressed = await _compressImage(
        image.sourceReference,
        targetReference,
        quality: 95,
        minHeight: photoImageSize.toInt(),
      );
      if (compressed == null || compressed.path.isEmpty) {
        await _removePartialFile(targetReference);
        return const Failure(
          AppError(
            code: AppErrorCode.imageCompressionFailed,
            message: 'The image compressor did not produce a file.',
          ),
        );
      }

      return Success(
        PreparedUserImage(
          temporaryReference: compressed.path,
          fileName: path.basename(compressed.path),
        ),
      );
    } catch (error, stackTrace) {
      await _removePartialFile(targetReference);
      return Failure(
        AppError(
          code: AppErrorCode.imageCompressionFailed,
          message: 'Could not compress the selected image.',
          details: (error: error, stackTrace: stackTrace),
        ),
      );
    }
  }

  Future<void> _removePartialFile(String reference) async {
    final file = File(reference);
    if (await file.exists()) {
      try {
        await file.delete();
      } on FileSystemException {
        // The compression error remains the primary failure. Temporary files
        // are also eligible for cleanup by the operating system.
      }
    }
  }

  Future<String> _availableReference({
    required Directory directory,
    required String fileName,
  }) async {
    final extension = path.extension(fileName);
    final baseName = path.basenameWithoutExtension(fileName);
    var candidate = path.join(directory.path, fileName);
    var suffix = 1;
    while (await File(candidate).exists()) {
      candidate = path.join(directory.path, '$baseName-$suffix$extension');
      suffix++;
    }
    return candidate;
  }
}

Future<XFile?> _compressWithPlugin(
  String sourceReference,
  String targetReference, {
  required int quality,
  required int minHeight,
}) =>
    FlutterImageCompress.compressAndGetFile(
      sourceReference,
      targetReference,
      quality: quality,
      minHeight: minHeight,
    );
