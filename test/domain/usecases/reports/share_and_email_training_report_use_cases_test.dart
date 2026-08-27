import 'package:flutter_test/flutter_test.dart';
import 'package:trainers_stopwatch/core/result/result.dart';
import 'package:trainers_stopwatch/domain/common/report/services/report_email_service.dart';
import 'package:trainers_stopwatch/domain/common/report/services/report_share_service.dart';
import 'package:trainers_stopwatch/domain/common/report/services/temporary_report_file_storage.dart';
import 'package:trainers_stopwatch/domain/common/report/services/training_report_pdf_renderer.dart';
import 'package:trainers_stopwatch/domain/common/training/models/training.dart';
import 'package:trainers_stopwatch/domain/common/user/models/user.dart';
import 'package:trainers_stopwatch/domain/usecases/reports/deliver_training_report_use_case.dart';
import 'package:trainers_stopwatch/domain/usecases/reports/send_training_report_email_use_case.dart';
import 'package:trainers_stopwatch/domain/usecases/reports/share_training_report_use_case.dart';

void main() {
  group('ShareTrainingReportUseCase', () {
    test('delegates generation, sharing metadata and default filename',
        () async {
      final delivery = _FakeDeliverReport();
      final shareService = _FakeShareService();
      final useCase = ShareTrainingReportUseCase(
        deliverReport: delivery,
        shareService: shareService,
      );

      final result = await useCase.execute(
        user: _user,
        trainings: [_training],
        texts: _texts,
        subject: 'Training',
      );

      expect(result.isSuccess, isTrue);
      expect(delivery.callCount, 1);
      expect(delivery.receivedUser, _user);
      expect(delivery.receivedTrainings, [_training]);
      expect(delivery.receivedTexts, _texts);
      expect(delivery.receivedName, 'training_logs.pdf');
      expect(shareService.receivedFile, delivery.file);
      expect(shareService.receivedSubject, 'Training');
    });

    test('propagates sharing failure through the delivery coordinator',
        () async {
      final delivery = _FakeDeliverReport();
      final shareService = _FakeShareService()
        ..error = const AppError(
          code: AppErrorCode.unexpected,
          message: 'share failed',
        );
      final useCase = ShareTrainingReportUseCase(
        deliverReport: delivery,
        shareService: shareService,
      );

      final result = await useCase.execute(
        user: _user,
        trainings: [_training],
        texts: _texts,
        subject: 'Training',
      );

      expect(result.isFailure, isTrue);
      expect(result.error, shareService.error);
    });
  });

  group('SendTrainingReportEmailUseCase', () {
    test('delegates generation and sends the prepared HTML message', () async {
      final delivery = _FakeDeliverReport();
      final emailService = _FakeEmailService();
      final useCase = SendTrainingReportEmailUseCase(
        deliverReport: delivery,
        emailService: emailService,
      );

      final result = await useCase.execute(
        user: _user,
        trainings: [_training],
        texts: _texts,
        recipients: const ['ana@example.com'],
        subject: 'Training logs',
        htmlBody: '<p>Training</p>',
      );

      expect(result.isSuccess, isTrue);
      expect(delivery.callCount, 1);
      expect(delivery.receivedName, 'training_logs.pdf');

      final message = emailService.receivedMessage!;
      expect(message.recipients, ['ana@example.com']);
      expect(message.subject, 'Training logs');
      expect(message.htmlBody, '<p>Training</p>');
      expect(message.attachments, [delivery.file]);
    });

    test('rejects an empty recipient list before generating a file', () async {
      final delivery = _FakeDeliverReport();
      final emailService = _FakeEmailService();
      final useCase = SendTrainingReportEmailUseCase(
        deliverReport: delivery,
        emailService: emailService,
      );

      final result = await useCase.execute(
        user: _user,
        trainings: [_training],
        texts: _texts,
        recipients: const [],
        subject: 'Training logs',
        htmlBody: '<p>Training</p>',
      );

      expect(result.isFailure, isTrue);
      expect(result.error!.code, AppErrorCode.invalidData);
      expect(delivery.callCount, 0);
      expect(emailService.receivedMessage, isNull);
    });

    test('rejects a blank recipient before generating a file', () async {
      final delivery = _FakeDeliverReport();
      final emailService = _FakeEmailService();
      final useCase = SendTrainingReportEmailUseCase(
        deliverReport: delivery,
        emailService: emailService,
      );

      final result = await useCase.execute(
        user: _user,
        trainings: [_training],
        texts: _texts,
        recipients: const ['  '],
        subject: 'Training logs',
        htmlBody: '<p>Training</p>',
      );

      expect(result.isFailure, isTrue);
      expect(result.error!.code, AppErrorCode.invalidData);
      expect(delivery.callCount, 0);
    });

    test('propagates email failure through the delivery coordinator', () async {
      final delivery = _FakeDeliverReport();
      final emailService = _FakeEmailService()
        ..error = const AppError(
          code: AppErrorCode.unexpected,
          message: 'email failed',
        );
      final useCase = SendTrainingReportEmailUseCase(
        deliverReport: delivery,
        emailService: emailService,
      );

      final result = await useCase.execute(
        user: _user,
        trainings: [_training],
        texts: _texts,
        recipients: const ['ana@example.com'],
        subject: 'Training logs',
        htmlBody: '<p>Training</p>',
      );

      expect(result.isFailure, isTrue);
      expect(result.error, emailService.error);
    });
  });
}

const _user = User(
  id: 1,
  name: 'Ana',
  email: 'ana@example.com',
);

final _training = Training.create(
  id: 10,
  userId: 1,
  date: DateTime(2026, 8, 26),
).value!;

const _texts = TrainingReportPdfTexts(
  locale: 'pt-BR',
  reportTitle: 'Relatório',
  userLabel: 'Usuário',
  dateLabel: 'Data',
  totalDistanceLabel: 'Distância total',
  totalTimeLabel: 'Tempo total',
  averageSpeedLabel: 'Velocidade média',
  lapDistanceLabel: 'Distância da volta',
  splitDistanceLabel: 'Distância da parcial',
  lapCountLabel: 'Voltas',
  eventColumnLabel: 'Evento',
  timeColumnLabel: 'Tempo',
  speedColumnLabel: 'Velocidade',
  commentsColumnLabel: 'Comentários',
  trainingStartedLabel: 'Início',
  splitLabel: 'Parcial',
  lapLabel: 'Volta',
);

final class _FakeDeliverReport implements DeliverTrainingReportUseCase {
  final TemporaryReportFile file = const TemporaryReportFile(
    path: '/temporary/training_logs.pdf',
    name: 'training_logs.pdf',
    mimeType: 'application/pdf',
  );

  int callCount = 0;
  User? receivedUser;
  List<Training>? receivedTrainings;
  TrainingReportPdfTexts? receivedTexts;
  String? receivedName;

  @override
  AsyncResult<Unit> execute({
    required User user,
    required List<Training> trainings,
    required TrainingReportPdfTexts texts,
    required String suggestedName,
    required TrainingReportDelivery deliver,
  }) {
    callCount++;
    receivedUser = user;
    receivedTrainings = trainings;
    receivedTexts = texts;
    receivedName = suggestedName;
    return deliver(file);
  }
}

final class _FakeShareService implements ReportShareService {
  TemporaryReportFile? receivedFile;
  String? receivedSubject;
  AppError? error;

  @override
  AsyncResult<Unit> share({
    required TemporaryReportFile file,
    required String subject,
  }) async {
    receivedFile = file;
    receivedSubject = subject;

    final currentError = error;
    return currentError == null ? const Success(unit) : Failure(currentError);
  }
}

final class _FakeEmailService implements ReportEmailService {
  ReportEmailMessage? receivedMessage;
  AppError? error;

  @override
  AsyncResult<Unit> send(ReportEmailMessage message) async {
    receivedMessage = message;

    final currentError = error;
    return currentError == null ? const Success(unit) : Failure(currentError);
  }
}
