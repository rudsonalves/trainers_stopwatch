import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';

import '../../common/abstract_classes/history_controller.dart';
import '../../common/functions/stopwatch_functions.dart';
import '../../manager/history_manager.dart';
import '../../common/models/history_model.dart';
import '../../common/models/training_model.dart';

class HistoryPageController extends HistoryController {
  final _historyManager = HistoryManager();
  late final TrainingModel training;

  List<HistoryModel> get histories => _historyManager.histories;

  void init(TrainingModel training) {
    this.training = training;
    _historyManager.init(training.id!);
    getHistory();
  }

  @override
  Future<void> updateHistory(HistoryModel history) async {
    await _historyManager.update(history);
  }

  @override
  Future<void> deleteHistory(HistoryModel history) async {
    await _historyManager.delete(history);
  }

  @override
  Future<void> getHistory() async {
    try {
      changeState(StateLoading());
      await _historyManager.getHistory();
      changeState(StateSuccess());
    } catch (err) {
      final message = 'HistoryPageController.getHistory: $err';
      log(message);
      changeState(StateError());
    }
  }

  String _cleanTime(double millsec) {
    final duration = Duration(milliseconds: (millsec * 1000).toInt());

    String time = duration.toString();
    while (time[0] == '0' || time[0] == ':') {
      time = time.substring(1);
    }
    return time.substring(0, time.length - 4);
  }

  String trainingStatistic() {
    double totalLength = 0;
    double totalTime = 0;

    for (final history in histories) {
      if (history.lap == null) {
        totalTime += history.duration.inMilliseconds / 1000;
        totalLength += training.splitLength;
      }
    }
    final speed = StopwatchFunctions.speedCalc(
      length: totalLength,
      time: totalTime,
      training: training,
    );

    return 'HPTrainingStat'.tr(args: [
      totalLength.toStringAsFixed(1),
      training.distanceUnit,
      _cleanTime(totalTime),
      speed,
    ]);
  }
}
