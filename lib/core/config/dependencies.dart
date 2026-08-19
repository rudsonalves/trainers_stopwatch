import 'package:auto_injector/auto_injector.dart';

import '/features/stopwatch_page/stopwatch_page_controller.dart';
import '/features/widgets/precise_stopwatch/precise_stopwatch_controller.dart';
import 'dependencies/application_dependencies.dart';
import 'dependencies/repositories_dependencies.dart';
import 'dependencies/services_dependencies.dart';
import 'dependencies/usecases_dependencies.dart';
import 'dependencies/viewmodels_dependencies.dart';

final injector = AutoInjector();
bool _initialized = false;

void setupDependencies() {
  if (_initialized) return;

  registerServicesDependencies(injector);
  registerRepositoriesDependencies(injector);
  registerUseCasesDependencies(injector);
  registerViewModelsDependencies(injector);
  registerApplicationDependencies(injector);
  injector.commit();

  injector.get<StopwatchPageController>().configure(
        stopwatchFactory: () => injector.get<PreciseStopwatchController>(),
      );

  _initialized = true;
}
