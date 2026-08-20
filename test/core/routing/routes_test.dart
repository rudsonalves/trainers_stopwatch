import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:trainers_stopwatch/common/functions/share_functions.dart';
import 'package:trainers_stopwatch/core/config/dependencies.dart';
import 'package:trainers_stopwatch/core/routing/animations_page/app_custom_transition_page.dart';
import 'package:trainers_stopwatch/core/routing/route_arguments.dart';
import 'package:trainers_stopwatch/core/routing/routes.dart';
import 'package:trainers_stopwatch/core/routing/routes/main_routes.dart';
import 'package:trainers_stopwatch/data/repositories/histories/history_repository.dart';
import 'package:trainers_stopwatch/data/repositories/trainings/training_repository.dart';
import 'package:trainers_stopwatch/data/repositories/users/user_repository.dart';
import 'package:trainers_stopwatch/domain/common/training/models/training.dart';
import 'package:trainers_stopwatch/domain/common/user/models/user.dart';
import 'package:trainers_stopwatch/domain/usecases/users/users_use_case.dart';
import 'package:trainers_stopwatch/features/about_page/about_page.dart';
import 'package:trainers_stopwatch/features/stopwatch_page/stopwatch_page.dart';
import 'package:trainers_stopwatch/features/stopwatch_page/stopwatch_page_controller.dart';
import 'package:trainers_stopwatch/ui/pages/history/viewmodel/history_view_model.dart';
import 'package:trainers_stopwatch/ui/pages/settings/settings_page.dart';
import 'package:trainers_stopwatch/ui/pages/settings/viewmodel/settings_view_model.dart';
import 'package:trainers_stopwatch/ui/pages/trainings/trainings_page.dart';
import 'package:trainers_stopwatch/ui/pages/trainings/viewmodel/trainings_view_model.dart';
import 'package:trainers_stopwatch/ui/pages/users/users_page.dart';
import 'package:trainers_stopwatch/ui/pages/users/viewmodel/users_view_model.dart';

void main() {
  test('route names and paths are centralized and unique', () {
    final names = MainRoutes.values.map((route) => route.routeName).toSet();
    final paths = MainRoutes.values.map((route) => route.routePath).toSet();

    expect(names, hasLength(MainRoutes.values.length));
    expect(paths, hasLength(MainRoutes.values.length));
    expect(MainRoutes.stopwatch.routePath, '/stopwatch');
    expect(MainRoutes.history.routeName, 'History');
  });

  test('history navigation uses typed arguments', () {
    const user = User(id: 1, name: 'Ana', email: 'ana@example.com');
    final training = Training.create(
      id: 1,
      userId: 1,
      date: DateTime(2026),
    ).value!;
    final arguments = HistoryRouteArguments(user: user, training: training);

    expect(arguments.user, same(user));
    expect(arguments.training, same(training));
  });

  testWidgets('custom route transition keeps the reference timing',
      (tester) async {
    final page = AppCustomTransitionPage<void>(
      key: const ValueKey('route'),
      child: const SizedBox(),
    );

    expect(page.transitionDuration, const Duration(milliseconds: 400));
    expect(page.reverseTransitionDuration, const Duration(milliseconds: 300));
  });

  testWidgets('routes build Pages directly and recreate route ViewModels',
      (tester) async {
    setupDependencies();
    var settingsCreations = 0;
    var trainingsCreations = 0;
    final stopwatchController = StopwatchPageController()
      ..configure(
        stopwatchFactory: () => throw StateError('unused in this test'),
      );
    final dependencies = MainRouteDependencies(
      stopwatchController: stopwatchController,
      usersViewModelFactory: (activeUserIds) => UsersViewModel(
        useCase: injector.get<UsersUseCase>(),
        initiallySelectedUserIds: activeUserIds,
      ),
      trainingsViewModelFactory: () {
        trainingsCreations++;
        return TrainingsViewModel(
          userRepository: injector.get<UserRepository>(),
          trainingRepository: injector.get<TrainingRepository>(),
        );
      },
      historyViewModelFactory: (training) => HistoryViewModel(
        training: training,
        historyRepository: injector.get<HistoryRepository>(),
      ),
      appShare: injector.get<AppShare>(),
      settingsViewModelFactory: () {
        settingsCreations++;
        return injector.get<SettingsViewModel>();
      },
    );
    final router = GoRouter(
      initialLocation: MainRoutes.about.routePath,
      routes: mainRoutes(dependencies),
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    expect(find.byType(AboutPage), findsOneWidget);

    router.go(MainRoutes.settings.routePath);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(SettingsPage), findsOneWidget);
    expect(settingsCreations, 1);

    router.go(MainRoutes.about.routePath);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    router.go(MainRoutes.settings.routePath);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(settingsCreations, 2);

    router.go(MainRoutes.users.routePath);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(UsersPage), findsOneWidget);

    router.go(MainRoutes.trainings.routePath);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(TrainingsPage), findsOneWidget);
    expect(trainingsCreations, 1);

    router.go(MainRoutes.stopwatch.routePath);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(StopWatchPage), findsOneWidget);
  });
}
