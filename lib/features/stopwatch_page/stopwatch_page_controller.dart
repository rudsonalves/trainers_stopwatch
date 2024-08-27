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

import 'package:flutter/material.dart';

import '../../common/models/messages_model.dart';
import '../../common/models/user_model.dart';
import '../widgets/precise_stopwatch/precise_stopwatch.dart';
import '../widgets/precise_stopwatch/precise_stopwatch_controller.dart';

class StopwatchPageController {
  StopwatchPageController._();
  static final _instance = StopwatchPageController._();
  static StopwatchPageController get instance => _instance;

  final List<PreciseStopwatch> _stopwatchs = [];

  final _stopwatchLength = ValueNotifier<int>(0);
  final _historyMessage = ValueNotifier<MessagesModel>(MessagesModel());
  final List<UserModel> _usersList = [];
  final List<UserModel> _newUsers = [];

  List<UserModel> get usersList => _usersList;
  List<UserModel> get newUsers => _newUsers;
  List<PreciseStopwatch> get stopwatchs => _stopwatchs;
  ValueNotifier<int> get stopwatchLength => _stopwatchLength;
  ValueNotifier<MessagesModel> get historyMessage => _historyMessage;

  void dispose() {
    _stopwatchLength.dispose();
    _historyMessage.dispose();
  }

  void addNewUsers(List<UserModel> newSelectedUsers) {
    for (final user in newSelectedUsers) {
      if (!_hasUser(user.id!)) {
        _newUsers.add(user);
      }
    }
  }

  void sendHistoryMessage(MessagesModel message) {
    _historyMessage.value = message;
  }

  void mergeUserLists() {
    if (_newUsers.isNotEmpty) {
      _usersList.addAll(_newUsers);
      _newUsers.clear();
    }
  }

  bool _hasUser(int id) {
    int index = _usersList.indexWhere((user) => user.id == id);
    return index >= 0;
  }

  void addStopwatch() {
    for (final user in newUsers) {
      final stopwatchController = PreciseStopwatchController();

      _stopwatchs.add(
        PreciseStopwatch(
          key: GlobalKey(),
          user: user,
          controller: stopwatchController,
        ),
      );
    }
    mergeUserLists();

    _stopwatchLength.value = _stopwatchs.length;
  }

  void removeStopwatch(int userId) {
    final itemIndex = _stopwatchs.indexWhere((sw) => sw.user.id! == userId);
    _usersList.removeWhere((item) => item.id == userId);
    _stopwatchs.removeAt(itemIndex);
    _stopwatchLength.value = _stopwatchs.length;
  }
}
