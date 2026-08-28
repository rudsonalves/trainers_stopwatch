import '/core/result/result.dart';
import '/domain/common/report/services/temporary_report_file_storage.dart';
import '/domain/common/report/services/training_report_pdf_renderer.dart';
import '/domain/common/training/models/training.dart';
import '/domain/common/user/models/user.dart';
import '../../common/report/models/training_report_content.dart';
import 'build_training_report_use_case.dart';

class GenerateTrainingReportFileUseCase {
  final BuildTrainingReportUseCase _buildReport;
  final TrainingReportPdfRenderer _renderer;
  final TemporaryReportFileStorage _fileStorage;

  const GenerateTrainingReportFileUseCase({
    required BuildTrainingReportUseCase buildReport,
    required TrainingReportPdfRenderer renderer,
    required TemporaryReportFileStorage fileStorage,
  })  : _buildReport = buildReport,
        _renderer = renderer,
        _fileStorage = fileStorage;

  AsyncResult<TemporaryReportFile> execute({
    required User user,
    required List<Training> trainings,
    required TrainingReportPdfTexts texts,
    required String suggestedName,
  }) async {
    final contentResult = await _buildReport.execute(
      user: user,
      trainings: trainings,
    );
    if (contentResult.isFailure) {
      return Failure(contentResult.error!);
    }

    final pdfResult = await _renderer.render(
      content: contentResult.value!,
      texts: texts,
    );
    if (pdfResult.isFailure) {
      return Failure(pdfResult.error!);
    }

    final fileResult = await _fileStorage.write(
      suggestedName: suggestedName,
      mimeType: 'application/pdf',
      bytes: pdfResult.value!,
    );
    if (fileResult.isFailure) {
      return Failure(fileResult.error!);
    }

    return generateFromContent(
      content: contentResult.value!,
      texts: texts,
      suggestedName: suggestedName,
    );
  }

  AsyncResult<TemporaryReportFile> generateFromContent({
    required TrainingReportContent content,
    required TrainingReportPdfTexts texts,
    required String suggestedName,
  }) async {
    final pdfResult = await _renderer.render(
      content: content,
      texts: texts,
    );
    if (pdfResult.isFailure) {
      return Failure(pdfResult.error!);
    }

    final fileResult = await _fileStorage.write(
      suggestedName: suggestedName,
      mimeType: 'application/pdf',
      bytes: pdfResult.value!,
    );
    if (fileResult.isFailure) {
      return Failure(fileResult.error!);
    }

    return Success(fileResult.value!);
  }
}
