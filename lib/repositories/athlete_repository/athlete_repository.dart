import '../../models/athlete_model.dart';
import '../../store/athlete_store.dart';
import 'abstract_athlete_repository.dart';

class AthleteRepository implements AbstractAthleteRepository {
  final _store = AthleteStore();

  @override
  Future<int> insert(AthleteModel athlete) async {
    final id = await _store.insert(athlete.toMap());
    athlete.id = id;

    return id;
  }

  @override
  Future<AthleteModel?> query(int id) async {
    final map = await _store.query(id);
    if (map == null) return null;
    final athlete = AthleteModel.fromMap(map);
    return athlete;
  }

  @override
  Future<List<AthleteModel>> queryAll() async {
    final mapList = await _store.queryAll();
    if (mapList.isEmpty) return [];
    final athleteList =
        mapList.map((map) => AthleteModel.fromMap(map!)).toList();
    return athleteList;
  }

  @override
  Future<int> delete(AthleteModel athlete) async {
    final result = await _store.delete(athlete.id!);
    return result;
  }

  @override
  Future<int> update(AthleteModel athlete) async {
    final result = await _store.update(athlete.id!, athlete.toMap());
    return result;
  }
}
