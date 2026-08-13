import 'package:flutter_test/flutter_test.dart';
import 'package:trainers_stopwatch/common/functions/training_report.dart';
import 'package:trainers_stopwatch/common/models/history_model.dart';
import 'package:trainers_stopwatch/common/models/messages_model.dart';
import 'package:trainers_stopwatch/common/models/training_model.dart';
import 'package:trainers_stopwatch/common/models/user_model.dart';

void main() {
  test('legacy report delegates event generation and maps messages', () {
    final report = TrainingReport(
      user: UserModel(id: 1, name: 'Ana', email: 'ana@example.com'),
      training: TrainingModel(
        id: 10,
        userId: 1,
        date: DateTime(2026),
        splitLength: 200,
        lapLength: 1000,
      ),
      histories: [
        HistoryModel(
          id: 1,
          trainingId: 10,
          duration: Duration.zero,
          comments: 'started',
        ),
        for (var index = 0; index < 5; index++)
          HistoryModel(
            id: index + 2,
            trainingId: 10,
            duration: const Duration(seconds: 20),
            comments: 'split',
          ),
      ],
    );

    report.createMessages();

    expect(report.messages, hasLength(7));
    expect(report.messages.first.msgType, MessageType.isStarting);
    expect(
      report.messages
          .where((message) => message.msgType == MessageType.isSplit)
          .map((message) => message.label),
      ['Split[1]', 'Split[2]', 'Split[3]', 'Split[4]', 'Split[5]'],
    );
    final lap = report.messages.last;
    expect(lap.msgType, MessageType.isLap);
    expect(lap.label, 'Lap[1]');
    expect(lap.duration, const Duration(seconds: 100));
  });

  test('legacy getIndex remains available to active stopwatch code', () {
    final split = TrainingReport.getIndex(1, 5);
    final lap = TrainingReport.getIndex(5, 5);

    expect(split.isLap, isFalse);
    expect(split.splitIndex, 1);
    expect(lap.isLap, isTrue);
    expect(lap.lapIndex, 1);
    expect(lap.splitIndex, 5);
  });
}
