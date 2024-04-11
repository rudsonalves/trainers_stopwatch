import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

import '../../models/athlete_model.dart';
import '../widgets/precise_stopwatch/precise_stopwatch.dart';

class StopwatchPageController {
  StopwatchPageController._();
  static final _instance = StopwatchPageController._();
  static StopwatchPageController get instance => _instance;
  final List<PreciseStopwatch> _stopwatch = [];
  final _stopwatchLength = signal<int>(0);

  final List<AthleteModel> _selectedAthletes = [];
  final List<AthleteModel> _newAthletes = [];

  List<AthleteModel> get selectedAthletes => _selectedAthletes;
  List<AthleteModel> get newAthletes => _newAthletes;
  List<PreciseStopwatch> get stopwatch => _stopwatch;
  Signal<int> get stopwatchLenght => _stopwatchLength;

  void addNewAthletes(List<AthleteModel> newSelectedAthletes) {
    for (final athlete in newSelectedAthletes) {
      if (!_hasAthlete(athlete.id!)) {
        _newAthletes.add(athlete);
      }
    }
  }

  void mergeAthleteLists() {
    if (_newAthletes.isNotEmpty) {
      _selectedAthletes.addAll(_newAthletes);
      _newAthletes.clear();
    }
  }

  bool _hasAthlete(int id) {
    int index = _selectedAthletes.indexWhere((athlete) => athlete.id == id);
    return index >= 0;
  }

  void addStopwatch() {
    for (final athlete in newAthletes) {
      _stopwatch.add(
        PreciseStopwatch(
          key: GlobalKey(),
          athlete: athlete,
        ),
      );
    }
    mergeAthleteLists();

    _stopwatchLength.value = _stopwatch.length;
  }

  void removeStopwatch(int index) {
    final id = _stopwatch[index].athlete.id!;

    _selectedAthletes.removeWhere((item) => item.id == id);
    _stopwatch.removeAt(index);

    _stopwatchLength.value = _stopwatch.length;
  }
}
