import '/domain/common/report/services/training_report_pdf_renderer.dart';

class ShareTrainingReportCommandInput {
  final TrainingReportPdfTexts pdfTexts;
  final String subject;

  const ShareTrainingReportCommandInput({
    required this.pdfTexts,
    required this.subject,
  });
}

class EmailTrainingReportCommandInput {
  final TrainingReportPdfTexts pdfTexts;
  final List<String> recipients;
  final String subject;
  final String htmlBody;

  EmailTrainingReportCommandInput({
    required this.pdfTexts,
    required List<String> recipients,
    required this.subject,
    required this.htmlBody,
  }) : recipients = List.unmodifiable(recipients);
}
