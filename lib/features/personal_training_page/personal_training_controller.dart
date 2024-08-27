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
    super.init(
      user: user,
      training: training,
      histories: histories,
    );

    stopwatch.controller.actionOnPress.addListener(getHistory);
  }

  @override
  Future<void> getHistory() async {
    try {
      changeState(StateLoading());
      await Future.delayed(const Duration(milliseconds: 50));
      trainingReport.createMessages();
      changeState(StateSuccess());
    } catch (err) {
      final message = 'PersonalTrainingController.getHistory: $err';
      log(message);
      changeState(StateError());
    }
  }

  @override
  Future<bool> deleteHistory(int historyId) async {
    try {
      changeState(StateLoading());
      await stopwatch.controller.deleteHistory(historyId);
      trainingReport.createMessages();
      changeState(StateSuccess());
      return true;
    } catch (err) {
      changeState(StateError());
      log('PersonalTrainingController.deleteHistory: $err');
      return false;
    }
  }

  @override
  Future<bool> updateHistory(HistoryModel history) async {
    try {
      changeState(StateLoading());
      await stopwatch.controller.updateHistory(history);
      trainingReport.createMessages();
      changeState(StateSuccess());
      return true;
    } catch (err) {
      changeState(StateError());
      log('PersonalTrainingController.updateHistory: $err');
      return false;
    }
  }
}
