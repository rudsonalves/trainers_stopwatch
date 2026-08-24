import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:trainers_stopwatch/application/stopwatch/bloc/stopwatch_bloc.dart';
import 'package:trainers_stopwatch/application/stopwatch/bloc/stopwatch_event.dart';
import 'package:trainers_stopwatch/application/stopwatch/bloc/stopwatch_state.dart';
import 'package:trainers_stopwatch/common/models/training_model.dart';
import 'package:trainers_stopwatch/common/models/user_model.dart';
import 'package:trainers_stopwatch/domain/usecases/trainings/create_training_use_case.dart';
import 'package:trainers_stopwatch/features/stopwatch_page/stopwatch_page_controller.dart';
import 'package:trainers_stopwatch/features/widgets/precise_stopwatch/precise_stopwatch.dart';
import 'package:trainers_stopwatch/features/widgets/precise_stopwatch/precise_stopwatch_controller.dart';
import 'package:trainers_stopwatch/features/widgets/precise_stopwatch/widgets/lap_split_counters.dart';
import 'package:trainers_stopwatch/features/widgets/precise_stopwatch/widgets/stopwatch_display.dart';
import 'package:trainers_stopwatch/manager/history_manager.dart';
import 'package:trainers_stopwatch/manager/training_manager.dart';

void main() {
  testWidgets('display and counters rebuild from StopwatchState',
      (tester) async {
    final bloc = StopwatchBloc(
      splitsPerLap: 2,
      tickInterval: const Duration(days: 1),
    );
    final maxLaps = ValueNotifier<int?>(null);
    addTearDown(bloc.close);
    addTearDown(maxLaps.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Row(
            children: [
              StopwatchDisplay(bloc: bloc),
              LapSplitCouters(bloc: bloc, maxLaps: maxLaps),
            ],
          ),
        ),
      ),
    );
    expect(find.text('0:00:00.00'), findsOneWidget);

    final running = bloc.stream.firstWhere(
      (state) => state.status == StopwatchStatus.running,
    );
    bloc.add(const StopwatchEventRun());
    await tester.pump();
    await running;
    final split = bloc.stream.firstWhere((state) => state.splitCount == 1);
    bloc.add(const StopwatchEventSplit());
    await tester.pump();
    await split;
    await tester.pump();
    expect(find.text('1'), findsOneWidget);
    bloc.add(const StopwatchEventPause());
    await tester.pump();
  });

  testWidgets('does not read training before controller initialization',
      (tester) async {
    final controller = DelayedPreciseStopwatchController();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PreciseStopwatch(
            user: UserModel(id: 1, name: 'Athlete', email: 'a@example.com'),
            controller: controller,
          ),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(controller.trainingWasRead, isFalse);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox());
    controller.completeInitialization();
    await tester.pump();
  });
}

final class DelayedPreciseStopwatchController
    extends PreciseStopwatchController {
  final _initialization = Completer<void>();
  bool trainingWasRead = false;

  DelayedPreciseStopwatchController()
      : super(
          trainingManager: MockTrainingManager(),
          historyManager: MockHistoryManager(),
          createTrainingUseCase: MockCreateTrainingUseCase(),
          stopwatchController: MockStopwatchPageController(),
        );

  @override
  Future<void> init(UserModel user) => _initialization.future;

  @override
  TrainingModel get training {
    trainingWasRead = true;
    if (!_initialization.isCompleted) {
      throw StateError('Training was read before initialization completed.');
    }
    return TrainingModel(
      userId: 1,
      date: DateTime.utc(2026, 8, 24),
      splitLength: 100,
      lapLength: 400,
    );
  }

  void completeInitialization() => _initialization.complete();
}

class MockTrainingManager extends Mock implements TrainingManager {}

class MockHistoryManager extends Mock implements HistoryManager {}

class MockCreateTrainingUseCase extends Mock implements CreateTrainingUseCase {}

class MockStopwatchPageController extends Mock
    implements StopwatchPageController {}
