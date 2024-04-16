import 'dart:developer';

import 'package:flutter/foundation.dart';

import '../../manager/athlete_manager.dart';
import '../../manager/training_manager.dart';
import '../../models/athlete_model.dart';
import '../../models/training_model.dart';
import 'trainings_page_state.dart';

class TrainingsPageController extends ChangeNotifier {
  TrainingsPageState _state = TrainingsPageStateInitial();

  final _athletesManager = AthleteManager.instance;
  TrainingManager? _trainingsManager;

  AthleteModel? _athlete;

  TrainingsPageState get state => _state;
  List<AthleteModel> get athletes => _athletesManager.athletes;
  List<TrainingModel> get trainings => _trainingsManager?.trainings ?? [];
  int? get athleteId => _athlete?.id;

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
  }
}
