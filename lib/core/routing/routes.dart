abstract interface class AppRoute {
  String get routePath;
  String get routeName;
}

enum MainRoutes implements AppRoute {
  stopwatch('/stopwatch', 'Stopwatch'),
  users('/users', 'Users'),
  trainings('/trainings', 'Trainings'),
  settings('/settings', 'Settings'),
  about('/about', 'About'),
  personalTraining('/training', 'PersonalTraining'),
  history('/history', 'History');

  const MainRoutes(this.routePath, this.routeName);

  @override
  final String routePath;

  @override
  final String routeName;
}
