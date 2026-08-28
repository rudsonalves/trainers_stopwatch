import '/domain/common/report/models/training_report_content.dart';
import '/domain/common/report/services/training_report_pdf_renderer.dart';

class SharePreparedTrainingReportCommandInput {
  final TrainingReportContent content;
  final TrainingReportPdfTexts pdfTexts;
  final String subject;

  const SharePreparedTrainingReportCommandInput({
    required this.content,
    required this.pdfTexts,
    required this.subject,
  });
}
