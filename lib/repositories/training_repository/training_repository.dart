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

import '../../common/models/training_model.dart';
import '../../store/stores/training_store.dart';
import 'abstract_training_repository.dart';

class TrainingRepository implements AbstractTrainingRepository {
  final _store = TrainingStore();

  @override
  Future<int> insert(TrainingModel training) async {
    final id = await _store.insert(training.toMap());
    training.id = id;

    return id;
  }

  @override
  Future<TrainingModel?> query(int id) async {
    final map = await _store.query(id);
    if (map == null) return null;
    final training = TrainingModel.fromMap(map);
    return training;
  }

  @override
  Future<List<TrainingModel>> queryAllFromUser(int userId) async {
    final mapList = await _store.queryAllFromUser(userId);
    if (mapList.isEmpty) return [];
    final trainingList =
        mapList.map((map) => TrainingModel.fromMap(map!)).toList();
    return trainingList;
  }

  @override
  Future<int> delete(TrainingModel training) async {
    final result = await _store.delete(training.id!);
    return result;
  }

  @override
  Future<int> update(TrainingModel training) async {
    final result = await _store.update(training.id!, training.toMap());
    return result;
  }
}
