import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trainers_stopwatch/core/result/result.dart';
import 'package:trainers_stopwatch/data/services/reports/training_report_pdf_renderer_impl.dart';
import 'package:trainers_stopwatch/domain/common/history/models/history_entry.dart';
import 'package:trainers_stopwatch/domain/common/report/models/training_report_content.dart';
import 'package:trainers_stopwatch/domain/common/report/services/training_report_content_builder.dart';
import 'package:trainers_stopwatch/domain/common/report/services/training_report_input.dart';
import 'package:trainers_stopwatch/domain/common/report/services/training_report_pdf_renderer.dart';
import 'package:trainers_stopwatch/domain/common/training/models/training.dart';
import 'package:trainers_stopwatch/domain/common/user/models/user.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const user = User(
    id: 1,
    name: 'Ana',
    email: 'ana@example.com',
  );

  const texts = TrainingReportPdfTexts(
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

  test('renders report content as PDF bytes with Unicode texts', () async {
    final renderer = TrainingReportPdfRendererImpl();
    final content = _content(
      user: user,
      trainingIds: const [10],
    );

    final result = await renderer.render(
      content: content,
      texts: texts,
    );

    expect(result.isSuccess, isTrue);
    expect(result.value, isA<Uint8List>());
    expect(result.value, isNotEmpty);
    expect(
      ascii.decode(result.value!.sublist(0, 5)),
      '%PDF-',
    );
  });

  test('renders every received training section', () async {
    final renderer = TrainingReportPdfRendererImpl();
    final singleSection = _content(
      user: user,
      trainingIds: const [10],
    );
    final multipleSections = _content(
      user: user,
      trainingIds: const [10, 20],
    );

    final singleResult = await renderer.render(
      content: singleSection,
      texts: texts,
    );
    final multipleResult = await renderer.render(
      content: multipleSections,
      texts: texts,
    );

    expect(singleResult.isSuccess, isTrue);
    expect(multipleResult.isSuccess, isTrue);
    expect(
      multipleResult.value!.length,
      greaterThan(singleResult.value!.length),
    );
  });

  test('preserves the empty report as a valid zero-page PDF', () async {
    final renderer = TrainingReportPdfRendererImpl();
    final content = TrainingReportContent(
      user: user,
      sections: const [],
    );

    final result = await renderer.render(
      content: content,
      texts: texts,
    );

    expect(result.isSuccess, isTrue);
    expect(result.value, isNotEmpty);
    expect(
      ascii.decode(result.value!.sublist(0, 5)),
      '%PDF-',
    );
  });

  test('maps asset loading failures to AppError', () async {
    final renderer = TrainingReportPdfRendererImpl(
      assetBundle: _FailingAssetBundle(),
    );
    final content = _content(
      user: user,
      trainingIds: const [10],
    );

    final result = await renderer.render(
      content: content,
      texts: texts,
    );

    expect(result.isFailure, isTrue);
    expect(result.error!.code, AppErrorCode.unexpected);
    expect(result.error!.details, isA<StateError>());
  });
}

TrainingReportContent _content({
  required User user,
  required List<int> trainingIds,
}) {
  const builder = TrainingReportContentBuilder();

  final result = builder.build(
    user: user,
    inputs: trainingIds
        .map(
          (trainingId) => TrainingReportInput(
            training: _training(trainingId),
            histories: _histories(trainingId),
          ),
        )
        .toList(growable: false),
  );

  expect(result.isSuccess, isTrue);
  return result.value!;
}

Training _training(int id) => Training.create(
      id: id,
      userId: 1,
      date: DateTime(2026, 8, 25, 10, 30),
    ).value!;

List<HistoryEntry> _histories(int trainingId) => [
      HistoryEntry.create(
        id: 1,
        trainingId: trainingId,
        duration: Duration.zero,
        comments: 'Início',
      ).value!,
      HistoryEntry.create(
        id: 2,
        trainingId: trainingId,
        duration: const Duration(seconds: 20),
        comments: 'Parcial concluída',
      ).value!,
    ];

final class _FailingAssetBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async {
    throw StateError('Asset unavailable: $key');
  }
}
