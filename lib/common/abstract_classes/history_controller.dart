// Copyright (C) 2024 Rudson Alves
// 
// This file is part of trainers_stopwatch.
// 
// trainers_stopwatch is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
// 
// trainers_stopwatch is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
// 
// You should have received a copy of the GNU General Public License
// along with trainers_stopwatch.  If not, see <https://www.gnu.org/licenses/>.

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
