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

abstract class AbstractHistoryRepository {
  Future<int> insert(HistoryModel history);
  Future<HistoryModel?> getById(int id);
  Future<List<HistoryModel>> queryAllFromTraining(int trainingId);
  Future<int> delete(HistoryModel history);
  Future<int> update(HistoryModel history);
}
