import '../models/training_model.dart';
import '../repositories/training_repository/training_repository.dart';

class TrainingManager {
  final _repository = TrainingRepository();
  late final int _athleteId;
  final List<TrainingModel> _trainings = [];

  int get athleteId => _athleteId;
  List<TrainingModel> get trainings => _trainings;

  Future<void> init(int athleteId) async {
    _athleteId = athleteId;
    await getTrainings();
  }

  Future<void> getTrainings() async {
    _trainings.clear();
    final trainings = await _repository.queryAllFromAthlete(_athleteId);

    if (trainings.isNotEmpty) {
      _trainings.addAll(trainings);
    }
  }

  Future<void> insert(TrainingModel training) async {
    training.athleteId = _athleteId;
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

      if (index < 1) {
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
