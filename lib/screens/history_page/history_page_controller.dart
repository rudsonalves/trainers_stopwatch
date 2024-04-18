import 'dart:developer';

import 'package:flutter/foundation.dart';

import '../../common/functions/stopwatch_functions.dart';
import '../../manager/history_manager.dart';
import '../../models/history_model.dart';
import '../../models/training_model.dart';
import 'history_page_state.dart';

class HistoryPageController extends ChangeNotifier {
  final _historyManager = HistoryManager();
  HistoryPageState _state = HistoryPageStateInitial();
  late final TrainingModel training;

  HistoryPageState get state => _state;
  List<HistoryModel> get histories => _historyManager.histories;

  void _changeState(HistoryPageState newState) {
    _state = newState;
    notifyListeners();
  }

  void init(TrainingModel training) {
    this.training = training;
    _historyManager.init(training.id!);
    getHistory();
  }

  Future<void> getHistory() async {
    try {
      _changeState(HistoryPageStateLoading());
      await _historyManager.getHistory();
      _changeState(HistoryPageStateSuccess());
    } catch (err) {
      final message = 'HistoryPageController.getHistory: $err';
      log(message);
      _changeState(HistoryPageStateError());
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

    return 'Length: ${totalLength.toStringAsFixed(1)} ${training.distanceUnit} '
        '- Time: ${_cleanTime(totalTime)}s\nAverage Speed $speed';
  }
}
