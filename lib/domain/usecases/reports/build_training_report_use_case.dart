import '/core/result/result.dart';
import '/data/repositories/histories/history_repository.dart';
import '../../common/report/models/training_report_build_outcome.dart';
import '../../common/report/models/training_report_content.dart';
import '../../common/report/models/training_report_issue.dart';
import '../../common/report/models/training_report_section.dart';
import '../../common/report/services/training_report_content_builder.dart';
import '../../common/report/services/training_report_input.dart';
import '../../common/training/models/training.dart';
import '../../common/user/models/user.dart';

class BuildTrainingReportUseCase {
  final HistoryRepository _historyRepository;
  final TrainingReportContentBuilder _contentBuilder;

  const BuildTrainingReportUseCase({
    required HistoryRepository historyRepository,
    TrainingReportContentBuilder contentBuilder =
        const TrainingReportContentBuilder(),
  })  : _historyRepository = historyRepository,
        _contentBuilder = contentBuilder;

  AsyncResult<TrainingReportContent> execute({
    required User user,
    required List<Training> trainings,
  }) async {
    final userId = user.id;
    if (userId == null) {
      return const Failure(
        AppError(
          code: AppErrorCode.invalidData,
          message: 'A report requires a persisted user.',
        ),
      );
    }

    final inputs = <TrainingReportInput>[];

    for (final training in trainings) {
      final trainingId = training.id;
      if (trainingId == null) {
        return const Failure(
          AppError(
            code: AppErrorCode.invalidData,
            message: 'A report requires persisted trainings.',
          ),
        );
      }

      if (training.userId != userId) {
        return Failure(
          AppError(
              code: AppErrorCode.invalidData,
              message: 'Reported trainings must belong to the selected user.'),
        );
      }

      final historiesResult =
          await _historyRepository.loadForTraining(trainingId);
      if (historiesResult.isFailure) {
        return Failure(historiesResult.error!);
      }

      inputs.add(
        TrainingReportInput(
          training: training,
          histories: historiesResult.value!,
        ),
      );
    }

    return _contentBuilder.build(
      user: user,
      inputs: inputs,
    );
  }

  AsyncResult<TrainingReportBuildOutcome> buildOutcome({
    required User user,
    required List<Training> trainings,
  }) async {
    final userId = user.id;
    if (userId == null) {
      return const Failure(
        AppError(
          code: AppErrorCode.invalidData,
          message: 'A report requires a persisted user.',
        ),
      );
    }

    final sections = <TrainingReportSection>[];
    final issues = <TrainingReportIssue>[];

    for (final training in trainings) {
      final trainingId = training.id;

      if (trainingId == null) {
        issues.add(
          TrainingReportIssue(
            training: training,
            error: const AppError(
              code: AppErrorCode.invalidData,
              message: 'A report requires persisted trainings.',
            ),
          ),
        );
        continue;
      }

      if (training.userId != userId) {
        issues.add(
          TrainingReportIssue(
            training: training,
            error: const AppError(
              code: AppErrorCode.invalidData,
              message: 'Reported training must belong to the selected user.',
            ),
          ),
        );
        continue;
      }

      final historiesResult =
          await _historyRepository.loadForTraining(trainingId);

      if (historiesResult.isFailure) {
        issues.add(
          TrainingReportIssue(
            training: training,
            error: historiesResult.error!,
          ),
        );
        continue;
      }

      final histories = historiesResult.value!;

      if (histories.length <= 1) {
        issues.add(
          TrainingReportIssue(
            training: training,
            error: const AppError(
              code: AppErrorCode.zeroElapsedTime,
              message: 'Training has no measurements.',
            ),
          ),
        );
        continue;
      }

      final sectionResult = _contentBuilder.buildSection(
        TrainingReportInput(
          training: training,
          histories: histories,
        ),
      );

      if (sectionResult.isFailure) {
        issues.add(
          TrainingReportIssue(
            training: training,
            error: sectionResult.error!,
          ),
        );
        continue;
      }

      sections.add(sectionResult.value!);
    }

    return Success(
      TrainingReportBuildOutcome(
        content: TrainingReportContent(
          user: user,
          sections: sections,
        ),
        issues: issues,
      ),
    );
  }
}
