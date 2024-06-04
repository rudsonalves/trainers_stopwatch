import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:onboarding_overlay/onboarding_overlay.dart';

import '../../common/singletons/app_settings.dart';
import '../../models/messages_model.dart';
import '../users_page/users_overlay.dart';
import '../personal_training_page/personal_training_page.dart';
import '../widgets/common/generic_dialog.dart';
import 'stopwatch_page_controller.dart';
import 'widgets/message_row.dart';
import 'widgets/stopwatch_dismissible.dart';
import 'widgets/stopwatch_drawer.dart';

const double stopWatchHeight = 134;

class StopWatchPage extends StatefulWidget {
  const StopWatchPage({super.key});

  @override
  State<StopWatchPage> createState() => _StopWatchPageState();
}

class _StopWatchPageState extends State<StopWatchPage> {
  final _controller = StopwatchPageController.instance;
  final app = AppSettings.instance;
  final _messageList = <MessagesModel>[];
  late final OnboardingState? overlay;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    _controller.historyMessage.addListener(_onHistoryMessageChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      overlay = Onboarding.of(context);
      if (app.showTutorial) {
        if (overlay != null) {
          app.disableTutorial();
          app.tutorialOn = true;
          overlay!.show();
        }
      }
    });
  }

  void _onHistoryMessageChanged() {
    final message = _controller.historyMessage.value;
    // && message != 'none'
    if (message.isNotEmpty && !_messageList.contains(message)) {
      _messageList.add(message);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    app.dispose();
    super.dispose();
  }

  Future<void> _addStopwatchs() async {
    await Navigator.pushNamed(context, UsersOverlay.routeName);
    _controller.addStopwatch();
    setState(() {});

    if (app.tutorialOn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          overlay?.showFromIndex(11);
        }
      });
    }
  }

  Future<bool> _removeStopwatch(int userId) async {
    final result = await GenericDialog.open(context,
        title: 'SPRemoveTraining'.tr(),
        message: 'SPLongMsg'.tr(),
        actions: DialogActions.yesNo);
    if (result) {
      final userName = _controller.usersList
          .firstWhere(
            (user) => user.id == userId,
          )
          .name;
      _removeUserFromLogs(userName);
      _controller.removeStopwatch(userId);
      setState(() {});
    }
    return result;
  }

  void _removeUserFromLogs(String userName) {
    _messageList.removeWhere((message) => message.title == userName);
  }

  Future<void> _managerStopwatch(int userId) async {
    final stopwatch = _controller.stopwatchList.firstWhere(
      (stopwatch) => stopwatch.user.id == userId,
    );
    if (!context.mounted) return;
    await Navigator.pushNamed(
      context,
      PersonalTrainingPage.routeName,
      arguments: {
        'stopwatch': stopwatch,
      },
    );
  }

  Widget _stopWatchListView() {
    final listViewBuilder = ListView.builder(
      itemCount: _controller.stopwatchLength.value,
      itemBuilder: (context, index) => StopwatDismissible(
        stopwatch: _controller.stopwatchList[index],
        removeStopwatch: _removeStopwatch,
        managerStopwatch: _managerStopwatch,
      ),
    );

    return SizedBox(
      height: _sizedBoxHeigth(),
      child: listViewBuilder,
    );
  }

  Widget _logTimes() {
    final colorScheme = Theme.of(context).colorScheme;

    return Expanded(
      child: Focus(
        focusNode: app.tutorialOn ? app.focusNodes[17] : null,
        child: Container(
          margin: EdgeInsets.zero,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: colorScheme.secondaryContainer,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: ListenableBuilder(
              listenable: _controller.historyMessage,
              builder: (context, _) {
                final int lastIndex = _messageList.length - 1;

                return ListView.builder(
                  itemCount: _messageList.length,
                  itemBuilder: (context, index) => MessageRow(
                    _messageList[lastIndex - index],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  double _sizedBoxHeigth() {
    int length = _controller.stopwatchLength.value;
    length = length < 1 ? 1 : length;
    length = length > 4 ? 4 : length;
    return length * stopWatchHeight;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final primary = colorScheme.primary;

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        elevation: 4,
        title: Text('SPAppBarTitle'.tr()),
        actions: [
          IconButton(
            focusNode: app.focusNodes[0],
            icon: ValueListenableBuilder(
              valueListenable: app.brightnessMode,
              builder: (context, value, _) => Icon(
                value == Brightness.dark ? Icons.dark_mode : Icons.light_mode,
              ),
            ),
            onPressed: app.toggleBrightnessMode,
          ),
        ],
        leading: IconButton(
          focusNode: app.focusNodes[1],
          icon: const Icon(Icons.menu),
          onPressed: () => scaffoldKey.currentState?.openDrawer(),
        ),
      ),
      drawer: StopwatchDrawer(
        addStopwatchs: _addStopwatchs,
        focusNodes: app.focusNodes,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          children: [
            _stopWatchListView(),
            _logTimes(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        focusNode: app.focusNodes[7],
        onPressed: _addStopwatchs,
        child: Icon(
          Icons.group_add,
          color: primary.withOpacity(.5),
        ),
      ),
    );
  }
}
