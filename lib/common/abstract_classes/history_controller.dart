import 'package:flutter/foundation.dart';

import '../functions/training_report.dart';
import '../models/history_model.dart';
import '../models/messages_model.dart';
import '../models/training_model.dart';
import '../models/user_model.dart';

abstract class HistoryState {}

class StateInitial extends HistoryState {}

class StateLoading extends HistoryState {}

class StateSuccess extends HistoryState {}

class StateError extends HistoryState {}

abstract class HistoryController extends ChangeNotifier {
  late final TrainingReport trainingReport;
  HistoryState _state = StateInitial();

  HistoryState get state => _state;
  List<MessagesModel> get messages => trainingReport.messages;

  late final UserModel user;
  late final TrainingModel training;

  void changeState(HistoryState newState) {
    _state = newState;
    notifyListeners();
  }

  void init({
    required UserModel user,
    required TrainingModel training,
    required List<HistoryModel> histories,
  }) {
    this.user = user;
    this.training = training;
    trainingReport = TrainingReport(
      user: user,
      training: training,
      histories: histories,
    );
  }

  Future<void> getHistory();

  Future<bool> updateHistory(HistoryModel history);

  Future<bool> deleteHistory(int historyId);
}
