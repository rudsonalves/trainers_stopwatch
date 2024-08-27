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

import '../../common/models/user_model.dart';
import '../../store/stores/user_store.dart';
import 'abstract_user_repository.dart';

class UserRepository implements AbstractUserRepository {
  final _store = UserStore();

  @override
  Future<int> insert(UserModel user) async {
    final id = await _store.insert(user.toMap());
    user.id = id;

    return id;
  }

  @override
  Future<UserModel?> query(int id) async {
    final map = await _store.query(id);
    if (map == null) return null;
    final user = UserModel.fromMap(map);
    return user;
  }

  @override
  Future<List<UserModel>> queryAll() async {
    final mapList = await _store.queryAll();
    if (mapList.isEmpty) return [];
    final userList = mapList.map((map) => UserModel.fromMap(map!)).toList();
    return userList;
  }

  @override
  Future<int> delete(UserModel user) async {
    final result = await _store.delete(user.id!);
    return result;
  }

  @override
  Future<int> update(UserModel user) async {
    final result = await _store.update(user.id!, user.toMap());
    return result;
  }

  @override
  Future<List<String>> getImagesList() async {
    return await _store.getImagesList();
  }
}
