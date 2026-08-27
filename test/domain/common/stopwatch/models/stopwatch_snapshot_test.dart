import 'package:flutter_test/flutter_test.dart';
import 'package:trainers_stopwatch/core/result/errors/app_error_code.dart';
import 'package:trainers_stopwatch/domain/common/stopwatch/models/stopwatch_snapshot.dart';

void main() {
  group('SplitSnapshot', () {
    test('captures elapsed time, segment and counters', () {
      final result = SplitSnapshot.create(
        elapsed: const Duration(seconds: 12),
        splitDuration: const Duration(seconds: 2),
        lapCount: 1,
        splitCount: 3,
      );

      expect(result.isSuccess, isTrue);
      expect(result.value?.elapsed, const Duration(seconds: 12));
      expect(result.value?.splitDuration, const Duration(seconds: 2));
      expect(result.value?.lapCount, 1);
      expect(result.value?.splitCount, 3);
    });

    test('allows zero durations for the calculator to classify later', () {
      final result = SplitSnapshot.create(
        elapsed: Duration.zero,
        splitDuration: Duration.zero,
        lapCount: 0,
        splitCount: 0,
      );

      expect(result.isSuccess, isTrue);
    });
  });

  group('LapSnapshot', () {
    test('captures split and accumulated lap durations', () {
      final result = LapSnapshot.create(
        elapsed: const Duration(seconds: 20),
        splitDuration: const Duration(seconds: 5),
        lapDuration: const Duration(seconds: 10),
        lapCount: 2,
        splitCount: 0,
      );

      expect(result.isSuccess, isTrue);
      expect(result.value?.splitDuration, const Duration(seconds: 5));
      expect(result.value?.lapDuration, const Duration(seconds: 10));
      expect(result.value?.lapCount, 2);
      expect(result.value?.splitCount, 0);
    });
  });

  group('FinishSnapshot', () {
    test('captures final segments and counters', () {
      final result = FinishSnapshot.create(
        elapsed: const Duration(seconds: 30),
        finalSplitDuration: const Duration(seconds: 4),
        finalLapDuration: const Duration(seconds: 14),
        lapCount: 2,
        splitCount: 2,
      );

      expect(result.isSuccess, isTrue);
      expect(result.value?.finalSplitDuration, const Duration(seconds: 4));
      expect(result.value?.finalLapDuration, const Duration(seconds: 14));
    });
  });

  group('snapshot invariants', () {
    test('rejects negative duration', () {
      final result = SplitSnapshot.create(
        elapsed: const Duration(seconds: 1),
        splitDuration: const Duration(microseconds: -1),
        lapCount: 0,
        splitCount: 0,
      );

      expect(result.isFailure, isTrue);
      expect(result.error?.code, AppErrorCode.invalidData);
    });

    test('rejects a segment greater than total elapsed time', () {
      final result = LapSnapshot.create(
        elapsed: const Duration(seconds: 5),
        splitDuration: const Duration(seconds: 2),
        lapDuration: const Duration(seconds: 6),
        lapCount: 1,
        splitCount: 0,
      );

      expect(result.isFailure, isTrue);
      expect(result.error?.code, AppErrorCode.invalidData);
    });

    test('rejects negative counters', () {
      final result = FinishSnapshot.create(
        elapsed: const Duration(seconds: 1),
        finalSplitDuration: const Duration(seconds: 1),
        finalLapDuration: const Duration(seconds: 1),
        lapCount: -1,
        splitCount: 0,
      );

      expect(result.isFailure, isTrue);
      expect(result.error?.code, AppErrorCode.invalidData);
    });

    test('supports value equality', () {
      final first = SplitSnapshot.create(
        elapsed: const Duration(seconds: 2),
        splitDuration: const Duration(seconds: 1),
        lapCount: 0,
        splitCount: 1,
      );
      final second = SplitSnapshot.create(
        elapsed: const Duration(seconds: 2),
        splitDuration: const Duration(seconds: 1),
        lapCount: 0,
        splitCount: 1,
      );

      expect(first.value, second.value);
      expect(first.value.hashCode, second.value.hashCode);
    });
  });
}
