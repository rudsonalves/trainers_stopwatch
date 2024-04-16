import 'dart:developer';

import 'package:flutter/foundation.dart';

import '../../manager/athlete_manager.dart';
import '../../models/athlete_model.dart';
import 'athletes_page_state.dart';

class AthletesPageController extends ChangeNotifier {
  final _athletesManager = AthleteManager.instance;
  AthletesPageState _state = AthletesPageStateInitial();

  AthletesPageState get state => _state;
  List<AthleteModel> get athletes => _athletesManager.athletes;

  void _changeState(AthletesPageState newState) {
    _state = newState;
    notifyListeners();
  }

  Future<void> init() async {
    await _athletesManager.init();
    getAllAthletes();
  }

  Future<void> getAllAthletes() async {
    try {
      _changeState(AthletesPageStateLoading());
      await _athletesManager.getAllAthletes();
      _changeState(AthletesPageStateSuccess());
    } catch (err) {
      log('AthletesPageState.getAllAthletes: $err');
      _changeState(AthletesPageStateError());
    }
  }

  Future<void> addAthlete(AthleteModel athlete) async {
    try {
      _changeState(AthletesPageStateLoading());
      await _athletesManager.insert(athlete);
      _changeState(AthletesPageStateSuccess());
    } catch (err) {
      log('AthletesPageState.addAthlete: $err');
      _changeState(AthletesPageStateError());
    }
  }

  Future<void> updateAthlete(AthleteModel athlete) async {
    try {
      _changeState(AthletesPageStateLoading());
      await _athletesManager.update(athlete);
      _changeState(AthletesPageStateSuccess());
    } catch (err) {
      log('AthletesPageState.updateAthlete: $err');
      _changeState(AthletesPageStateError());
    }
  }

  Future<void> deleteAthlete(AthleteModel athlete) async {
    try {
      _changeState(AthletesPageStateLoading());
      await _athletesManager.delete(athlete);
      _changeState(AthletesPageStateSuccess());
    } catch (err) {
      log('AthletesPageState.updateAthlete: $err');
      _changeState(AthletesPageStateError());
    }
  }
}
