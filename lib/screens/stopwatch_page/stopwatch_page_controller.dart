import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

import '../../models/athlete_model.dart';
import '../widgets/precise_stopwatch/precise_stopwatch.dart';
import '../widgets/precise_stopwatch/precise_stopwatch_controller.dart';

class StopwatchPageController {
  StopwatchPageController._();
  static final _instance = StopwatchPageController._();
  static StopwatchPageController get instance => _instance;

  final List<PreciseStopwatch> _stopwatchList = [];
  final _stopwatchLength = signal<int>(0);
  final snackBarMessage = signal<String>('');
  final List<AthleteModel> _athletesList = [];
  final List<PreciseStopwatchController> _stopwatchControllers = [];
  final List<AthleteModel> _newAthletes = [];

  List<AthleteModel> get athletesList => _athletesList;
  List<AthleteModel> get newAthletes => _newAthletes;
  List<PreciseStopwatch> get stopwatchList => _stopwatchList;
  List<PreciseStopwatchController> get stopwatchControllers =>
      _stopwatchControllers;
  Signal<int> get stopwatchLenght => _stopwatchLength;

  void dispose() {
    _stopwatchLength.dispose();
    snackBarMessage.dispose();
  }

  void addNewAthletes(List<AthleteModel> newSelectedAthletes) {
    for (final athlete in newSelectedAthletes) {
      if (!_hasAthlete(athlete.id!)) {
        _newAthletes.add(athlete);
      }
    }
  }

  void sendSnackBarMessage(String message) {
    snackBarMessage.value = message;
  }

  void mergeAthleteLists() {
    if (_newAthletes.isNotEmpty) {
      _athletesList.addAll(_newAthletes);
      _newAthletes.clear();
    }
  }

  bool _hasAthlete(int id) {
    int index = _athletesList.indexWhere((athlete) => athlete.id == id);
    return index >= 0;
  }

  void addStopwatch() {
    for (final athlete in newAthletes) {
      final stopwatchController = PreciseStopwatchController();
      _stopwatchControllers.add(stopwatchController);
      _stopwatchList.add(
        PreciseStopwatch(
          key: GlobalKey(),
          athlete: athlete,
          controller: stopwatchController,
        ),
      );
    }
    mergeAthleteLists();

    _stopwatchLength.value = _stopwatchList.length;
  }

  void removeStopwatch(int index) {
    final id = _stopwatchList[index].athlete.id!;

    _athletesList.removeWhere((item) => item.id == id);
    _stopwatchList.removeAt(index);

    _stopwatchLength.value = _stopwatchList.length;
  }
}
