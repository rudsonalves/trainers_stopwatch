import '/common/adapters/history_domain_adapter.dart';
import '/common/models/history_model.dart';
import '/data/repositories/histories/history_repository.dart';

// Temporary session adapter. Replace with StopwatchSessionViewModel in backlog 008.
class HistoryManager {
  final HistoryRepository _repository;
  int? _trainingId;

  HistoryManager({required HistoryRepository repository})
      : _repository = repository;

  int get trainingId => _trainingId!;
  List<HistoryModel> get histories => _trainingId == null
      ? const []
      : _repository
          .historiesForTraining(_trainingId!)
          .map((entry) => entry.toLegacy())
          .toList(growable: false);

  void init(int trainingId) => _trainingId = trainingId;

  Future<void> getHistory() async {
    final result = await _repository.loadForTraining(trainingId);
    if (result.isFailure) throw result.error!;
  }

  Future<void> insert(HistoryModel history) async {
    history.trainingId = trainingId;
    final domain = history.toDomain();
    if (domain.isFailure) throw domain.error!;
    final result = await _repository.insert(domain.value!);
    if (result.isFailure) throw result.error!;
    history.id = result.value!.id;
  }

  Future<void> delete(int historyId) async {
    final result = await _repository.deleteAndMergeNext(
      trainingId: trainingId,
      historyEntryId: historyId,
    );
    if (result.isFailure) throw result.error!;
  }

  Future<void> update(HistoryModel history) async {
    final domain = history.toDomain();
    if (domain.isFailure) throw domain.error!;
    final result = await _repository.update(domain.value!);
    if (result.isFailure) throw result.error!;
  }

  int findIndex(int id) => histories.indexWhere((entry) => entry.id == id);
}
