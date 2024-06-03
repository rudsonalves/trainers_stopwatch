import 'dart:async';

import '../models/user_model.dart';
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
}
