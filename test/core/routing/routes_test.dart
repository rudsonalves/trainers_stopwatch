import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trainers_stopwatch/common/models/training_model.dart';
import 'package:trainers_stopwatch/common/models/user_model.dart';
import 'package:trainers_stopwatch/core/routing/animations_page/app_custom_transition_page.dart';
import 'package:trainers_stopwatch/core/routing/route_arguments.dart';
import 'package:trainers_stopwatch/core/routing/routes.dart';

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
    final user = UserModel(name: 'Ana', email: 'ana@example.com');
    final training = TrainingModel(userId: 1, date: DateTime(2026));
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
}
