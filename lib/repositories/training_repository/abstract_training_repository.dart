import '../../models/training_model.dart';

abstract class AbstractTrainingRepository {
  Future<int> insert(TrainingModel training);
  Future<TrainingModel?> query(int id);
  Future<List<TrainingModel>> queryAllFromUser(int userId);
  Future<int> delete(TrainingModel training);
  Future<int> update(TrainingModel training);
}
