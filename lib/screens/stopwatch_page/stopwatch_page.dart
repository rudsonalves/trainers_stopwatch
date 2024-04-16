import 'dart:async';

import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';
import 'package:trainers_stopwatch/common/theme/app_font_style.dart';

import '../../common/singletons/app_settings.dart';
import '../athletes_page/athletes_page.dart';
import '../personal_training_page/personal_training_page.dart';
import '../settings/settings_page.dart';
import '../trainings_page/trainings_page.dart';
import '../widgets/common/generic_dialog.dart';
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
    _settings.dispose();
    super.dispose();
  }

  Future<void> _addStopwatchs() async {
    await Navigator.pushNamed(context, AthletesPage.routeName);
    _controller.addStopwatch();
    setState(() {});
  }

  Future<bool> _removeStopwatch(int athleteId) async {
    final result = await GenericDialog.open(context,
        title: 'Remove Training',
        message:
            'Training records will be removed from the log but will still be'
            ' stored in the athlete\'s training file.',
        actions: DialogActions.yesNo);
    if (result) {
      final athleteName = _controller.athletesList
          .firstWhere(
            (athlete) => athlete.id == athleteId,
          )
          .name;
      _removeAthleteFromLogs(athleteName);
      _controller.removeStopwatch(athleteId);
      setState(() {});
    }
    return result;
  }

  void _removeAthleteFromLogs(String athleteName) {
    _messageList.removeWhere((message) => message.contains(athleteName));
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
    length = length < 2 ? 2 : length;
    length = length > 4 ? 4 : length;
    return length * stopWatchHeight;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final primary = colorScheme.primary;

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
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: colorScheme.onPrimary,
              ),
              child: const Text(
                'Training\'s Stopwatch Menu',
                style: AppFontStyle.roboto20SemiBold,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.people_alt_rounded),
              title: const Text('Athletes'),
              onTap: () async {
                Navigator.pop(context);
                _addStopwatchs();
              },
            ),
            ListTile(
              leading: const Icon(Icons.directions_run),
              title: const Text('Trainings'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, TrainingsPage.routeName);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, SettingsPage.routeName);
              },
            ),
          ],
        ),
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
