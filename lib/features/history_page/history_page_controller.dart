import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';

import '../../common/abstract_classes/history_controller.dart';
import '../../common/functions/stopwatch_functions.dart';
import '../../common/models/user_model.dart';
import '../../manager/history_manager.dart';
import '../../common/models/history_model.dart';
import '../../common/models/training_model.dart';

class HistoryPageController extends HistoryController {
  final _historyManager = HistoryManager();

  List<HistoryModel> get histories => _historyManager.histories;

  @override
  void init({
    required UserModel user,
    required TrainingModel training,
    required List<HistoryModel> histories,
  }) {
    super.init(
      user: user,
      training: training,
      histories: _historyManager.histories,
    );
    _historyManager.init(training.id!);
    getHistory();
  }

  @override
  Future<bool> updateHistory(int historyId) async {
    try {
      changeState(StateLoading());
      await _historyManager.update(historyId);
      trainingReport.createMessages();
      changeState(StateSuccess());
      return true;
    } catch (err) {
      final message = 'HistoryPageController.updateHistory: $err';
      log(message);
      changeState(StateError());
      return false;
    }
  }

  @override
  Future<bool> deleteHistory(int historyId) async {
    try {
      changeState(StateLoading());
      await _historyManager.delete(historyId);
      trainingReport.createMessages();
      changeState(StateSuccess());
      return true;
    } catch (err) {
      final message = 'HistoryPageController.deleteHistory: $err';
      log(message);
      changeState(StateError());
      return false;
    }
  }

  @override
  Future<void> getHistory() async {
    try {
      changeState(StateLoading());
      await _historyManager.getHistory();
      trainingReport.createMessages();
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

    final speed = StopwatchFunctions.speedCalc(
      length: totalLength,
      time: totalTime,
      training: training,
    );

    return 'HPTrainingStat'.tr(args: [
      totalLength.toStringAsFixed(1),
      training.distanceUnit,
      _cleanTime(totalTime),
      speed.toString(),
    ]);
  }
}
