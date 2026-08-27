import '/core/result/result.dart';
import '/data/repositories/histories/history_repository.dart';
import '../../common/report/models/training_report_content.dart';
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
}
