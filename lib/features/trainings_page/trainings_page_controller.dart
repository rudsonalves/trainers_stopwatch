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

// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:developer';

import 'package:flutter/foundation.dart';

import '../../manager/user_manager.dart';
import '../../manager/training_manager.dart';
import '../../common/models/user_model.dart';
import '../../common/models/training_model.dart';
import 'trainings_page_state.dart';

class TrainingItem {
  int trainingId;
  bool selected;

  TrainingItem({
    required this.trainingId,
    required this.selected,
  });
}

class TrainingsPageController extends ChangeNotifier {
  TrainingsPageState _state = TrainingsPageStateInitial();

  final _usersManager = UserManager.instance;
  TrainingManager? _trainingsManager;
  UserModel? _user;
  final List<TrainingItem> selectedTraining = [];

  TrainingsPageState get state => _state;
  List<UserModel> get users => _usersManager.users;
  List<TrainingModel> get trainings => _trainingsManager?.trainings ?? [];
  int? get userId => _user?.id;
  UserModel? get user => _user;
  bool get haveTrainingSelected {
    if (selectedTraining.isEmpty) return false;

    final items = selectedTraining.where((item) => item.selected).toList();

    return items.isNotEmpty;
  }

  void _changeState(TrainingsPageState newState) {
    _state = newState;
    notifyListeners();
  }

  void init() {
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      _changeState(TrainingsPageStateLoading());
      await _usersManager.init();
      _changeState(TrainingsPageStateSuccess());
    } catch (err) {
      _changeState(TrainingsPageStateError());
    }
  }

  Future<void> selectUser(int? id) async {
    if (id == null) return;
    try {
      _changeState(TrainingsPageStateLoading());
      await _selectUser(id);
      _changeState(TrainingsPageStateSuccess());
    } catch (err) {
      log('TrainingsPageController.selectUser: $err');
      _changeState(TrainingsPageStateError());
    }
  }

  Future<void> removeTraining(TrainingModel training) async {
    try {
      _changeState(TrainingsPageStateLoading());
      _removeFromSelection(training);
      await _trainingsManager!.delete(training);
      _changeState(TrainingsPageStateSuccess());
    } catch (err) {
      log('TrainingsPageController.removeTraining: $err');
      _changeState(TrainingsPageStateError());
    }
  }

  void _removeFromSelection(TrainingModel training) {
    selectedTraining.removeWhere((item) => item.trainingId == training.id);
  }

  Future<void> _selectUser(int id) async {
    _user = users.firstWhere((user) => user.id == id);
    if (_user == null) {
      throw Exception('User id $id not found!');
    }
    _trainingsManager = await TrainingManager.byUserId(id);
    _updateSelectedList();
  }

  void _updateSelectedList() {
    selectedTraining.clear();
    for (final training in trainings) {
      selectedTraining.add(
        TrainingItem(
          trainingId: training.id!,
          selected: false,
        ),
      );
    }
  }

  bool areAllSelecting() {
    if (selectedTraining.isEmpty) return false;
    return !selectedTraining.any((item) => !item.selected);
  }

  Future<void> updateTraining(TrainingModel training) async {
    try {
      _changeState(TrainingsPageStateLoading());
      await _trainingsManager!.update(training);
      _changeState(TrainingsPageStateSuccess());
    } catch (err) {
      log('TrainingsPageController.updateTraining: $err');
      _changeState(TrainingsPageStateError());
    }
  }

  void selectTraining(int id) {
    try {
      _changeState(TrainingsPageStateLoading());
      int index = selectedTraining.indexWhere((item) => item.trainingId == id);
      selectedTraining[index].selected = !selectedTraining[index].selected;
      _changeState(TrainingsPageStateSuccess());
    } catch (err) {
      log('TrainingsPageController.selectTraining: $err');
      _changeState(TrainingsPageStateError());
    }
  }

  void selectAllTraining() {
    try {
      _changeState(TrainingsPageStateLoading());
      for (final item in selectedTraining) {
        item.selected = true;
      }
      _changeState(TrainingsPageStateSuccess());
    } catch (err) {
      log('TrainingsPageController.selectTraining: $err');
      _changeState(TrainingsPageStateError());
    }
  }

  void deselectAllTraining() {
    try {
      _changeState(TrainingsPageStateLoading());
      for (final item in selectedTraining) {
        item.selected = false;
      }
      _changeState(TrainingsPageStateSuccess());
    } catch (err) {
      log('TrainingsPageController.selectTraining: $err');
      _changeState(TrainingsPageStateError());
    }
  }

  Future<void> removeSelected() async {
    try {
      _changeState(TrainingsPageStateLoading());
      final selected = selectedTraining.where((item) => item.selected);

      for (final item in selected) {
        if (item.selected) {
          final training =
              trainings.firstWhere((t) => t.id! == item.trainingId);
          await _trainingsManager!.delete(training);
        }
      }
      _updateSelectedList();
      _changeState(TrainingsPageStateSuccess());
    } catch (err) {
      log('TrainingsPageController.removeSelecteds: $err');
      _changeState(TrainingsPageStateError());
    }
  }
}
