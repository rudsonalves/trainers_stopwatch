import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:trainers_stopwatch/core/result/result.dart';
import 'package:trainers_stopwatch/data/repositories/histories/history_repository.dart';
import 'package:trainers_stopwatch/domain/common/history/models/history_entry.dart';
import 'package:trainers_stopwatch/domain/common/report/models/training_report_content.dart';
import 'package:trainers_stopwatch/domain/common/report/services/temporary_report_file_storage.dart';
import 'package:trainers_stopwatch/domain/common/report/services/training_report_pdf_renderer.dart';
import 'package:trainers_stopwatch/domain/common/training/models/training.dart';
import 'package:trainers_stopwatch/domain/common/user/models/user.dart';
import 'package:trainers_stopwatch/domain/usecases/reports/build_training_report_use_case.dart';
import 'package:trainers_stopwatch/domain/usecases/reports/generate_training_report_file_use_case.dart';

void main() {
  late _FakeHistoryRepository repository;
  late _FakeRenderer renderer;
  late _FakeFileStorage storage;
  late GenerateTrainingReportFileUseCase useCase;

  const user = User(
    id: 1,
    name: 'Ana',
    email: 'ana@example.com',
  );

  setUp(() {
    repository = _FakeHistoryRepository()
      ..histories = _histories(trainingId: 10);
    renderer = _FakeRenderer();
    storage = _FakeFileStorage();

    useCase = GenerateTrainingReportFileUseCase(
      buildReport: BuildTrainingReportUseCase(
        historyRepository: repository,
      ),
      renderer: renderer,
      fileStorage: storage,
    );
  });

  test('builds, renders and writes the report in order', () async {
    final result = await useCase.execute(
      user: user,
      trainings: [_training],
      texts: _texts,
      suggestedName: 'training_logs.pdf',
    );

    expect(result.isSuccess, isTrue);
    expect(result.value, storage.file);
    expect(repository.loadedTrainingIds, [10]);
    expect(renderer.receivedContent, isNotNull);
    expect(renderer.receivedTexts, _texts);
    expect(storage.receivedName, 'training_logs.pdf');
    expect(storage.receivedMimeType, 'application/pdf');
    expect(storage.receivedBytes, renderer.bytes);
  });

  test('does not render or write when report building fails', () async {
    repository.loadError = const AppError(
      code: AppErrorCode.storageReadFailed,
      message: 'load failed',
    );

    final result = await useCase.execute(
      user: user,
      trainings: [_training],
      texts: _texts,
      suggestedName: 'training_logs.pdf',
    );

    expect(result.isFailure, isTrue);
    expect(result.error, repository.loadError);
    expect(renderer.callCount, 0);
    expect(storage.writeCount, 0);
  });

  test('does not write when rendering fails', () async {
    renderer.error = const AppError(
      code: AppErrorCode.unexpected,
      message: 'render failed',
    );

    final result = await useCase.execute(
      user: user,
      trainings: [_training],
      texts: _texts,
      suggestedName: 'training_logs.pdf',
    );

    expect(result.isFailure, isTrue);
    expect(result.error, renderer.error);
    expect(renderer.callCount, 1);
    expect(storage.writeCount, 0);
  });

  test('propagates temporary file write failure', () async {
    storage.writeError = const AppError(
      code: AppErrorCode.storageWriteFailed,
      message: 'write failed',
    );

    final result = await useCase.execute(
      user: user,
      trainings: [_training],
      texts: _texts,
      suggestedName: 'training_logs.pdf',
    );

    expect(result.isFailure, isTrue);
    expect(result.error, storage.writeError);
    expect(renderer.callCount, 1);
    expect(storage.writeCount, 1);
  });
}

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

List<HistoryEntry> _histories({required int trainingId}) => [
      HistoryEntry.create(
        id: 1,
        trainingId: trainingId,
        duration: Duration.zero,
      ).value!,
      HistoryEntry.create(
        id: 2,
        trainingId: trainingId,
        duration: const Duration(seconds: 20),
      ).value!,
    ];

final class _FakeHistoryRepository implements HistoryRepository {
  List<HistoryEntry> histories = const [];
  AppError? loadError;
  final List<int> loadedTrainingIds = [];

  @override
  AsyncResult<List<HistoryEntry>> loadForTraining(int trainingId) async {
    loadedTrainingIds.add(trainingId);
    final error = loadError;
    return error == null ? Success(histories) : Failure(error);
  }

  @override
  List<HistoryEntry> historiesForTraining(int trainingId) => histories;

  @override
  AsyncResult<HistoryEntry> insert(HistoryEntry entry) =>
      throw UnimplementedError();

  @override
  AsyncResult<HistoryEntry> insertIdempotent(HistoryEntry entry) =>
      throw UnimplementedError();

  @override
  AsyncResult<Unit> update(HistoryEntry entry) => throw UnimplementedError();

  @override
  AsyncResult<Unit> deleteAndMergeNext({
    required int trainingId,
    required int historyEntryId,
  }) =>
      throw UnimplementedError();
}

final class _FakeRenderer implements TrainingReportPdfRenderer {
  final Uint8List bytes = Uint8List.fromList([1, 2, 3]);
  AppError? error;
  int callCount = 0;
  TrainingReportContent? receivedContent;
  TrainingReportPdfTexts? receivedTexts;

  @override
  AsyncResult<Uint8List> render({
    required TrainingReportContent content,
    required TrainingReportPdfTexts texts,
  }) async {
    callCount++;
    receivedContent = content;
    receivedTexts = texts;

    final currentError = error;
    return currentError == null ? Success(bytes) : Failure(currentError);
  }
}

final class _FakeFileStorage implements TemporaryReportFileStorage {
  final TemporaryReportFile file = const TemporaryReportFile(
    path: '/temporary/training_logs.pdf',
    name: 'training_logs.pdf',
    mimeType: 'application/pdf',
  );

  AppError? writeError;
  int writeCount = 0;
  String? receivedName;
  String? receivedMimeType;
  Uint8List? receivedBytes;

  @override
  AsyncResult<TemporaryReportFile> write({
    required String suggestedName,
    required String mimeType,
    required Uint8List bytes,
  }) async {
    writeCount++;
    receivedName = suggestedName;
    receivedMimeType = mimeType;
    receivedBytes = bytes;

    final error = writeError;
    return error == null ? Success(file) : Failure(error);
  }

  @override
  AsyncResult<Unit> delete(TemporaryReportFile file) =>
      throw UnimplementedError();
}
