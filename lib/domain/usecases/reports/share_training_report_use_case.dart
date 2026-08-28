import '/core/result/result.dart';
import '/domain/common/report/services/report_share_service.dart';
import '/domain/common/report/services/training_report_pdf_renderer.dart';
import '/domain/common/training/models/training.dart';
import '/domain/common/user/models/user.dart';
import '../../common/report/models/training_report_content.dart';
import 'deliver_training_report_use_case.dart';

class ShareTrainingReportUseCase {
  final DeliverTrainingReportUseCase _deliverReport;
  final ReportShareService _shareService;

  const ShareTrainingReportUseCase({
    required DeliverTrainingReportUseCase deliverReport,
    required ReportShareService shareService,
  })  : _deliverReport = deliverReport,
        _shareService = shareService;

  AsyncResult<Unit> execute({
    required User user,
    required List<Training> trainings,
    required TrainingReportPdfTexts texts,
    required String subject,
    String suggestedName = 'training_logs.pdf',
  }) {
    return _deliverReport.execute(
      user: user,
      trainings: trainings,
      texts: texts,
      suggestedName: suggestedName,
      deliver: (file) => _shareService.share(
        file: file,
        subject: subject,
      ),
    );
  }

  AsyncResult<Unit> executeFromContent({
    required TrainingReportContent content,
    required TrainingReportPdfTexts texts,
    required String subject,
    String suggestedName = 'training_logs.pdf',
  }) {
    return _deliverReport.executeFromContent(
      content: content,
      texts: texts,
      suggestedName: suggestedName,
      deliver: (file) => _shareService.share(
        file: file,
        subject: subject,
      ),
    );
  }
}
