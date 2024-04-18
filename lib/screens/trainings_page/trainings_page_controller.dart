// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:developer';

import 'package:flutter/foundation.dart';

import '../../manager/athlete_manager.dart';
import '../../manager/training_manager.dart';
import '../../models/athlete_model.dart';
import '../../models/training_model.dart';
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

  final _athletesManager = AthleteManager.instance;
  TrainingManager? _trainingsManager;
  AthleteModel? _athlete;
  final List<TrainingItem> selectedTraining = [];

  TrainingsPageState get state => _state;
  List<AthleteModel> get athletes => _athletesManager.athletes;
  List<TrainingModel> get trainings => _trainingsManager?.trainings ?? [];
  int? get athleteId => _athlete?.id;
  AthleteModel? get athlete => _athlete;

  void _changeState(TrainingsPageState newState) {
    _state = newState;
    notifyListeners();
  }

  void init() {
    _loadAthletes();
  }

  Future<void> _loadAthletes() async {
    try {
      _changeState(TrainingsPageStateLoading());
      await _athletesManager.init();
      _changeState(TrainingsPageStateSuccess());
    } catch (err) {
      _changeState(TrainingsPageStateError());
    }
  }

  Future<void> selectAthlete(int? id) async {
    if (id == null) return;
    try {
      _changeState(TrainingsPageStateLoading());
      await _selectAthlete(id);
      _changeState(TrainingsPageStateSuccess());
    } catch (err) {
      log('TrainingsPageController.selectAthlete: $err');
      _changeState(TrainingsPageStateError());
    }
  }

  Future<void> removeTraining(TrainingModel training) async {
    try {
      _changeState(TrainingsPageStateLoading());
      await _trainingsManager!.delete(training);
      _changeState(TrainingsPageStateSuccess());
    } catch (err) {
      log('TrainingsPageController.removeTraining: $err');
      _changeState(TrainingsPageStateError());
    }
  }

  Future<void> _selectAthlete(int id) async {
    _athlete = athletes.firstWhere((athlete) => athlete.id == id);
    if (_athlete == null) {
      throw Exception('Athlete id $id not found!');
    }
    _trainingsManager = await TrainingManager.byAthleteId(id);
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
