import '/core/result/result.dart';
import '/domain/common/training/models/training.dart';

abstract interface class TrainingRepository {
  List<Training> trainingsForUser(int userId);

  AsyncResult<List<Training>> loadForUser(int userId);
  AsyncResult<Training> insert(Training training);
  AsyncResult<Unit> update(Training training);
  AsyncResult<Unit> delete(Training training);
}
