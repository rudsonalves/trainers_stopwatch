import '/core/result/result.dart';
import '../../history/models/history_entry.dart';
import '../events/training_event.dart';
import '../models/training.dart';
import '../services/speed_calculator.dart';

final class TrainingEventGenerator {
  final SpeedCalculator _speedCalculator;

  const TrainingEventGenerator({
    SpeedCalculator speedCalculator = const SpeedCalculator(),
  }) : _speedCalculator = speedCalculator;

  Result<List<TrainingEvent>> generate({
    required Training training,
    required List<HistoryEntry> histories,
  }) {
    if (histories.isEmpty) return const Success([]);

    final trainingId = training.id;
    if (trainingId == null) {
      return const Failure(
        AppError(
          code: AppErrorCode.invalidData,
          message: 'A report requires a persisted training.',
        ),
      );
    }

    if (histories.any((history) => history.trainingId != trainingId)) {
      return const Failure(
        AppError(
          code: AppErrorCode.invalidData,
          message: 'History entries must belong to the reported training.',
        ),
      );
    }

    final splitsPerLapResult = _splitsPerLap(training);
    if (splitsPerLapResult.isFailure) {
      return Failure(splitsPerLapResult.error!);
    }
    final splitsPerLap = splitsPerLapResult.value!;

    final events = <TrainingEvent>[
      TrainingStarted(
        historyId: histories.first.id,
        comments: histories.first.comments,
      ),
    ];
    var lapDuration = Duration.zero;

    for (var historyIndex = 1;
        historyIndex < histories.length;
        historyIndex++) {
      final history = histories[historyIndex];
      final measurementNumber = historyIndex;
      final splitIndex = ((measurementNumber - 1) % splitsPerLap) + 1;
      final lapIndex = measurementNumber ~/ splitsPerLap;

      final splitSpeed = _speedCalculator.calculate(
        distance: training.splitDistance,
        duration: history.duration,
        outputUnit: training.speedUnit,
      );
      if (splitSpeed.isFailure) return Failure(splitSpeed.error!);

      final splitEvent = SplitRecorded.create(
        historyId: history.id,
        comments: history.comments,
        splitIndex: splitIndex,
        duration: history.duration,
        speed: splitSpeed.value!,
      );
      if (splitEvent.isFailure) return Failure(splitEvent.error!);

      events.add(splitEvent.value!);
      lapDuration += history.duration;

      if (splitIndex != splitsPerLap) continue;

      final lapSpeed = _speedCalculator.calculate(
        distance: training.lapDistance,
        duration: lapDuration,
        outputUnit: training.speedUnit,
      );
      if (lapSpeed.isFailure) return Failure(lapSpeed.error!);

      final lapEvent = LapRecorded.create(
        historyId: history.id,
        comments: history.comments,
        lapIndex: lapIndex,
        duration: lapDuration,
        speed: lapSpeed.value!,
      );
      if (lapEvent.isFailure) return Failure(lapEvent.error!);

      events.add(lapEvent.value!);
      lapDuration = Duration.zero;
    }

    return Success(List.unmodifiable(events));
  }

  Result<int> _splitsPerLap(Training training) {
    final splitMeters = training.splitDistance.inMeters;
    final lapMeters = training.lapDistance.inMeters;
    final ratio = lapMeters / splitMeters;
    final roundedRatio = ratio.round();

    if (!ratio.isFinite || roundedRatio <= 0) {
      return Failure(
        AppError(
          code: AppErrorCode.invalidData,
          message: 'Lap and split distances produce an invalid ratio.',
          details: ratio,
        ),
      );
    }

    return Success(roundedRatio);
  }
}
