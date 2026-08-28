import '/core/result/result.dart';
import '/domain/common/report/services/report_email_service.dart';
import '/domain/common/report/services/training_report_pdf_renderer.dart';
import '/domain/common/training/models/training.dart';
import '/domain/common/user/models/user.dart';
import '../../common/report/models/training_report_content.dart';
import 'deliver_training_report_use_case.dart';

class SendTrainingReportEmailUseCase {
  final DeliverTrainingReportUseCase _deliverReport;
  final ReportEmailService _emailService;

  const SendTrainingReportEmailUseCase({
    required DeliverTrainingReportUseCase deliverReport,
    required ReportEmailService emailService,
  })  : _deliverReport = deliverReport,
        _emailService = emailService;

  AsyncResult<Unit> execute({
    required User user,
    required List<Training> trainings,
    required TrainingReportPdfTexts texts,
    required List<String> recipients,
    required String subject,
    required String htmlBody,
    String suggestedName = 'training_logs.pdf',
  }) async {
    if (recipients.isEmpty ||
        recipients.any((recipient) => recipient.trim().isEmpty)) {
      return const Failure(
        AppError(
          code: AppErrorCode.invalidData,
          message: 'Training report email requires valid recipients.',
        ),
      );
    }

    return _deliverReport.execute(
      user: user,
      trainings: trainings,
      texts: texts,
      suggestedName: suggestedName,
      deliver: (file) => _emailService.send(
        ReportEmailMessage(
          recipients: recipients,
          subject: subject,
          htmlBody: htmlBody,
          attachments: [file],
        ),
      ),
    );
  }

  AsyncResult<Unit> executeFromContent({
    required TrainingReportContent content,
    required TrainingReportPdfTexts texts,
    required List<String> recipients,
    required String subject,
    required String htmlBody,
    String suggestedName = 'training_logs.pdf',
  }) async {
    if (recipients.isEmpty ||
        recipients.any((recipient) => recipient.trim().isEmpty)) {
      return const Failure(
        AppError(
          code: AppErrorCode.invalidData,
          message: 'Training report email requires valid recipients.',
        ),
      );
    }

    return _deliverReport.executeFromContent(
      content: content,
      texts: texts,
      suggestedName: suggestedName,
      deliver: (file) => _emailService.send(
        ReportEmailMessage(
          recipients: recipients,
          subject: subject,
          htmlBody: htmlBody,
          attachments: [file],
        ),
      ),
    );
  }
}
