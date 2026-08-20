import '/core/result/result.dart';
import '/data/repositories/histories/history_repository.dart';
import '/data/repositories/trainings/training_repository.dart';
import '/domain/common/history/models/history_entry.dart';
import '/domain/common/training/models/training.dart';
import 'training_initialization.dart';

class CreateTrainingUseCase {
  final TrainingRepository _trainingRepository;
  final HistoryRepository _historyRepository;

  const CreateTrainingUseCase({
    required TrainingRepository trainingRepository,
    required HistoryRepository historyRepository,
  })  : _trainingRepository = trainingRepository,
        _historyRepository = historyRepository;

  AsyncResult<TrainingInitialization> execute({
    required Training training,
    String? initialComments,
  }) async {
    final insertion = await _trainingRepository.insert(training);
    if (insertion.isFailure) return Failure(insertion.error!);

    final persistedTraining = insertion.value!;
    final trainingId = persistedTraining.id;
    if (trainingId == null) {
      return const Failure(
        AppError(
          code: AppErrorCode.invalidData,
          message: 'Training insertion did not return a persistence identity.',
        ),
      );
    }

    final initialHistory = HistoryEntry.create(
      trainingId: trainingId,
      duration: Duration.zero,
      comments: initialComments,
    );
    if (initialHistory.isFailure) {
      return _rollback<TrainingInitialization>(
        training: persistedTraining,
        primaryError: initialHistory.error!,
      );
    }

    final historyInsertion = await _historyRepository.insert(
      initialHistory.value!,
    );
    if (historyInsertion.isFailure) {
      return _rollback<TrainingInitialization>(
        training: persistedTraining,
        primaryError: historyInsertion.error!,
      );
    }

    return Success(
      TrainingInitialization(
        training: persistedTraining,
        initialHistory: historyInsertion.value!,
      ),
    );
  }

  Future<Result<T>> _rollback<T extends Object>({
    required Training training,
    required AppError primaryError,
  }) async {
    final compensation = await _trainingRepository.delete(training);
    if (compensation.isSuccess) return Failure(primaryError);

    return Failure(
      AppError(
        code: compensation.error!.code,
        message:
            'Training creation failed and the persisted training could not be removed.',
        details: (
          primaryError: primaryError,
          compensationError: compensation.error!,
          trainingId: training.id,
        ),
      ),
    );
  }
}
