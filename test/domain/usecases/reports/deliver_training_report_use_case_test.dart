import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:trainers_stopwatch/core/result/result.dart';
import 'package:trainers_stopwatch/domain/common/report/models/training_report_content.dart';
import 'package:trainers_stopwatch/domain/common/report/models/training_report_section.dart';
import 'package:trainers_stopwatch/domain/common/report/models/training_report_totals.dart';
import 'package:trainers_stopwatch/domain/common/report/services/temporary_report_file_storage.dart';
import 'package:trainers_stopwatch/domain/common/report/services/training_report_pdf_renderer.dart';
import 'package:trainers_stopwatch/domain/common/training/models/training.dart';
import 'package:trainers_stopwatch/domain/common/training/values/distance.dart';
import 'package:trainers_stopwatch/domain/common/training/values/speed.dart';
import 'package:trainers_stopwatch/domain/common/user/models/user.dart';
import 'package:trainers_stopwatch/domain/usecases/reports/deliver_training_report_use_case.dart';
import 'package:trainers_stopwatch/domain/usecases/reports/generate_training_report_file_use_case.dart';

void main() {
  late List<String> events;
  late _FakeGenerateFile generateFile;
  late _FakeFileStorage storage;
  late DeliverTrainingReportUseCase useCase;

  setUp(() {
    events = [];
    generateFile = _FakeGenerateFile(events);
    storage = _FakeFileStorage(events);

    useCase = DeliverTrainingReportUseCase(
      generateFile: generateFile,
      fileStorage: storage,
    );
  });

  test('does not generate or deliver prepared content without sections',
      () async {
    final content = TrainingReportContent(
      user: _user,
      sections: const [],
    );
    var deliveryCalled = false;

    final result = await useCase.executeFromContent(
      content: content,
      texts: _texts,
      suggestedName: 'training_logs.pdf',
      deliver: (_) async {
        deliveryCalled = true;
        return const Success(unit);
      },
    );

    expect(result.isFailure, isTrue);
    expect(result.error!.code, AppErrorCode.invalidData);
    expect(deliveryCalled, isFalse);
    expect(events, isEmpty);
    expect(storage.deletedFiles, isEmpty);
  });

  test('generates, delivers and deletes in order', () async {
    final result = await useCase.execute(
      user: _user,
      trainings: [_training],
      texts: _texts,
      suggestedName: 'training_logs.pdf',
      deliver: (file) async {
        events.add('deliver');
        expect(file, generateFile.file);
        return const Success(unit);
      },
    );

    expect(result.isSuccess, isTrue);
    expect(events, ['generate', 'deliver', 'delete']);
    expect(storage.deletedFiles, [generateFile.file]);
  });

  test('delivers prepared content without rebuilding the report', () async {
    final content = TrainingReportContent(
      user: _user,
      sections: [
        TrainingReportSection(
          training: _training,
          rows: const [],
          totals: TrainingReportTotals(
            distance: Distance.create(value: 200).value!,
            duration: const Duration(seconds: 20),
            lapCount: 0,
            averageSpeed: Speed.create(value: 10).value!,
          ),
        ),
      ],
    );

    final result = await useCase.executeFromContent(
      content: content,
      texts: _texts,
      suggestedName: 'training_logs.pdf',
      deliver: (file) async {
        events.add('deliver');
        expect(file, generateFile.file);
        return const Success(unit);
      },
    );

    expect(result.isSuccess, isTrue);
    expect(events, ['generate-content', 'deliver', 'delete']);
    expect(storage.deletedFiles, [generateFile.file]);
  });

  test('does not deliver or delete when generation fails', () async {
    generateFile.error = const AppError(
      code: AppErrorCode.storageWriteFailed,
      message: 'generation failed',
    );

    var deliveryCalled = false;
    final result = await useCase.execute(
      user: _user,
      trainings: [_training],
      texts: _texts,
      suggestedName: 'training_logs.pdf',
      deliver: (_) async {
        deliveryCalled = true;
        return const Success(unit);
      },
    );

    expect(result.isFailure, isTrue);
    expect(result.error, generateFile.error);
    expect(deliveryCalled, isFalse);
    expect(storage.deletedFiles, isEmpty);
    expect(events, ['generate']);
  });

  test('deletes the file after a delivery failure', () async {
    const deliveryError = AppError(
      code: AppErrorCode.unexpected,
      message: 'delivery failed',
    );

    final result = await useCase.execute(
      user: _user,
      trainings: [_training],
      texts: _texts,
      suggestedName: 'training_logs.pdf',
      deliver: (_) async {
        events.add('deliver');
        return const Failure(deliveryError);
      },
    );

    expect(result.isFailure, isTrue);
    expect(result.error, deliveryError);
    expect(events, ['generate', 'deliver', 'delete']);
    expect(storage.deletedFiles, [generateFile.file]);
  });

  test('deletes the file when delivery throws', () async {
    final result = await useCase.execute(
      user: _user,
      trainings: [_training],
      texts: _texts,
      suggestedName: 'training_logs.pdf',
      deliver: (_) async {
        events.add('deliver');
        throw StateError('unexpected delivery failure');
      },
    );

    expect(result.isFailure, isTrue);
    expect(result.error!.code, AppErrorCode.unexpected);
    expect(result.error!.details, isA<StateError>());
    expect(events, ['generate', 'deliver', 'delete']);
  });

  test('returns cleanup failure after successful delivery', () async {
    storage.deleteError = const AppError(
      code: AppErrorCode.storageWriteFailed,
      message: 'cleanup failed',
    );

    final result = await useCase.execute(
      user: _user,
      trainings: [_training],
      texts: _texts,
      suggestedName: 'training_logs.pdf',
      deliver: (_) async {
        events.add('deliver');
        return const Success(unit);
      },
    );

    expect(result.isFailure, isTrue);
    expect(result.error, storage.deleteError);
    expect(events, ['generate', 'deliver', 'delete']);
  });

  test('preserves delivery and cleanup errors together', () async {
    const deliveryError = AppError(
      code: AppErrorCode.unexpected,
      message: 'delivery failed',
    );
    const cleanupError = AppError(
      code: AppErrorCode.storageWriteFailed,
      message: 'cleanup failed',
    );
    storage.deleteError = cleanupError;

    final result = await useCase.execute(
      user: _user,
      trainings: [_training],
      texts: _texts,
      suggestedName: 'training_logs.pdf',
      deliver: (_) async {
        events.add('deliver');
        return const Failure(deliveryError);
      },
    );

    expect(result.isFailure, isTrue);
    expect(result.error!.code, deliveryError.code);

    final details = result.error!.details as ({
      AppError primaryError,
      AppError cleanupError,
      String filePath,
    });

    expect(details.primaryError, deliveryError);
    expect(details.cleanupError, cleanupError);
    expect(details.filePath, generateFile.file.path);
    expect(events, ['generate', 'deliver', 'delete']);
  });

  test('maps an unexpected cleanup exception', () async {
    storage.throwOnDelete = true;

    final result = await useCase.execute(
      user: _user,
      trainings: [_training],
      texts: _texts,
      suggestedName: 'training_logs.pdf',
      deliver: (_) async {
        events.add('deliver');
        return const Success(unit);
      },
    );

    expect(result.isFailure, isTrue);
    expect(result.error!.code, AppErrorCode.storageWriteFailed);
    expect(result.error!.details, isA<StateError>());
    expect(events, ['generate', 'deliver', 'delete']);
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

final class _FakeGenerateFile implements GenerateTrainingReportFileUseCase {
  final List<String> events;

  final TemporaryReportFile file = const TemporaryReportFile(
    path: '/temporary/training_logs.pdf',
    name: 'training_logs.pdf',
    mimeType: 'application/pdf',
  );

  AppError? error;

  _FakeGenerateFile(this.events);

  @override
  AsyncResult<TemporaryReportFile> execute({
    required User user,
    required List<Training> trainings,
    required TrainingReportPdfTexts texts,
    required String suggestedName,
  }) async {
    events.add('generate');
    final currentError = error;
    return currentError == null ? Success(file) : Failure(currentError);
  }

  @override
  AsyncResult<TemporaryReportFile> generateFromContent({
    required TrainingReportContent content,
    required TrainingReportPdfTexts texts,
    required String suggestedName,
  }) async {
    events.add('generate-content');
    final currentError = error;
    return currentError == null ? Success(file) : Failure(currentError);
  }
}

final class _FakeFileStorage implements TemporaryReportFileStorage {
  final List<String> events;
  final List<TemporaryReportFile> deletedFiles = [];

  AppError? deleteError;
  bool throwOnDelete = false;

  _FakeFileStorage(this.events);

  @override
  AsyncResult<Unit> delete(TemporaryReportFile file) async {
    events.add('delete');
    deletedFiles.add(file);

    if (throwOnDelete) {
      throw StateError('unexpected cleanup failure');
    }

    final currentError = deleteError;
    return currentError == null ? const Success(unit) : Failure(currentError);
  }

  @override
  AsyncResult<TemporaryReportFile> write({
    required String suggestedName,
    required String mimeType,
    required Uint8List bytes,
  }) =>
      throw UnimplementedError();
}
