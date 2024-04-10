import '../../models/athlete_model.dart';

abstract class AbstractAthleteRepository {
  Future<int> insert(AthleteModel athlete);
  Future<AthleteModel?> query(int id);
  Future<List<AthleteModel>> queryAll();
  Future<int> delete(AthleteModel athlete);
  Future<int> update(AthleteModel athlete);
}
