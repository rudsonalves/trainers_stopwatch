import 'package:flutter_test/flutter_test.dart';
import 'package:trainers_stopwatch/core/result/errors/app_error_code.dart';
import 'package:trainers_stopwatch/domain/common/history/models/history_entry.dart';

void main() {
  group('HistoryEntry', () {
    test('allows zero duration for the initial training entry', () {
      final result = HistoryEntry.create(
        trainingId: 1,
        duration: Duration.zero,
      );

      expect(result.isSuccess, isTrue);
      expect(result.value?.duration, Duration.zero);
    });

    test('rejects a training that is not persisted', () {
      final result = HistoryEntry.create(
        trainingId: 0,
        duration: Duration.zero,
      );

      expect(result.isFailure, isTrue);
      expect(result.error?.code, AppErrorCode.invalidData);
    });

    test('rejects negative duration', () {
      final result = HistoryEntry.create(
        trainingId: 1,
        duration: const Duration(milliseconds: -1),
      );

      expect(result.isFailure, isTrue);
      expect(result.error?.code, AppErrorCode.invalidData);
    });

    test('has value equality', () {
      final first = HistoryEntry.create(
        id: 1,
        trainingId: 2,
        duration: const Duration(seconds: 3),
        comments: 'split',
      );
      final second = HistoryEntry.create(
        id: 1,
        trainingId: 2,
        duration: const Duration(seconds: 3),
        comments: 'split',
      );

      expect(first.value, second.value);
      expect(first.value.hashCode, second.value.hashCode);
    });
  });
}
