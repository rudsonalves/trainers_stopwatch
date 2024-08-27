// Copyright (C) 2024 Rudson Alves
// 
// This file is part of trainers_stopwatch.
// 
// trainers_stopwatch is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
// 
// trainers_stopwatch is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
// 
// You should have received a copy of the GNU General Public License
// along with trainers_stopwatch.  If not, see <https://www.gnu.org/licenses/>.

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

  Future<HistoryModel?> getById(int id) async {
    final history = await _repository.getById(id);
    return history;
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

  Future<void> update(HistoryModel history) async {
    int index = findIndex(history.id!);

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
