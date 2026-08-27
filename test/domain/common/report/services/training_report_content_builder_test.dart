import 'package:flutter_test/flutter_test.dart';
import 'package:trainers_stopwatch/core/result/result.dart';
import 'package:trainers_stopwatch/domain/common/history/models/history_entry.dart';
import 'package:trainers_stopwatch/domain/common/report/services/training_report_content_builder.dart';
import 'package:trainers_stopwatch/domain/common/report/services/training_report_input.dart';
import 'package:trainers_stopwatch/domain/common/training/events/training_event.dart';
import 'package:trainers_stopwatch/domain/common/training/models/training.dart';
import 'package:trainers_stopwatch/domain/common/user/models/user.dart';

void main() {
  const builder = TrainingReportContentBuilder();
  const user = User(
    id: 1,
    name: 'Ana',
    email: 'ana@example.com',
  );

  group('TrainingReportContentBuilder', () {
    test('returns an empty report when no trainings are provided', () {
      final result = builder.build(
        user: user,
        inputs: const [],
      );

      expect(result.isSuccess, isTrue);
      expect(result.value!.user, user);
      expect(result.value!.sections, isEmpty);
    });

    test('preserves training order', () {
      final firstTraining = _training(id: 10);
      final secondTraining = _training(id: 20);

      final result = builder.build(
        user: user,
        inputs: [
          TrainingReportInput(
            training: secondTraining,
            histories: _histories(trainingId: 20),
          ),
          TrainingReportInput(
            training: firstTraining,
            histories: _histories(trainingId: 10),
          ),
        ],
      );

      expect(result.isSuccess, isTrue);
      expect(
        result.value!.sections.map((section) => section.training.id),
        [20, 10],
      );
    });

    test('builds rows and totals from persisted histories', () {
      final result = builder.build(
        user: user,
        inputs: [
          TrainingReportInput(
            training: _training(id: 10),
            histories: _histories(trainingId: 10),
          ),
        ],
      );

      expect(result.isSuccess, isTrue);

      final section = result.value!.sections.single;

      expect(section.rows, hasLength(7));
      expect(section.rows.first.event, isA<TrainingStarted>());

      expect(
        section.rows
            .where((row) => row.event is SplitRecorded)
            .map((row) => (row.event as SplitRecorded).splitIndex),
        [1, 2, 3, 4, 5],
      );

      expect(section.rows.last.event, isA<LapRecorded>());

      final lap = section.rows.last.event as LapRecorded;
      expect(lap.lapIndex, 1);
      expect(lap.duration, const Duration(seconds: 110));
      expect(lap.comments, 'lap completed');

      expect(section.totals.distance.value, 1000);
      expect(section.totals.distance.unit.symbol, 'm');
      expect(section.totals.duration, const Duration(seconds: 110));
      expect(section.totals.lapCount, 1);
      expect(section.totals.averageSpeed.value, closeTo(9.090909, 0.000001));
      expect(section.totals.averageSpeed.unit.symbol, 'm/s');
    });

    test('copies and protects histories received by an input', () {
      final histories = _histories(trainingId: 10);
      final input = TrainingReportInput(
        training: _training(id: 10),
        histories: histories,
      );

      histories.clear();

      expect(input.histories, hasLength(6));
      expect(
        () => input.histories.add(
          _history(
            id: 7,
            trainingId: 10,
            duration: const Duration(seconds: 25),
          ),
        ),
        throwsUnsupportedError,
      );
    });

    test('preserves zeroElapsedTime for a training without partials', () {
      final result = builder.build(
        user: user,
        inputs: [
          TrainingReportInput(
            training: _training(id: 10),
            histories: [
              _history(
                id: 1,
                trainingId: 10,
                duration: Duration.zero,
              ),
            ],
          ),
        ],
      );

      expect(result.isFailure, isTrue);
      expect(result.error!.code, AppErrorCode.zeroElapsedTime);
    });

    test('rejects an empty history list for a reported training', () {
      final result = builder.build(
        user: user,
        inputs: [
          TrainingReportInput(
            training: _training(id: 10),
            histories: const [],
          ),
        ],
      );

      expect(result.isFailure, isTrue);
      expect(result.error!.code, AppErrorCode.invalidData);
    });

    test('propagates invalid history timeline errors', () {
      final result = builder.build(
        user: user,
        inputs: [
          TrainingReportInput(
            training: _training(id: 10),
            histories: [
              _history(
                id: 2,
                trainingId: 10,
                duration: Duration.zero,
              ),
              _history(
                id: 1,
                trainingId: 10,
                duration: const Duration(seconds: 20),
              ),
            ],
          ),
        ],
      );

      expect(result.isFailure, isTrue);
      expect(result.error!.code, AppErrorCode.invalidData);
    });

    test('does not return sections built before a later failure', () {
      final result = builder.build(
        user: user,
        inputs: [
          TrainingReportInput(
            training: _training(id: 10),
            histories: _histories(trainingId: 10),
          ),
          TrainingReportInput(
            training: _training(id: 20),
            histories: const [],
          ),
        ],
      );

      expect(result.isFailure, isTrue);
      expect(result.value, isNull);
    });
  });
}

Training _training({required int id}) => Training.create(
      id: id,
      userId: 1,
      date: DateTime(2026, 8, 25),
    ).value!;

List<HistoryEntry> _histories({required int trainingId}) => [
      _history(
        id: 1,
        trainingId: trainingId,
        duration: Duration.zero,
        comments: 'started',
      ),
      _history(
        id: 2,
        trainingId: trainingId,
        duration: const Duration(seconds: 20),
      ),
      _history(
        id: 3,
        trainingId: trainingId,
        duration: const Duration(seconds: 21),
      ),
      _history(
        id: 4,
        trainingId: trainingId,
        duration: const Duration(seconds: 22),
      ),
      _history(
        id: 5,
        trainingId: trainingId,
        duration: const Duration(seconds: 23),
      ),
      _history(
        id: 6,
        trainingId: trainingId,
        duration: const Duration(seconds: 24),
        comments: 'lap completed',
      ),
    ];

HistoryEntry _history({
  required int id,
  required int trainingId,
  required Duration duration,
  String? comments,
}) =>
    HistoryEntry.create(
      id: id,
      trainingId: trainingId,
      duration: duration,
      comments: comments,
    ).value!;
