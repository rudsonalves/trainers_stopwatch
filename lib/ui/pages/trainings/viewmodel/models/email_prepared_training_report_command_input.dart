import '/domain/common/report/models/training_report_content.dart';
import '/domain/common/report/services/training_report_pdf_renderer.dart';

class EmailPreparedTrainingReportCommandInput {
  final TrainingReportContent content;
  final TrainingReportPdfTexts pdfTexts;
  final List<String> recipients;
  final String subject;
  final String htmlBody;

  EmailPreparedTrainingReportCommandInput({
    required this.content,
    required this.pdfTexts,
    required List<String> recipients,
    required this.subject,
    required this.htmlBody,
  }) : recipients = List.unmodifiable(recipients);
}
