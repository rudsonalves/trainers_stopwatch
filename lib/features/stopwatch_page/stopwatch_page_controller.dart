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
