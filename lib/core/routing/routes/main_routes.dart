import 'package:go_router/go_router.dart';

import '/common/functions/share_functions.dart';
import '/features/about_page/about_page.dart';
import '/features/history_page/history_page.dart';
import '/features/history_page/history_page_controller.dart';
import '/features/personal_training_page/personal_training_page.dart';
import '/features/stopwatch_page/stopwatch_overlay.dart';
import '/features/stopwatch_page/stopwatch_page_controller.dart';
import '/features/trainings_page/trainings_overlay.dart';
import '/features/trainings_page/trainings_page_controller.dart';
import '/ui/pages/settings/settings_overlay.dart';
import '/ui/pages/settings/viewmodel/settings_view_model.dart';
import '/ui/pages/users/users_overlay.dart';
import '/ui/pages/users/viewmodel/users_view_model.dart';
import '../animations_page/app_custom_transition_page.dart';
import '../route_arguments.dart';
import '../routes.dart';

final class MainRouteDependencies {
  final StopwatchPageController stopwatchController;
  final UsersViewModel Function(Iterable<int> activeUserIds)
      usersViewModelFactory;
  final TrainingsPageController Function() trainingsControllerFactory;
  final HistoryPageController Function() historyControllerFactory;
  final AppShare appShare;
  final SettingsViewModel Function() settingsViewModelFactory;

  const MainRouteDependencies({
    required this.stopwatchController,
    required this.usersViewModelFactory,
    required this.trainingsControllerFactory,
    required this.historyControllerFactory,
    required this.appShare,
    required this.settingsViewModelFactory,
  });
}

List<RouteBase> mainRoutes(MainRouteDependencies dependencies) => [
      GoRoute(
        path: MainRoutes.stopwatch.routePath,
        name: MainRoutes.stopwatch.routeName,
        builder: (context, state) => StopwatchOverlay(
          controller: dependencies.stopwatchController,
        ),
      ),
      GoRoute(
        path: MainRoutes.users.routePath,
        name: MainRoutes.users.routeName,
        pageBuilder: (context, state) => AppCustomTransitionPage(
          key: state.pageKey,
          child: UsersOverlay(
            viewModel: dependencies.usersViewModelFactory(
              dependencies.stopwatchController.usersList
                  .map((user) => user.id)
                  .nonNulls,
            ),
            stopwatchController: dependencies.stopwatchController,
          ),
        ),
      ),
      GoRoute(
        path: MainRoutes.trainings.routePath,
        name: MainRoutes.trainings.routeName,
        pageBuilder: (context, state) => AppCustomTransitionPage(
          key: state.pageKey,
          child: TrainingsOverlay(
            controller: dependencies.trainingsControllerFactory(),
            appShare: dependencies.appShare,
          ),
        ),
      ),
      GoRoute(
        path: MainRoutes.settings.routePath,
        name: MainRoutes.settings.routeName,
        pageBuilder: (context, state) => AppCustomTransitionPage(
          key: state.pageKey,
          child: SettingsOverlay(
            viewModel: dependencies.settingsViewModelFactory(),
          ),
        ),
      ),
      GoRoute(
        path: MainRoutes.about.routePath,
        name: MainRoutes.about.routeName,
        pageBuilder: (context, state) => AppCustomTransitionPage(
          key: state.pageKey,
          child: const AboutPage(),
        ),
      ),
      GoRoute(
        path: MainRoutes.personalTraining.routePath,
        name: MainRoutes.personalTraining.routeName,
        pageBuilder: (context, state) {
          final arguments = state.extra as PersonalTrainingRouteArguments;
          return AppCustomTransitionPage(
            key: state.pageKey,
            child: PersonalTrainingPage(stopwatch: arguments.stopwatch),
          );
        },
      ),
      GoRoute(
        path: MainRoutes.history.routePath,
        name: MainRoutes.history.routeName,
        pageBuilder: (context, state) {
          final arguments = state.extra as HistoryRouteArguments;
          return AppCustomTransitionPage(
            key: state.pageKey,
            child: HistoryPage(
              user: arguments.user,
              training: arguments.training,
              controller: dependencies.historyControllerFactory(),
            ),
          );
        },
      ),
    ];
