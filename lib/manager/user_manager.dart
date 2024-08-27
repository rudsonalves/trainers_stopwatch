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

import 'dart:async';

import '../common/models/user_model.dart';
import '../repositories/user_repository/user_repository.dart';

class UserManager {
  UserManager._();
  static final UserManager _instance = UserManager._();
  static UserManager get instance => _instance;
  bool _started = false;

  final _repository = UserRepository();
  final List<UserModel> _users = [];

  List<UserModel> get users => _users;

  Future<void> init() async {
    if (!_started) {
      await getAllUsers();
      _started = true;
    }
  }

  Future<void> insert(UserModel user) async {
    if (user.id != null) {
      throw Exception('Sorry, There is a logical error.');
    }
    await _repository.insert(user);
    await getAllUsers();
  }

  Future<void> getAllUsers() async {
    users.clear();
    final newsUsers = await _repository.queryAll();
    users.addAll(newsUsers);
  }

  Future<void> update(UserModel user) async {
    int index = findIndex(user.id!);
    if (index < 0) {
      throw Exception(
        'UserManager.update: Error!',
      );
    }
    _repository.update(user);
    _users[index] = user;
  }

  Future<void> delete(UserModel user) async {
    int index = findIndex(user.id!);
    if (index < 0) {
      throw Exception(
        'UserManager.delete: Error!',
      );
    }
    await _repository.delete(user);
    _users.removeAt(index);
  }

  int findIndex(int id) {
    int findIndex = _users.indexWhere((user) => user.id == id);
    return findIndex;
  }

  Future<List<String>> getImagesList() async {
    return await _repository.getImagesList();
  }
}
