import '/core/result/result.dart';
import '/domain/common/report/services/temporary_report_file_storage.dart';
import '/domain/common/report/services/training_report_pdf_renderer.dart';
import '/domain/common/training/models/training.dart';
import '/domain/common/user/models/user.dart';
import '../../common/report/models/training_report_content.dart';
import 'generate_training_report_file_use_case.dart';

typedef TrainingReportDelivery = AsyncResult<Unit> Function(
  TemporaryReportFile file,
);

class DeliverTrainingReportUseCase {
  final GenerateTrainingReportFileUseCase _generateFile;
  final TemporaryReportFileStorage _fileStorage;

  const DeliverTrainingReportUseCase({
    required GenerateTrainingReportFileUseCase generateFile,
    required TemporaryReportFileStorage fileStorage,
  })  : _generateFile = generateFile,
        _fileStorage = fileStorage;

  AsyncResult<Unit> execute({
    required User user,
    required List<Training> trainings,
    required TrainingReportPdfTexts texts,
    required String suggestedName,
    required TrainingReportDelivery deliver,
  }) async {
    final fileResult = await _generateFile.execute(
      user: user,
      trainings: trainings,
      texts: texts,
      suggestedName: suggestedName,
    );
    if (fileResult.isFailure) {
      return Failure(fileResult.error!);
    }

    return _deliverFile(
      file: fileResult.value!,
      deliver: deliver,
    );
  }

  AsyncResult<Unit> executeFromContent({
    required TrainingReportContent content,
    required TrainingReportPdfTexts texts,
    required String suggestedName,
    required TrainingReportDelivery deliver,
  }) async {
    if (content.sections.isEmpty) {
      return const Failure(
        AppError(
          code: AppErrorCode.invalidData,
          message: 'A training report requires at least one valid training.',
        ),
      );
    }

    final fileResult = await _generateFile.generateFromContent(
      content: content,
      texts: texts,
      suggestedName: suggestedName,
    );
    if (fileResult.isFailure) {
      return Failure(fileResult.error!);
    }

    return _deliverFile(
      file: fileResult.value!,
      deliver: deliver,
    );
  }

  AsyncResult<Unit> _deliverFile({
    required TemporaryReportFile file,
    required TrainingReportDelivery deliver,
  }) async {
    Result<Unit>? deliveryResult;
    Result<Unit>? cleanupResult;

    try {
      deliveryResult = await deliver(file);
    } catch (error) {
      deliveryResult = Failure(
        AppError(
          code: AppErrorCode.unexpected,
          message: 'Training report delivery failed unexpectedly.',
          details: error,
        ),
      );
    } finally {
      cleanupResult = await _deleteSafely(file);
    }

    return _mergeResults(
      delivery: deliveryResult,
      cleanup: cleanupResult,
      file: file,
    );
  }

  Future<Result<Unit>> _deleteSafely(
    TemporaryReportFile file,
  ) async {
    try {
      return await _fileStorage.delete(file);
    } catch (error) {
      return Failure(
        AppError(
          code: AppErrorCode.storageWriteFailed,
          message: 'Temporary report cleanup failed unexpectedly.',
          details: error,
        ),
      );
    }
  }

  Result<Unit> _mergeResults({
    required Result<Unit> delivery,
    required Result<Unit> cleanup,
    required TemporaryReportFile file,
  }) {
    if (delivery.isSuccess && cleanup.isSuccess) {
      return const Success(unit);
    }

    if (delivery.isSuccess) {
      return Failure(cleanup.error!);
    }

    if (cleanup.isSuccess) {
      return Failure(delivery.error!);
    }

    return Failure(
      AppError(
        code: delivery.error!.code,
        message:
            'Training report delivery failed and its temporary file could not '
            'be removed.',
        details: (
          primaryError: delivery.error!,
          cleanupError: cleanup.error!,
          filePath: file.path,
        ),
      ),
    );
  }
}
