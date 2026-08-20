import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '/common/constants.dart';
import '/core/result/result.dart';
import '/domain/models/prepared_user_image.dart';
import '/domain/models/stored_user_image.dart';
import 'user_image_storage_service.dart';

typedef DocumentsDirectoryProvider = Future<Directory> Function();

class UserImageStorageServiceImpl implements UserImageStorageService {
  final DocumentsDirectoryProvider _documentsDirectoryProvider;
  final DateTime Function() _clock;

  UserImageStorageServiceImpl({
    required DocumentsDirectoryProvider documentsDirectoryProvider,
    required DateTime Function() clock,
  })  : _documentsDirectoryProvider = documentsDirectoryProvider,
        _clock = clock;

  factory UserImageStorageServiceImpl.platform() => UserImageStorageServiceImpl(
        documentsDirectoryProvider: getApplicationDocumentsDirectory,
        clock: DateTime.now,
      );

  @override
  AsyncResult<StoredUserImage> promote(PreparedUserImage image) async {
    try {
      final source = File(image.temporaryReference);
      if (!await source.exists()) {
        return Failure(
          AppError(
            code: AppErrorCode.imageStorageReadFailed,
            message: 'The prepared image does not exist.',
            details: image.temporaryReference,
          ),
        );
      }

      final imageDirectory = await _imageDirectory(create: true);
      final destination = await _availableDestination(
        directory: imageDirectory,
        fileName:
            '${_clock().microsecondsSinceEpoch}-${path.basename(image.fileName)}',
      );
      await source.copy(destination.path);

      try {
        await source.delete();
      } on FileSystemException {
        // Promotion has succeeded. A leftover temporary file must not turn a
        // valid stored image into a failed operation.
      }

      return Success(StoredUserImage(reference: destination.path));
    } catch (error, stackTrace) {
      return Failure(
        AppError(
          code: AppErrorCode.imageStorageWriteFailed,
          message: 'Could not store the prepared image.',
          details: (error: error, stackTrace: stackTrace),
        ),
      );
    }
  }

  @override
  AsyncResult<Unit> remove(String reference) async {
    try {
      final file = File(reference);
      if (await file.exists()) await file.delete();
      return const Success(unit);
    } catch (error, stackTrace) {
      return Failure(
        AppError(
          code: AppErrorCode.imageStorageDeleteFailed,
          message: 'Could not remove the image.',
          details: (error: error, stackTrace: stackTrace),
        ),
      );
    }
  }

  @override
  AsyncResult<Unit> cleanUnused(Set<String> referencedImages) async {
    final Directory imageDirectory;
    try {
      imageDirectory = await _imageDirectory(create: false);
      if (!await imageDirectory.exists()) return const Success(unit);
    } catch (error, stackTrace) {
      return Failure(
        AppError(
          code: AppErrorCode.imageStorageReadFailed,
          message: 'Could not access the user image directory.',
          details: (error: error, stackTrace: stackTrace),
        ),
      );
    }

    final referencedNames = referencedImages.map(path.basename).toSet();
    try {
      await for (final entity in imageDirectory.list(followLinks: false)) {
        if (entity is File &&
            !referencedNames.contains(path.basename(entity.path))) {
          await entity.delete();
        }
      }
      return const Success(unit);
    } catch (error, stackTrace) {
      return Failure(
        AppError(
          code: AppErrorCode.imageStorageDeleteFailed,
          message: 'Could not clean unused user images.',
          details: (error: error, stackTrace: stackTrace),
        ),
      );
    }
  }

  /// Returns the directory where user images are stored. If [create] is true,
  /// the directory will be created if it does not exist.
  Future<Directory> _imageDirectory({required bool create}) async {
    final documentsDirectory = await _documentsDirectoryProvider();
    final directory =
        Directory(path.join(documentsDirectory.path, usersImages));
    if (create) await directory.create(recursive: true);
    return directory;
  }

  /// Returns a file in the given [directory] with the given [fileName], ensuring
  /// that the file does not already exist. If a file with the same name exists,
  /// a suffix will be added to the file name to make it unique.
  Future<File> _availableDestination({
    required Directory directory,
    required String fileName,
  }) async {
    final extension = path.extension(fileName);
    final baseName = path.basenameWithoutExtension(fileName);
    var candidate = File(path.join(directory.path, fileName));
    var suffix = 1;
    while (await candidate.exists()) {
      candidate = File(
        path.join(directory.path, '$baseName-$suffix$extension'),
      );
      suffix++;
    }
    return candidate;
  }
}
