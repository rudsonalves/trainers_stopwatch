import 'package:auto_injector/auto_injector.dart';

import '/common/adapters/legacy_settings_sink.dart';
import '/common/functions/share_functions.dart';
import '/common/singletons/app_settings.dart';
import '/core/bootstrap/bootstrap.dart';
import '/data/services/database/database_provider.dart';
import '/features/stopwatch_page/stopwatch_page_controller.dart';
import '/features/widgets/precise_stopwatch/precise_stopwatch_controller.dart';
import '/manager/history_manager.dart';
import '/manager/training_manager.dart';

void registerApplicationDependencies(AutoInjector injector) {
  injector
    ..addInstance<AppSettings>(AppSettings.instance)
    ..addInstance<LegacySettingsSink>(AppSettings.instance)
    ..addSingleton<AppShare>(AppShare.new)
    ..add<TrainingManager>(TrainingManager.new)
    ..add<HistoryManager>(HistoryManager.new)
    ..addSingleton<StopwatchPageController>(StopwatchPageController.new)
    ..add<PreciseStopwatchController>(PreciseStopwatchController.new)
    ..add<DatabaseProvider>(DatabaseProvider.new)
    ..add<Bootstrap>(Bootstrap.new);
}
