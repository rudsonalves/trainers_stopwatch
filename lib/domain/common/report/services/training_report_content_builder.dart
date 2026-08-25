import '/core/result/result.dart';
import '../../training/services/speed_calculator.dart';
import '../../training/services/training_event_generator.dart';
import '../../training/values/distance.dart';
import '../../user/models/user.dart';
import '../models/training_report_content.dart';
import '../models/training_report_row.dart';
import '../models/training_report_section.dart';
import '../models/training_report_totals.dart';
import 'training_report_input.dart';

class TrainingReportContentBuilder {
  final TrainingEventGenerator _eventGenerator;
  final SpeedCalculator _speedCalculator;

  const TrainingReportContentBuilder({
    TrainingEventGenerator eventGenerator = const TrainingEventGenerator(),
    SpeedCalculator speedCalculator = const SpeedCalculator(),
  })  : _eventGenerator = eventGenerator,
        _speedCalculator = speedCalculator;

  Result<TrainingReportContent> build({
    required User user,
    required List<TrainingReportInput> inputs,
  }) {
    final sections = <TrainingReportSection>[];

    for (final input in inputs) {
      final sectionResult = _buildSection(input);

      if (sectionResult.isFailure) {
        return Failure(sectionResult.error!);
      }

      sections.add(sectionResult.value!);
    }

    return Success(
      TrainingReportContent(
        user: user,
        sections: sections,
      ),
    );
  }

  Result<TrainingReportSection> _buildSection(
    TrainingReportInput input,
  ) {
    final training = input.training;
    final histories = input.histories;

    final eventsResult = _eventGenerator.generate(
      training: training,
      histories: histories,
    );
    if (eventsResult.isFailure) {
      return Failure(eventsResult.error!);
    }

    final splitCount = histories.length - 1;
    final totalDistanceResult = Distance.create(
      value: splitCount * training.splitDistance.value,
      unit: training.splitDistance.unit,
    );
    if (totalDistanceResult.isFailure) {
      return Failure(totalDistanceResult.error!);
    }

    final totalDuration = histories.fold(
      Duration.zero,
      (total, history) => total + history.duration,
    );

    final averageSpeedResult = _speedCalculator.calculate(
      distance: totalDistanceResult.value!,
      duration: totalDuration,
      outputUnit: training.speedUnit,
    );
    if (averageSpeedResult.isFailure) {
      return Failure(averageSpeedResult.error!);
    }

    final lapRatio =
        totalDistanceResult.value!.inMeters / training.lapDistance.inMeters;
    final lapCount = lapRatio.round();

    final rows = eventsResult.value!
        .map((event) => TrainingReportRow(event: event))
        .toList(growable: false);

    return Success(
      TrainingReportSection(
        training: training,
        rows: rows,
        totals: TrainingReportTotals(
          distance: totalDistanceResult.value!,
          duration: totalDuration,
          lapCount: lapCount,
          averageSpeed: averageSpeedResult.value!,
        ),
      ),
    );
  }
}
