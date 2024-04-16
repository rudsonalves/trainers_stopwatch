import 'dart:async';

import '../models/athlete_model.dart';
import '../repositories/athlete_repository/athlete_repository.dart';

class AthleteManager {
  AthleteManager._();
  static final AthleteManager _instance = AthleteManager._();
  static AthleteManager get instance => _instance;
  bool _started = false;

  final _repository = AthleteRepository();
  final List<AthleteModel> _athletes = [];

  List<AthleteModel> get athletes => _athletes;

  Future<void> init() async {
    if (!_started) {
      await getAllAthletes();
      _started = true;
    }
  }

  Future<void> insert(AthleteModel athlete) async {
    if (athlete.id != null) {
      throw Exception('Sorry, There is a logical error.');
    }
    await _repository.insert(athlete);
    await getAllAthletes();
  }

  Future<void> getAllAthletes() async {
    athletes.clear();
    final newsAthletes = await _repository.queryAll();
    athletes.addAll(newsAthletes);
  }

  Future<void> update(AthleteModel athlete) async {
    int index = findIndex(athlete.id!);
    if (index < 0) {
      throw Exception(
        'AthleteManager.update: Error!',
      );
    }
    _repository.update(athlete);
    _athletes[index] = athlete;
  }

  Future<void> delete(AthleteModel athlete) async {
    int index = findIndex(athlete.id!);
    if (index < 0) {
      throw Exception(
        'AthleteManager.delete: Error!',
      );
    }
    await _repository.delete(athlete);
    _athletes.removeAt(index);
  }

  int findIndex(int id) {
    int findIndex = _athletes.indexWhere((athlete) => athlete.id == id);
    return findIndex;
  }
}
