import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:trainers_stopwatch/application/stopwatch/bloc/stopwatch_bloc.dart';
import 'package:trainers_stopwatch/application/stopwatch/bloc/stopwatch_event.dart';
import 'package:trainers_stopwatch/application/stopwatch/bloc/stopwatch_state.dart';
import 'package:trainers_stopwatch/application/stopwatch/session/stopwatch_session_view_model.dart';
import 'package:trainers_stopwatch/domain/common/training/models/training.dart';
import 'package:trainers_stopwatch/domain/common/user/models/user.dart';
import 'package:trainers_stopwatch/domain/usecases/trainings/create_training_use_case.dart';
import 'package:trainers_stopwatch/domain/usecases/trainings/persist_stopwatch_snapshot_use_case.dart';
import 'package:trainers_stopwatch/features/stopwatch_page/stopwatch_page.dart';
import 'package:trainers_stopwatch/features/stopwatch_page/widgets/stopwatch_dismissible.dart';
import 'package:trainers_stopwatch/features/widgets/precise_stopwatch/precise_stopwatch.dart';
import 'package:trainers_stopwatch/features/widgets/precise_stopwatch/widgets/lap_split_counters.dart';
import 'package:trainers_stopwatch/features/widgets/precise_stopwatch/widgets/stopwatch_display.dart';
import 'package:trainers_stopwatch/ui/pages/stopwatch/stopwatch_page_view_model.dart';

void main() {
  testWidgets('display and counters rebuild from StopwatchState',
      (tester) async {
    final bloc = StopwatchBloc(
      splitsPerLap: 2,
      tickInterval: const Duration(days: 1),
    );
    addTearDown(bloc.close);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Row(
            children: [
              StopwatchDisplay(bloc: bloc),
              LapSplitCouters(bloc: bloc, maxLaps: null),
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

  testWidgets('renders directly from a stopwatch session', (tester) async {
    const user = User(
      id: 1,
      name: 'Athlete',
      email: 'a@example.com',
    );
    final session = StopwatchSessionViewModel(
      user: user,
      training: Training.create(
        userId: 1,
        date: DateTime.utc(2026, 8, 24),
      ).value!,
      bloc: StopwatchBloc(tickInterval: const Duration(days: 1)),
      createTrainingUseCase: MockCreateTrainingUseCase(),
      persistSnapshotUseCase: MockPersistStopwatchSnapshotUseCase(),
    );
    addTearDown(session.close);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PreciseStopwatch(session: session),
        ),
      ),
    );

    expect(find.text('Athlete'), findsOneWidget);
    expect(find.text('0:00:00.00'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('page builds session widgets with stable athlete keys',
      (tester) async {
    const user = User(
      id: 7,
      name: 'Athlete',
      email: 'a@example.com',
    );
    final viewModel = StopwatchPageViewModel(
      sessionFactory: (user) => StopwatchSessionViewModel(
        user: user,
        training: Training.create(
          userId: user.id!,
          date: DateTime.utc(2026, 8, 24),
        ).value!,
        bloc: StopwatchBloc(tickInterval: const Duration(days: 1)),
        createTrainingUseCase: MockCreateTrainingUseCase(),
        persistSnapshotUseCase: MockPersistStopwatchSnapshotUseCase(),
      ),
    );
    viewModel.addUsers([user]);
    addTearDown(viewModel.close);

    await tester.pumpWidget(
      MaterialApp(home: StopWatchPage(viewModel: viewModel)),
    );

    expect(find.byType(StopwatDismissible), findsOneWidget);
    expect(find.byKey(const ValueKey(7)), findsWidgets);
    expect(find.byType(PreciseStopwatch), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

class MockCreateTrainingUseCase extends Mock implements CreateTrainingUseCase {}

class MockPersistStopwatchSnapshotUseCase extends Mock
    implements PersistStopwatchSnapshotUseCase {}
