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

import '../../common/models/history_model.dart';
import '../../store/stores/history_store.dart';
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
  Future<HistoryModel?> getById(int id) async {
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
    final result = await _store.update(history.toMap());
    return result;
  }
}
