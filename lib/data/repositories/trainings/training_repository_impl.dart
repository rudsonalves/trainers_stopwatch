import '/core/result/result.dart';
import '/data/services/trainings/training_service.dart';
import '/domain/common/training/models/training.dart';
import 'training_repository.dart';

class TrainingRepositoryImpl implements TrainingRepository {
  final TrainingService _service;
  final Map<int, List<Training>> _cache = {};

  TrainingRepositoryImpl({required TrainingService service})
      : _service = service;

  @override
  List<Training> trainingsForUser(int userId) => _cache[userId] ?? const [];

  @override
  AsyncResult<List<Training>> loadForUser(int userId) async {
    final result = await _service.readAllFromUser(userId);
    if (result.isFailure) return Failure(result.error!);
    final snapshot = List<Training>.unmodifiable(result.value!);
    _cache[userId] = snapshot;
    return Success(snapshot);
  }

  @override
  AsyncResult<Training> insert(Training training) async {
    final result = await _service.insert(training);
    if (result.isFailure) return Failure(result.error!);
    _cache[training.userId] = List.unmodifiable([
      ...trainingsForUser(training.userId),
      result.value!,
    ]);
    return result;
  }

  @override
  AsyncResult<Unit> update(Training training) async {
    final id = training.id;
    if (id == null) return Failure(_missingId('update'));
    final result = await _service.update(training);
    if (result.isFailure) return Failure(result.error!);
    _cache[training.userId] = List.unmodifiable(
      trainingsForUser(
        training.userId,
      ).map((cached) => cached.id == id ? training : cached),
    );
    return const Success(unit);
  }

  @override
  AsyncResult<Unit> delete(Training training) async {
    final id = training.id;
    if (id == null) return Failure(_missingId('delete'));
    final result = await _service.delete(id);
    if (result.isFailure) return Failure(result.error!);
    _cache[training.userId] = List.unmodifiable(
      trainingsForUser(training.userId).where((cached) => cached.id != id),
    );
    return const Success(unit);
  }

  AppError _missingId(String operation) => AppError(
        code: AppErrorCode.invalidData,
        message: 'A persisted training id is required to $operation the cache.',
      );
}
