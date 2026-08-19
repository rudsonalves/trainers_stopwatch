import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:trainers_stopwatch/core/result/result.dart';
import 'package:trainers_stopwatch/data/services/images/image_compression_service_impl.dart';
import 'package:trainers_stopwatch/data/services/images/image_selection_service_impl.dart';
import 'package:trainers_stopwatch/data/services/images/models/image_selection.dart';
import 'package:trainers_stopwatch/data/services/images/models/prepared_user_image.dart';
import 'package:trainers_stopwatch/data/services/images/user_image_storage_service_impl.dart';

void main() {
  group('ImageSelectionServiceImpl', () {
    test('maps a picked file without exposing XFile in its contract', () async {
      final service = ImageSelectionServiceImpl(
        pickImage: () async => XFile('/picker/athlete.jpg'),
      );

      final result = await service.select();

      expect(result.isSuccess, isTrue);
      expect(
        result.value,
        const ImageSelected(
          sourceReference: '/picker/athlete.jpg',
          fileName: 'athlete.jpg',
        ),
      );
    });

    test('returns cancellation as a successful selection result', () async {
      final service = ImageSelectionServiceImpl(pickImage: () async => null);

      final result = await service.select();

      expect(result, isA<Success<ImageSelection>>());
      expect(result.value, isA<ImageSelectionCanceled>());
    });

    test('maps picker exceptions to imageSelectionFailed', () async {
      final service = ImageSelectionServiceImpl(
        pickImage: () async => throw StateError('picker unavailable'),
      );

      final result = await service.select();

      expect(result.error!.code, AppErrorCode.imageSelectionFailed);
    });
  });

  group('ImageCompressionServiceImpl', () {
    test('compresses into an identifiable temporary image', () async {
      final directory =
          await Directory.systemTemp.createTemp('image-compress-');
      addTearDown(() => directory.delete(recursive: true));
      final source = File('${directory.path}/source.jpg');
      await source.writeAsString('image-content');
      final service = ImageCompressionServiceImpl(
        temporaryDirectoryProvider: () async => directory,
        compressImage: (
          sourceReference,
          targetReference, {
          required quality,
          required minHeight,
        }) async {
          expect(quality, 95);
          expect(minHeight, 80);
          await File(sourceReference).copy(targetReference);
          return XFile(targetReference);
        },
        clock: () => DateTime.fromMicrosecondsSinceEpoch(123),
      );

      final result = await service.compress(
        ImageSelected(
          sourceReference: source.path,
          fileName: 'athlete.jpg',
        ),
      );

      expect(result.isSuccess, isTrue);
      expect(result.value!.fileName, '123-athlete.jpg');
      expect(await File(result.value!.temporaryReference).readAsString(),
          'image-content');
    });

    test('removes a partial target when compression fails', () async {
      final directory = await Directory.systemTemp.createTemp('image-partial-');
      addTearDown(() => directory.delete(recursive: true));
      final service = ImageCompressionServiceImpl(
        temporaryDirectoryProvider: () async => directory,
        compressImage: (
          _,
          targetReference, {
          required quality,
          required minHeight,
        }) async {
          await File(targetReference).writeAsString('partial');
          throw StateError('compression failed');
        },
        clock: () => DateTime.fromMicrosecondsSinceEpoch(456),
      );

      final result = await service.compress(
        const ImageSelected(
          sourceReference: '/source.jpg',
          fileName: 'athlete.jpg',
        ),
      );

      expect(result.error!.code, AppErrorCode.imageCompressionFailed);
      expect(
        await File(
          '${directory.path}/trainers_stopwatch_user_images/456-athlete.jpg',
        ).exists(),
        isFalse,
      );
    });
  });

  group('UserImageStorageServiceImpl', () {
    test('promotes an image and removes its temporary file', () async {
      final directory = await Directory.systemTemp.createTemp('image-store-');
      addTearDown(() => directory.delete(recursive: true));
      final temporary = File('${directory.path}/prepared.jpg');
      await temporary.writeAsString('prepared-image');
      final service = UserImageStorageServiceImpl(
        documentsDirectoryProvider: () async => directory,
        clock: () => DateTime.fromMicrosecondsSinceEpoch(789),
      );

      final result = await service.promote(
        PreparedUserImage(
          temporaryReference: temporary.path,
          fileName: 'athlete.jpg',
        ),
      );

      expect(result.isSuccess, isTrue);
      expect(result.value!.reference, endsWith('789-athlete.jpg'));
      expect(
          await File(result.value!.reference).readAsString(), 'prepared-image');
      expect(await temporary.exists(), isFalse);
    });

    test('remove is idempotent', () async {
      final directory = await Directory.systemTemp.createTemp('image-remove-');
      addTearDown(() => directory.delete(recursive: true));
      final file = File('${directory.path}/image.jpg');
      await file.writeAsString('image');
      final service = UserImageStorageServiceImpl(
        documentsDirectoryProvider: () async => directory,
        clock: DateTime.now,
      );

      expect((await service.remove(file.path)).isSuccess, isTrue);
      expect((await service.remove(file.path)).isSuccess, isTrue);
    });

    test('promotion never overwrites an existing image', () async {
      final directory = await Directory.systemTemp.createTemp('image-unique-');
      addTearDown(() => directory.delete(recursive: true));
      final firstTemporary = File('${directory.path}/first.jpg');
      final secondTemporary = File('${directory.path}/second.jpg');
      await firstTemporary.writeAsString('first');
      await secondTemporary.writeAsString('second');
      final service = UserImageStorageServiceImpl(
        documentsDirectoryProvider: () async => directory,
        clock: () => DateTime.fromMicrosecondsSinceEpoch(999),
      );

      final first = await service.promote(
        PreparedUserImage(
          temporaryReference: firstTemporary.path,
          fileName: 'athlete.jpg',
        ),
      );
      final second = await service.promote(
        PreparedUserImage(
          temporaryReference: secondTemporary.path,
          fileName: 'athlete.jpg',
        ),
      );

      expect(first.value!.reference, endsWith('999-athlete.jpg'));
      expect(second.value!.reference, endsWith('999-athlete-1.jpg'));
      expect(await File(first.value!.reference).readAsString(), 'first');
      expect(await File(second.value!.reference).readAsString(), 'second');
    });

    test('cleans only files without a persisted reference', () async {
      final directory = await Directory.systemTemp.createTemp('image-clean-');
      addTearDown(() => directory.delete(recursive: true));
      final images = Directory('${directory.path}/users_images');
      await images.create();
      final referenced = File('${images.path}/referenced.jpg');
      final orphan = File('${images.path}/orphan.jpg');
      await referenced.writeAsString('keep');
      await orphan.writeAsString('remove');
      final service = UserImageStorageServiceImpl(
        documentsDirectoryProvider: () async => directory,
        clock: DateTime.now,
      );

      final result = await service.cleanUnused({'/legacy/referenced.jpg'});

      expect(result.isSuccess, isTrue);
      expect(await referenced.exists(), isTrue);
      expect(await orphan.exists(), isFalse);
    });

    test('returns read failure when prepared image does not exist', () async {
      final directory = await Directory.systemTemp.createTemp('image-missing-');
      addTearDown(() => directory.delete(recursive: true));
      final service = UserImageStorageServiceImpl(
        documentsDirectoryProvider: () async => directory,
        clock: DateTime.now,
      );

      final result = await service.promote(
        const PreparedUserImage(
          temporaryReference: '/missing/prepared.jpg',
          fileName: 'athlete.jpg',
        ),
      );

      expect(result.error!.code, AppErrorCode.imageStorageReadFailed);
    });
  });
}
