import 'dart:developer';

import 'package:flutter/foundation.dart';

import '../../manager/athlete_manager.dart';
import '../../models/athlete_model.dart';
import 'athletes_page_state.dart';

class AthletesPageController extends ChangeNotifier {
  final _manager = AthleteManager();
  AthletesPageState _state = AthletesPageStateInitial();
  bool _started = false;

  AthletesPageState get state => _state;
  bool get started => _started;
  List<AthleteModel> get athletes => _manager.athletes;

  void _changeState(AthletesPageState newState) {
    _state = newState;
    notifyListeners();
  }

  Future<void> init() async {
    if (started) return;
    _started = true;
    await _manager.init();
    getAllAthletes();
  }

  Future<void> getAllAthletes() async {
    try {
      _changeState(AthletesPageStateLoading());
      await _manager.getAllAthletes();
      _changeState(AthletesPageStateSuccess());
    } catch (err) {
      log('AthletesPageState.getAllAthletes: $err');
      _changeState(AthletesPageStateError());
    }
  }

  Future<void> addAthlete(AthleteModel athlete) async {
    try {
      _changeState(AthletesPageStateLoading());
      await _manager.insert(athlete);
      _changeState(AthletesPageStateSuccess());
    } catch (err) {
      log('AthletesPageState.getAllAthletes: $err');
      _changeState(AthletesPageStateError());
    }
  }
}
