import 'dart:developer';

import 'package:flutter/foundation.dart';

import '../../common/singletons/app_settings.dart';
import '../../manager/user_manager.dart';
import '../../models/user_model.dart';
import 'users_page_state.dart';

class UsersPageController extends ChangeNotifier {
  final _usersManager = UserManager.instance;
  UsersPageState _state = UsersPageStateInitial();

  UsersPageState get state => _state;
  List<UserModel> get users => _usersManager.users;

  final app = AppSettings.instance;

  void _changeState(UsersPageState newState) {
    _state = newState;
    notifyListeners();
  }

  Future<void> init() async {
    await _usersManager.init();
    getAllUsers();
  }

  Future<void> getAllUsers() async {
    try {
      _changeState(UsersPageStateLoading());
      await _usersManager.getAllUsers();
      _changeState(UsersPageStateSuccess());
    } catch (err) {
      log('UsersPageState.getAllUsers: $err');
      _changeState(UsersPageStateError());
    }
  }

  Future<void> addUser(UserModel user) async {
    try {
      _changeState(UsersPageStateLoading());
      await _usersManager.insert(user);
      if (app.tutorialOn) {
        app.tutorialId = user.id!;
      }
      _changeState(UsersPageStateSuccess());
    } catch (err) {
      log('UsersPageState.addUser: $err');
      _changeState(UsersPageStateError());
    }
  }

  Future<void> updateUser(UserModel user) async {
    try {
      _changeState(UsersPageStateLoading());
      await _usersManager.update(user);
      _changeState(UsersPageStateSuccess());
    } catch (err) {
      log('UsersPageState.updateUser: $err');
      _changeState(UsersPageStateError());
    }
  }

  Future<void> deleteUser(UserModel user) async {
    try {
      _changeState(UsersPageStateLoading());
      await _usersManager.delete(user);
      _changeState(UsersPageStateSuccess());
    } catch (err) {
      log('UsersPageState.updateUser: $err');
      _changeState(UsersPageStateError());
    }
  }
}
