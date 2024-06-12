import 'dart:developer';

import '../../common/abstract_classes/history_controller.dart';
import '../../common/models/history_model.dart';
import '../../common/models/training_model.dart';
import '../../common/models/user_model.dart';
import '../widgets/precise_stopwatch/precise_stopwatch.dart';

class PersonalTrainingController extends HistoryController {
  final PreciseStopwatch stopwatch;

  PersonalTrainingController(this.stopwatch);

  List<HistoryModel> get histories => stopwatch.controller.histories;

  @override
  void init({
    required UserModel user,
    required TrainingModel training,
    required List<HistoryModel> histories,
  }) async {
    super.init(user: user, training: training, histories: histories);

    stopwatch.controller.actionOnPress.addListener(getHistory);
  }

  @override
  Future<void> getHistory() async {
    changeState(StateLoading());
    await Future.delayed(const Duration(milliseconds: 50));
    changeState(StateSuccess());
  }

  @override
  Future<void> deleteHistory(HistoryModel history) async {
    try {
      changeState(StateLoading());
      await stopwatch.controller.deleteHistory(history);
      changeState(StateSuccess());
    } catch (err) {
      changeState(StateError());
      log('PersonalTrainingController.deleteHistory: $err');
    }
  }

  @override
  Future<void> updateHistory(HistoryModel history) async {
    try {
      changeState(StateLoading());
      await stopwatch.controller.updateHistory(history);
      changeState(StateSuccess());
    } catch (err) {
      changeState(StateError());
      log('PersonalTrainingController.updateHistory: $err');
    }
  }
}
