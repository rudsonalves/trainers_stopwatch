import 'package:flutter_test/flutter_test.dart';
import 'package:trainers_stopwatch/common/functions/stopwatch_functions.dart';
import 'package:trainers_stopwatch/common/models/training_model.dart';
import 'package:trainers_stopwatch/core/result/errors/app_error.dart';

void main() {
  TrainingModel training({
    String distanceUnit = 'm',
    String speedUnit = 'm/s',
  }) =>
      TrainingModel(
        userId: 1,
        date: DateTime(2026),
        distanceUnit: distanceUnit,
        speedUnit: speedUnit,
      );

  test('legacy speedCalc delegates a metric calculation to the domain', () {
    final speed = StopwatchFunctions.speedCalc(
      length: 200,
      time: 20,
      training: training(),
    );

    expect(speed.value, 10);
    expect(speed.speedUnit, 'm/s');
  });

  test('legacy speedCalc preserves imperial conversion', () {
    final speed = StopwatchFunctions.speedCalc(
      length: 1,
      time: 3600,
      training: training(distanceUnit: 'mi', speedUnit: 'mph'),
    );

    expect(speed.value, closeTo(0.9999991721111111, 1e-12));
    expect(speed.speedUnit, 'mph');
  });

  test('legacy speedCalc exposes zero elapsed time as AppError', () {
    expect(
      () => StopwatchFunctions.speedCalc(
        length: 200,
        time: 0,
        training: training(),
      ),
      throwsA(
        isA<AppError>().having(
          (error) => error.code,
          'code',
          AppErrorCode.zeroElapsedTime,
        ),
      ),
    );
  });
}
