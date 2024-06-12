import '../common/models/history_model.dart';
import '../repositories/history_repository/history_repository.dart';

class HistoryManager {
  final _repository = HistoryRepository();
  late int _trainingId;
  final List<HistoryModel> _histories = [];

  int get trainingId => _trainingId;
  List<HistoryModel> get histories => _histories;

  Future<void> init(int trainingId) async {
    _trainingId = trainingId;
  }

  static Future<HistoryManager> newInstance(int trainingId) async {
    final manager = HistoryManager();
    manager.init(trainingId);
    await manager.getHistory();
    return manager;
  }

  Future<void> getHistory() async {
    _histories.clear();
    final histories = await _repository.queryAllFromTraining(trainingId);
    if (histories.isNotEmpty) {
      _histories.addAll(histories);
    }
  }

  Future<void> insert(HistoryModel history) async {
    history.trainingId = _trainingId;
    final result = await _repository.insert(history);

    if (result > 0) {
      _histories.add(history);
    } else {
      throw Exception('HistoryManager.insert: Error!');
    }
  }

  Future<void> delete(HistoryModel history) async {
    final result = await _repository.delete(history);
    if (result > 0) {
      int index = findIndex(history.id!);
      if (index < 1) {
        throw Exception('HistoryManager.delete: Error!');
      }

      _histories.removeAt(index);
    } else {
      throw Exception('HistoryManager.delete: Error!');
    }
  }

  int findIndex(int id) {
    final index = _histories.indexWhere((h) => h.id == id);
    return index;
  }

  Future<void> update(HistoryModel history) async {
    final result = await _repository.update(history);
    if (result > 0) {
      int index = findIndex(history.id!);
      if (index < 0) {
        throw Exception('HistoryManager.update: Error!');
      }

      _histories[index] = history;
    } else {
      throw Exception('HistoryManager.update: Error!');
    }
  }
}
