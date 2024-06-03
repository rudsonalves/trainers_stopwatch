import '../../models/training_model.dart';
import '../../store/stores/training_store.dart';
import 'abstract_training_repository.dart';

class TrainingRepository implements AbstractTrainingRepository {
  final _store = TrainingStore();

  @override
  Future<int> insert(TrainingModel training) async {
    final id = await _store.insert(training.toMap());
    training.id = id;

    return id;
  }

  @override
  Future<TrainingModel?> query(int id) async {
    final map = await _store.query(id);
    if (map == null) return null;
    final training = TrainingModel.fromMap(map);
    return training;
  }

  @override
  Future<List<TrainingModel>> queryAllFromUser(int userId) async {
    final mapList = await _store.queryAllFromUser(userId);
    if (mapList.isEmpty) return [];
    final trainingList =
        mapList.map((map) => TrainingModel.fromMap(map!)).toList();
    return trainingList;
  }

  @override
  Future<int> delete(TrainingModel training) async {
    final result = await _store.delete(training.id!);
    return result;
  }

  @override
  Future<int> update(TrainingModel training) async {
    final result = await _store.update(training.id!, training.toMap());
    return result;
  }
}
