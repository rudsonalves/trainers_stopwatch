import '../../models/history_model.dart';
import '../../store/history_store.dart';
import 'abstract_history_repository.dart';

class HistoryRepository implements AbstractHistoryRepository {
  final _store = HistoryStore();

  @override
  Future<int> insert(HistoryModel history) async {
    final id = await _store.insert(history.toMap());
    history.id = id;

    return id;
  }

  @override
  Future<HistoryModel?> query(int id) async {
    final map = await _store.query(id);
    if (map == null) return null;
    final history = HistoryModel.fromMap(map);
    return history;
  }

  @override
  Future<List<HistoryModel>> queryAllFromTraining(int trainingId) async {
    final mapList = await _store.queryAllFromTraining(trainingId);
    if (mapList.isEmpty) return [];
    final historyList =
        mapList.map((map) => HistoryModel.fromMap(map!)).toList();
    return historyList;
  }

  @override
  Future<int> delete(HistoryModel history) async {
    final result = await _store.delete(history.id!);
    return result;
  }

  @override
  Future<int> update(HistoryModel history) async {
    final result = await _store.update(history.id!, history.toMap());
    return result;
  }
}
