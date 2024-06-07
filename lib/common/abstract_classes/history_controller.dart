import 'package:flutter/foundation.dart';

import '../../models/history_model.dart';
import '../../models/training_model.dart';

abstract class HistoryState {}

class StateInitial extends HistoryState {}

class StateLoading extends HistoryState {}

class StateSuccess extends HistoryState {}

class StateError extends HistoryState {}

abstract class HistoryController extends ChangeNotifier {
  HistoryState _state = StateInitial();

  HistoryState get state => _state;

  void changeState(HistoryState newState) {
    _state = newState;
    notifyListeners();
  }

  void init(TrainingModel training);

  Future<void> getHistory();

  Future<void> updateHistory(HistoryModel history);

  Future<void> deleteHistory(HistoryModel history);
}
