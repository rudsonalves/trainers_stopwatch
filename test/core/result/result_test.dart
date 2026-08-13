import 'package:flutter_test/flutter_test.dart';
import 'package:trainers_stopwatch/core/result/result.dart';

void main() {
  group('Result', () {
    test('Success exposes its value and folds through onSuccess', () {
      const result = Success(42);

      expect(result.isSuccess, isTrue);
      expect(result.isFailure, isFalse);
      expect(result.value, 42);
      expect(
        result.fold(
          onSuccess: (value) => 'value:$value',
          onFailure: (error) => error.code.name,
        ),
        'value:42',
      );
    });

    test('Failure exposes its error and folds through onFailure', () {
      const error = AppError(
        code: AppErrorCode.storageReadFailed,
        message: 'read failed',
      );
      const Result<int> result = Failure(error);

      expect(result.isSuccess, isFalse);
      expect(result.isFailure, isTrue);
      expect(result.error, same(error));
      expect(
        result.fold(
          onSuccess: (value) => value.toString(),
          onFailure: (failure) => failure.code.name,
        ),
        'storageReadFailed',
      );
    });
  });
}
