import 'package:go_router/go_router.dart';

import '/domain/common/training/models/training.dart';
import '/features/about_page/about_page.dart';
import '/features/stopwatch_page/stopwatch_page.dart';
import '/ui/pages/history/history_page.dart';
import '/ui/pages/history/viewmodel/history_view_model.dart';
import '/ui/pages/personal_training/personal_training_page.dart';
import '/ui/pages/settings/settings_page.dart';
import '/ui/pages/settings/viewmodel/settings_view_model.dart';
import '/ui/pages/stopwatch/stopwatch_page_view_model.dart';
import '/ui/pages/trainings/trainings_page.dart';
import '/ui/pages/trainings/viewmodel/trainings_view_model.dart';
import '/ui/pages/users/users_page.dart';
import '/ui/pages/users/viewmodel/users_view_model.dart';
import '../animations_page/app_custom_transition_page.dart';
import '../route_arguments.dart';
import '../routes.dart';

class MainRouteDependencies {
  final StopwatchPageViewModel stopwatchViewModel;
  final UsersViewModel Function(Iterable<int> activeUserIds)
      usersViewModelFactory;
  final TrainingsViewModel Function() trainingsViewModelFactory;
  final HistoryViewModel Function(Training training) historyViewModelFactory;
  final SettingsViewModel Function() settingsViewModelFactory;

  const MainRouteDependencies({
    required this.stopwatchViewModel,
    required this.usersViewModelFactory,
    required this.trainingsViewModelFactory,
    required this.historyViewModelFactory,
    required this.settingsViewModelFactory,
  });
}

List<RouteBase> mainRoutes(MainRouteDependencies dependencies) => [
      GoRoute(
        path: MainRoutes.stopwatch.routePath,
        name: MainRoutes.stopwatch.routeName,
        builder: (context, state) => StopWatchPage(
          viewModel: dependencies.stopwatchViewModel,
        ),
      ),
      GoRoute(
        path: MainRoutes.users.routePath,
        name: MainRoutes.users.routeName,
        pageBuilder: (context, state) => AppCustomTransitionPage(
          key: state.pageKey,
          child: UsersPage(
            viewModel: dependencies.usersViewModelFactory(
              dependencies.stopwatchViewModel.activeUserIds,
            ),
            stopwatchViewModel: dependencies.stopwatchViewModel,
          ),
        ),
      ),
      GoRoute(
        path: MainRoutes.trainings.routePath,
        name: MainRoutes.trainings.routeName,
        pageBuilder: (context, state) => AppCustomTransitionPage(
          key: state.pageKey,
          child: TrainingsPage(
            viewModel: dependencies.trainingsViewModelFactory(),
          ),
        ),
      ),
      GoRoute(
        path: MainRoutes.settings.routePath,
        name: MainRoutes.settings.routeName,
        pageBuilder: (context, state) => AppCustomTransitionPage(
          key: state.pageKey,
          child: SettingsPage(
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
            child: PersonalTrainingPage(
              session: arguments.session,
              viewModel: dependencies.historyViewModelFactory(
                arguments.session.training,
              ),
            ),
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
              viewModel: dependencies.historyViewModelFactory(
                arguments.training,
              ),
            ),
          );
        },
      ),
    ];
