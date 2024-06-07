import '../common/models/training_model.dart';
import '../repositories/training_repository/training_repository.dart';

class TrainingManager {
  TrainingManager();

  final _repository = TrainingRepository();
  late final int _userId;
  final List<TrainingModel> _trainings = [];
  bool _started = false;

  int get userId => _userId;
  List<TrainingModel> get trainings => _trainings;

  static Future<TrainingManager> byUserId(int id) async {
    final trainingManager = TrainingManager();
    await trainingManager.init(id);
    return trainingManager;
  }

  Future<void> init(int userId) async {
    if (_started) return;
    _started = true;
    _userId = userId;
    await getTrainings();
  }

  Future<void> getTrainings() async {
    _trainings.clear();
    final trainings = await _repository.queryAllFromUser(_userId);

    if (trainings.isNotEmpty) {
      _trainings.addAll(trainings);
    }
  }

  Future<void> insert(TrainingModel training) async {
    training.userId = _userId;
    final result = await _repository.insert(training);

    if (result > 0) {
      _trainings.add(training);
    } else {
      throw Exception('TrainingManager.insert: Error!');
    }
  }

  Future<void> delete(TrainingModel training) async {
    final result = await _repository.delete(training);

    if (result > 0) {
      final index = findIndex(training.id!);

      if (index < 0) {
        throw Exception('TrainingManager.delete: Error!');
      }
      _trainings.removeAt(index);
    } else {
      throw Exception('TrainingManager.delete: Error!');
    }
  }

  int findIndex(int id) {
    final index = _trainings.indexWhere((t) => t.id == id);
    return index;
  }

  Future<void> update(TrainingModel training) async {
    final result = await _repository.update(training);

    if (result != 1) {
      throw Exception('TrainingManager.update: Error!');
    }
    final index = findIndex(training.id!);
    if (index < 0) {
      throw Exception('TrainingManager.update: Error!');
    }
    _trainings[index] = training;
  }
}
