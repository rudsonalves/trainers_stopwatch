import 'dart:async';

import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

import '../../common/singletons/app_settings.dart';
import '../athletes_page/athletes_page.dart';
import '../personal_training_page/personal_training_page.dart';
import 'stopwatch_page_controller.dart';
import 'widgets/message_row.dart';
import 'widgets/stopwatch_dismissible.dart';

const double stopWatchHeight = 134;

class StopWatchPage extends StatefulWidget {
  const StopWatchPage({super.key});

  static const routeName = '/stopwatchs';

  @override
  State<StopWatchPage> createState() => _StopWatchPageState();
}

class _StopWatchPageState extends State<StopWatchPage> {
  final _controller = StopwatchPageController.instance;
  final _settings = AppSettings.instance;
  final _messageList = <String>[];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      effect(() {
        final message = _controller.historyMessage.value;
        if (message.isNotEmpty &&
            !_messageList.contains(message) &&
            message != 'none') {
          _messageList.add(message);
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _addStopwatchs() async {
    await Navigator.pushNamed(context, AthletesPage.routeName);
    _controller.addStopwatch();
    setState(() {});
  }

  Future<bool> _removeStopwatch(int athleteId) async {
    _controller.removeStopwatch(athleteId);
    setState(() {});
    return true;
  }

  Future<void> _managerStopwatch(int athleteId) async {
    final stopwatch = _controller.stopwatchList.firstWhere(
      (stopwatch) => stopwatch.athlete.id == athleteId,
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
      itemCount: _controller.stopwatchLength(),
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

  double _sizedBoxHeigth() {
    int length = _controller.stopwatchLength();
    length = length == 0 ? 1 : length;
    length = length > 4 ? 4 : length;
    return length * stopWatchHeight;
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        elevation: 4,
        title: const Text('Trainer\'s Stopwatch'),
        actions: [
          IconButton(
            icon: Icon(
              _settings.themeMode.watch(context) == ThemeMode.dark
                  ? Icons.dark_mode
                  : Icons.light_mode,
            ),
            onPressed: _settings.toggleThemeMode,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          children: [
            _stopWatchListView(),
            Expanded(
              child: Card(
                margin: EdgeInsets.zero,
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: ListenableBuilder(
                    listenable: _controller.historyMessage.toValueListenable(),
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
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addStopwatchs,
        child: Icon(
          Icons.group_add,
          color: primary.withOpacity(.5),
        ),
      ),
    );
  }
}
