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

  Future<void> delete(int historyId) async {
    int index = findIndex(historyId);
    final history = _histories[index];
    final duration = history.duration;

    if (index < 1 || index >= _histories.length) {
      throw Exception('HistoryManager.delete: Error!');
    }

    final result = await _repository.delete(history);
    if (result > 0) {
      _histories.removeAt(index);

      if (index >= _histories.length) return;
      _histories[index].duration += duration;
      await _repository.update(_histories[index]);
    } else {
      throw Exception('HistoryManager.delete: Error!');
    }
  }

  Future<void> update(int historyId) async {
    int index = findIndex(historyId);
    final history = _histories[index];

    final result = await _repository.update(history);
    if (result > 0) {
      if (index < 0) {
        throw Exception('HistoryManager.update: Error!');
      }

      _histories[index] = history;
    } else {
      throw Exception('HistoryManager.update: Error!');
    }
  }

  int findIndex(int historyId) {
    return _histories.indexWhere((item) => item.id! == historyId);
  }
}
