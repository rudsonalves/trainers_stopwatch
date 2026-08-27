import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:trainers_stopwatch/core/result/result.dart';
import 'package:trainers_stopwatch/domain/common/history/models/history_entry.dart';
import 'package:trainers_stopwatch/domain/common/settings/models/settings.dart';
import 'package:trainers_stopwatch/domain/common/stopwatch/models/stopwatch_snapshot.dart';
import 'package:trainers_stopwatch/domain/common/training/models/training.dart';
import 'package:trainers_stopwatch/domain/common/user/models/user.dart';
import 'package:trainers_stopwatch/domain/usecases/trainings/create_training_use_case.dart';
import 'package:trainers_stopwatch/domain/usecases/trainings/persist_stopwatch_snapshot_use_case.dart';
import 'package:trainers_stopwatch/domain/usecases/trainings/training_initialization.dart';
import 'package:trainers_stopwatch/ui/components/dialogs/generic_dialog.dart';
import 'package:trainers_stopwatch/ui/components/precise_stopwatch/precise_stopwatch.dart';
import 'package:trainers_stopwatch/ui/components/precise_stopwatch/widgets/lap_split_counters.dart';
import 'package:trainers_stopwatch/ui/components/precise_stopwatch/widgets/stopwatch_display.dart';
import 'package:trainers_stopwatch/ui/pages/settings/viewmodel/models/settings_form_data.dart';
import 'package:trainers_stopwatch/ui/pages/settings/viewmodel/settings_view_model.dart';
import 'package:trainers_stopwatch/ui/pages/stopwatch/bloc/stopwatch_bloc.dart';
import 'package:trainers_stopwatch/ui/pages/stopwatch/bloc/stopwatch_event.dart';
import 'package:trainers_stopwatch/ui/pages/stopwatch/bloc/stopwatch_state.dart';
import 'package:trainers_stopwatch/ui/pages/stopwatch/session/stopwatch_session_view_model.dart';
import 'package:trainers_stopwatch/ui/pages/stopwatch/stopwatch_page.dart';
import 'package:trainers_stopwatch/ui/pages/stopwatch/stopwatch_page_view_model.dart';
import 'package:trainers_stopwatch/ui/pages/stopwatch/widgets/stopwatch_dismissible.dart';

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

  testWidgets('shows a recoverable error when training creation fails',
      (tester) async {
    const user = User(id: 2, name: 'Bia', email: 'b@example.com');
    final session = StopwatchSessionViewModel(
      user: user,
      training: Training.create(
        userId: 2,
        date: DateTime.utc(2026, 8, 24),
      ).value!,
      bloc: StopwatchBloc(tickInterval: const Duration(days: 1)),
      createTrainingUseCase: FailingCreateTrainingUseCase(),
      persistSnapshotUseCase: MockPersistStopwatchSnapshotUseCase(),
    );
    addTearDown(session.close);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: PreciseStopwatch(session: session)),
      ),
    );
    await tester.tap(find.text('PSStart'));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.error_outline), findsOneWidget);
    expect(session.bloc.state.status, StopwatchStatus.idle);
  });

  testWidgets('dismissible delegates removal and editing with the session',
      (tester) async {
    const user = User(id: 3, name: 'Caio', email: 'c@example.com');
    final session = StopwatchSessionViewModel(
      user: user,
      training: Training.create(
        userId: 3,
        date: DateTime.utc(2026, 8, 24),
      ).value!,
      bloc: StopwatchBloc(tickInterval: const Duration(days: 1)),
      createTrainingUseCase: MockCreateTrainingUseCase(),
      persistSnapshotUseCase: MockPersistStopwatchSnapshotUseCase(),
    );
    addTearDown(session.close);
    StopwatchSessionViewModel? edited;
    int? removedUserId;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StopwatDismissible(
            session: session,
            removeStopwatch: (id) async {
              removedUserId = id.userId;
              return true;
            },
            managerStopwatch: (value) async => edited = value,
          ),
        ),
      ),
    );
    final dismissible = tester.widget<Dismissible>(find.byType(Dismissible));

    expect(
      await dismissible.confirmDismiss!(DismissDirection.endToStart),
      isTrue,
    );
    expect(removedUserId, 3);
    expect(
      await dismissible.confirmDismiss!(DismissDirection.startToEnd),
      isFalse,
    );
    expect(edited, same(session));
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
      MaterialApp(
          home: StopWatchPage(
        viewModel: viewModel,
        settingsViewModel: MockSettingsViewModel(),
      )),
    );

    expect(find.byType(StopwatDismissible), findsOneWidget);
    expect(find.byKey(const ValueKey(7)), findsWidgets);
    expect(find.byType(PreciseStopwatch), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('active session dismissal asks confirmation and cancel keeps it',
      (tester) async {
    const user = User(id: 9, name: 'Dora', email: 'd@example.com');
    final viewModel = StopwatchPageViewModel(
      sessionFactory: (user) => StopwatchSessionViewModel(
        user: user,
        training: Training.create(
          userId: user.id!,
          date: DateTime.utc(2026, 8, 24),
        ).value!,
        bloc: StopwatchBloc(tickInterval: const Duration(days: 1)),
        createTrainingUseCase: SuccessfulCreateTrainingUseCase(),
        persistSnapshotUseCase: SuccessfulPersistSnapshotUseCase(),
      ),
    );
    viewModel.addUsers([user]);
    addTearDown(viewModel.close);
    final session = viewModel.sessions.single;
    await session.start();

    await tester.pumpWidget(
      MaterialApp(
          home: StopWatchPage(
        viewModel: viewModel,
        settingsViewModel: MockSettingsViewModel(),
      )),
    );
    await tester.drag(find.byType(Dismissible), const Offset(-500, 0));
    await tester.pumpAndSettle();

    expect(find.byType(GenericDialog), findsOneWidget);
    await tester.tap(find.text('GenericNo'));
    await tester.pumpAndSettle();
    expect(viewModel.sessions.single, same(session));
    expect(session.bloc.state.status, StopwatchStatus.running);
    await session.pause();
  });

  testWidgets('brightness button delegates the toggle to SettingsViewModel',
      (tester) async {
    final stopwatchViewModel = StopwatchPageViewModel(
      sessionFactory: (_) => throw UnimplementedError(),
    );
    final settingsViewModel = MockSettingsViewModel();

    when(settingsViewModel.state).thenReturn(
      SettingsFormData.fromDomain(Settings.create().value!),
    );
    when(settingsViewModel.toggleBrightness()).thenAnswer((_) async {});

    addTearDown(stopwatchViewModel.close);

    await tester.pumpWidget(
      MaterialApp(
        home: StopWatchPage(
          viewModel: stopwatchViewModel,
          settingsViewModel: settingsViewModel,
        ),
      ),
    );

    expect(find.byIcon(Icons.dark_mode), findsOneWidget);

    await tester.tap(find.byIcon(Icons.dark_mode));
    await tester.pump();

    verify(settingsViewModel.toggleBrightness()).called(1);
  });
}

class MockCreateTrainingUseCase extends Mock implements CreateTrainingUseCase {}

class FailingCreateTrainingUseCase implements CreateTrainingUseCase {
  @override
  AsyncResult<TrainingInitialization> execute({
    required Training training,
    String? initialComments,
  }) async =>
      const Failure(
        AppError(
          code: AppErrorCode.storageWriteFailed,
          message: 'write failed',
        ),
      );
}

class SuccessfulCreateTrainingUseCase implements CreateTrainingUseCase {
  @override
  AsyncResult<TrainingInitialization> execute({
    required Training training,
    String? initialComments,
  }) async {
    final persisted = Training.create(
      id: 50,
      userId: training.userId,
      date: training.date,
      comments: training.comments,
      splitDistance: training.splitDistance,
      lapDistance: training.lapDistance,
      maxLaps: training.maxLaps,
      speedUnit: training.speedUnit,
    ).value!;
    return Success(
      TrainingInitialization(
        training: persisted,
        initialHistory: HistoryEntry.create(
          id: 1,
          trainingId: 50,
          duration: Duration.zero,
          comments: initialComments,
        ).value!,
      ),
    );
  }
}

class SuccessfulPersistSnapshotUseCase
    implements PersistStopwatchSnapshotUseCase {
  @override
  AsyncResult<HistoryEntry> execute({
    required int trainingId,
    required int snapshotRevision,
    required StopwatchSnapshot snapshot,
    String? comments,
  }) async =>
      HistoryEntry.create(
        id: 2,
        trainingId: trainingId,
        duration: snapshot.elapsed,
        comments: comments,
        snapshotRevision: snapshotRevision,
      );
}

class MockPersistStopwatchSnapshotUseCase extends Mock
    implements PersistStopwatchSnapshotUseCase {}

class MockSettingsViewModel extends Mock implements SettingsViewModel {
  @override
  Future<void> toggleBrightness() => super.noSuchMethod(
        Invocation.method(#toggleBrightness, []),
        returnValue: Future<void>.value(),
      ) as Future<void>;
}
