import '/common/adapters/training_domain_adapter.dart';
import '/common/models/training_model.dart';
import '/data/repositories/trainings/training_repository.dart';

// Temporary UI adapter. Remove in backlog 006.
final class TrainingManager {
  final TrainingRepository _repository;
  int? _userId;

  TrainingManager({required TrainingRepository repository})
      : _repository = repository;

  int get userId => _userId!;
  List<TrainingModel> get trainings => _userId == null
      ? const []
      : _repository
          .trainingsForUser(_userId!)
          .map((training) => training.toLegacy())
          .toList(growable: false);

  Future<void> init(int userId) async {
    _userId = userId;
    await getTrainings();
  }

  Future<void> getTrainings() async {
    final result = await _repository.loadForUser(userId);
    if (result.isFailure) throw result.error!;
  }

  Future<void> insert(TrainingModel training) async {
    training.userId = userId;
    final domain = training.toDomain();
    if (domain.isFailure) throw domain.error!;
    final result = await _repository.insert(domain.value!);
    if (result.isFailure) throw result.error!;
    training.id = result.value!.id;
  }

  Future<void> delete(TrainingModel training) async {
    final domain = training.toDomain();
    if (domain.isFailure) throw domain.error!;
    final result = await _repository.delete(domain.value!);
    if (result.isFailure) throw result.error!;
  }

  Future<void> update(TrainingModel training) async {
    final domain = training.toDomain();
    if (domain.isFailure) throw domain.error!;
    final result = await _repository.update(domain.value!);
    if (result.isFailure) throw result.error!;
  }

  int findIndex(int id) =>
      trainings.indexWhere((training) => training.id == id);
}
