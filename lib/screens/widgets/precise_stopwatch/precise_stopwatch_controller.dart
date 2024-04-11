import 'package:signals/signals_flutter.dart';
import 'package:trainers_stopwatch/models/history_model.dart';

import '../../../bloc/stopwatch_bloc.dart';
import '../../../bloc/stopwatch_events.dart';
import '../../../bloc/stopwatch_state.dart';
import '../../../manager/history_manager.dart';
import '../../../manager/training_manager.dart';
import '../../../models/athlete_model.dart';
import '../../../models/training_model.dart';

class PreciseStopwatchController {
  final _bloc = StopwatchBloc();
  final _trainingManager = TrainingManager();
  final _historyManager = HistoryManager();
  late final AthleteModel _athlete;
  late TrainingModel _training;
  final _message = signal<String>('');
  int _lastLapMS = 0;
  int _lastSplitMS = 0;

  bool _trainingStarted = false;

  StopwatchBloc get bloc => _bloc;
  StopwatchState get state => _bloc.state;
  Signal<int> get counter => _bloc.counter;
  Signal<Duration> get durationTraining => _bloc.durationTraining;
  AthleteModel get athlete => _athlete;
  List<TrainingModel> get trainings => _trainingManager.trainings;
  List<HistoryModel> get histories => _historyManager.histories;
  Signal<String> get message => _message;
  TrainingModel get training => _training;

  Future<void> init(AthleteModel athlete) async {
    _athlete = athlete;
    _trainingManager.init(_athlete.id!);
    _createNewTraining();
  }

  void dispose() {
    _bloc.dispose();
  }

  Future<void> _createNewTraining() async {
    _training = TrainingModel(
      athleteId: _athlete.id!,
      date: DateTime.now(),
    );

    await _trainingManager.insert(_training);
    _historyManager.setTrainingId(_training.id!);
    _trainingStarted = true;
  }

  Future<void> blocStartTimer() async {
    _bloc.add(StopwatchEventRun());

    if (!_trainingStarted) {
      await _createNewTraining();
    }
  }

  void blocPauseTimer() {
    _bloc.add(StopwatchEventPause());
  }

  void blocResetTimer() {
    _bloc.add(StopwatchEventReset());
    _message.value = '';
  }

  Future<void> blocNextLap() async {
    if (_bloc.state is! StopwatchStateRunning) return;
    _bloc.add(StopwatchEventLap());

    if (!_trainingStarted) return;

    await Future.delayed(const Duration(milliseconds: 50));

    int lapMs;
    double speed;
    (lapMs, speed) = _calculateLapTimeSpeed();

    HistoryModel history = HistoryModel(
      trainingId: _training.id!,
      duration: Duration(milliseconds: lapMs),
      lap: counter(),
    );

    _createMassage(history.duration, speed, history.lap);
    await _historyManager.insert(history);
  }

  Future<void> blocSplitTimer() async {
    if (_bloc.state is! StopwatchStateRunning) return;
    _bloc.add(StopwatchEventSplit());

    if (!_trainingStarted) return;

    await Future.delayed(const Duration(milliseconds: 50));

    int splitMs;
    double speed;
    (splitMs, speed) = _calculateSplitTimeSpeed();

    HistoryModel history = HistoryModel(
      trainingId: _training.id!,
      duration: Duration(milliseconds: splitMs),
    );

    _createMassage(history.duration, speed);

    await _historyManager.insert(history);
  }

  Future<void> blocStopTimer() async {
    _bloc.add(StopwatchEventStop());
    _trainingStarted = false;

    await Future.delayed(const Duration(milliseconds: 50));

    int lapMs;
    double speed;
    (lapMs, speed) = _calculateLapTimeSpeed();

    HistoryModel historyLap = HistoryModel(
      trainingId: _training.id!,
      duration: Duration(milliseconds: lapMs),
      lap: counter(),
    );

    _createMassage(historyLap.duration, speed, historyLap.lap);

    await Future.delayed(const Duration(milliseconds: 1500));

    int splitMs;
    (splitMs, speed) = _calculateSplitTimeSpeed();

    HistoryModel historySpli = HistoryModel(
      trainingId: _training.id!,
      duration: Duration(milliseconds: splitMs),
    );

    _createMassage(historySpli.duration, speed);

    await _historyManager.insert(historyLap);
    await _historyManager.insert(historySpli);
  }

  String formatMs(Duration duration) {
    final durationStr = duration.toString();
    final point = durationStr.indexOf('.');
    return durationStr.substring(0, point + 4);
  }

  String formatCs(Duration duration) {
    final durationStr = duration.toString();
    final point = durationStr.indexOf('.');
    return durationStr.substring(0, point + 3);
  }

  void _createMassage(
    Duration time,
    double speed, [
    int? lap,
  ]) {
    if (lap != null) {
      _message.value = speed != 0
          ? 'Lap [$lap]: ${formatMs(time)}'
              ' speed: ${speed.toStringAsFixed(2)} m/s'
          : 'Lap [$lap]: ${formatMs(time)}';
    } else {
      _message.value = speed != 0
          ? 'Split: ${formatMs(time)}'
              ' speed: ${speed.toStringAsFixed(2)} m/s'
          : 'Split: ${formatMs(time)}';
    }
  }

  (int, double) _calculateLapTimeSpeed() {
    final lapMS = durationTraining().inMilliseconds - _lastLapMS;
    _lastLapMS = durationTraining().inMilliseconds;

    final speed = 1000 * (_training.lapLength ?? 0) / lapMS;
    return (lapMS, speed);
  }

  (int, double) _calculateSplitTimeSpeed() {
    final splitMS = durationTraining().inMilliseconds - _lastSplitMS;
    _lastSplitMS = durationTraining().inMilliseconds;

    final speed = 1000 * (_training.splitLength ?? 0) / splitMS;
    return (splitMS, speed);
  }
}
