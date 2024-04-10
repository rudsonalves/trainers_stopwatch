import '../../models/athlete_model.dart';

class StopwatchPageController {
  StopwatchPageController._();
  static final _instance = StopwatchPageController._();
  static StopwatchPageController get instance => _instance;

  final List<AthleteModel> _selectedAthletes = [];
  final List<AthleteModel> _newAthletes = [];

  List<AthleteModel> get selectedAthletes => _selectedAthletes;
  List<AthleteModel> get newAthletes => _newAthletes;

  void addNewAthletes(List<AthleteModel> newsAthletes) {
    for (final athlete in newsAthletes) {
      if (!hasAthlete(athlete)) {
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

  bool hasAthlete(AthleteModel athlete) {
    int index = _selectedAthletes.indexWhere((item) => item.id == athlete.id);
    return index >= 0;
  }
}
