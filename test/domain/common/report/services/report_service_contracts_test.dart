import 'package:flutter_test/flutter_test.dart';
import 'package:trainers_stopwatch/domain/common/report/services/report_email_service.dart';
import 'package:trainers_stopwatch/domain/common/report/services/temporary_report_file_storage.dart';
import 'package:trainers_stopwatch/domain/common/report/services/training_report_pdf_renderer.dart';

void main() {
  const file = TemporaryReportFile(
    path: '/temporary/report.pdf',
    name: 'report.pdf',
    mimeType: 'application/pdf',
  );

  TrainingReportPdfTexts texts() => const TrainingReportPdfTexts(
        locale: 'pt-BR',
        reportTitle: 'Relatório de treinos',
        userLabel: 'Usuário',
        dateLabel: 'Data',
        totalDistanceLabel: 'Distância total',
        totalTimeLabel: 'Tempo total',
        averageSpeedLabel: 'Velocidade média',
        lapDistanceLabel: 'Distância da volta',
        splitDistanceLabel: 'Distância da parcial',
        lapCountLabel: 'Número de voltas',
        eventColumnLabel: 'Parcial/volta',
        timeColumnLabel: 'Tempo',
        speedColumnLabel: 'Velocidade',
        commentsColumnLabel: 'Comentários',
        trainingStartedLabel: 'Início do treino',
        splitLabel: 'Parcial',
        lapLabel: 'Volta',
      );

  test('TemporaryReportFile has value equality', () {
    const equivalent = TemporaryReportFile(
      path: '/temporary/report.pdf',
      name: 'report.pdf',
      mimeType: 'application/pdf',
    );

    expect(file, equivalent);
    expect(file.hashCode, equivalent.hashCode);
  });

  test('TrainingReportPdfTexts has value equality', () {
    expect(texts(), texts());
    expect(texts().hashCode, texts().hashCode);
  });

  test('ReportEmailMessage has value equality', () {
    final first = ReportEmailMessage(
      recipients: const ['ana@example.com'],
      subject: 'Treinos',
      htmlBody: '<p>Relatório</p>',
      attachments: const [file],
    );
    final second = ReportEmailMessage(
      recipients: const ['ana@example.com'],
      subject: 'Treinos',
      htmlBody: '<p>Relatório</p>',
      attachments: const [file],
    );

    expect(first, second);
    expect(first.hashCode, second.hashCode);
  });

  test('ReportEmailMessage copies and protects recipients', () {
    final recipients = ['ana@example.com'];
    final message = ReportEmailMessage(
      recipients: recipients,
      subject: 'Treinos',
      htmlBody: '<p>Relatório</p>',
      attachments: const [file],
    );

    recipients.clear();

    expect(message.recipients, ['ana@example.com']);
    expect(
      () => message.recipients.add('bia@example.com'),
      throwsUnsupportedError,
    );
  });

  test('ReportEmailMessage copies and protects attachments', () {
    final attachments = [file];
    final message = ReportEmailMessage(
      recipients: const ['ana@example.com'],
      subject: 'Treinos',
      htmlBody: '<p>Relatório</p>',
      attachments: attachments,
    );

    attachments.clear();

    expect(message.attachments, [file]);
    expect(
      () => message.attachments.add(file),
      throwsUnsupportedError,
    );
  });
}
