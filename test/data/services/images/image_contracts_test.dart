import 'package:flutter_test/flutter_test.dart';
import 'package:trainers_stopwatch/core/result/result.dart';
import 'package:trainers_stopwatch/data/services/images/image_selection_service.dart';
import 'package:trainers_stopwatch/domain/models/image_selection.dart';
import 'package:trainers_stopwatch/domain/models/prepared_user_image.dart';
import 'package:trainers_stopwatch/domain/models/stored_user_image.dart';

void main() {
  test('canceled selection is a successful expected result', () async {
    final service = _CanceledImageSelectionService();

    final result = await service.select();

    expect(result, isA<Success<ImageSelection>>());
    expect(result.value, isA<ImageSelectionCanceled>());
  });

  test('image references have value equality', () {
    const selected = ImageSelected(
      sourceReference: '/picker/photo.jpg',
      fileName: 'photo.jpg',
    );
    const prepared = PreparedUserImage(
      temporaryReference: '/temporary/photo.jpg',
      fileName: 'photo.jpg',
    );
    const stored = StoredUserImage(reference: 'users/photo.jpg');

    expect(
      selected,
      const ImageSelected(
        sourceReference: '/picker/photo.jpg',
        fileName: 'photo.jpg',
      ),
    );
    expect(
      prepared,
      const PreparedUserImage(
        temporaryReference: '/temporary/photo.jpg',
        fileName: 'photo.jpg',
      ),
    );
    expect(stored, const StoredUserImage(reference: 'users/photo.jpg'));
  });

  test('image failures have codes distinct from database storage failures', () {
    expect(
      {
        AppErrorCode.imageSelectionFailed,
        AppErrorCode.imageCompressionFailed,
        AppErrorCode.imageStorageReadFailed,
        AppErrorCode.imageStorageWriteFailed,
        AppErrorCode.imageStorageDeleteFailed,
      }.length,
      5,
    );
    expect(
      AppErrorCode.imageStorageWriteFailed,
      isNot(AppErrorCode.storageWriteFailed),
    );
  });
}

final class _CanceledImageSelectionService implements ImageSelectionService {
  @override
  AsyncResult<ImageSelection> select() async =>
      const Success(ImageSelectionCanceled());
}
