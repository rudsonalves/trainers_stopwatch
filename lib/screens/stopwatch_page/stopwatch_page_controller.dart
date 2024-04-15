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
  final _historyMessage = signal<String>('');
  final List<AthleteModel> _athletesList = [];
  final List<PreciseStopwatchController> _stopwatchControllers = [];
  final List<AthleteModel> _newAthletes = [];

  List<AthleteModel> get athletesList => _athletesList;
  List<AthleteModel> get newAthletes => _newAthletes;
  List<PreciseStopwatch> get stopwatchList => _stopwatchList;
  List<PreciseStopwatchController> get stopwatchControllers =>
      _stopwatchControllers;
  Signal<int> get stopwatchLength => _stopwatchLength;
  Signal<String> get historyMessage => _historyMessage;

  void dispose() {
    _stopwatchLength.dispose();
    _historyMessage.dispose();
  }

  void addNewAthletes(List<AthleteModel> newSelectedAthletes) {
    for (final athlete in newSelectedAthletes) {
      if (!_hasAthlete(athlete.id!)) {
        _newAthletes.add(athlete);
      }
    }
  }

  void sendHistoryMessage(String message) {
    _historyMessage.value = message;
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

  void removeStopwatch(int athleteId) {
    _athletesList.removeWhere((item) => item.id == athleteId);
    _stopwatchList
        .removeWhere((stopwatch) => stopwatch.athlete.id == athleteId);

    _stopwatchLength.value = _stopwatchList.length;
  }
}
