import 'dart:async';

import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

import '../../common/singletons/app_settings.dart';
import '../athletes_page/athletes_page.dart';
import '../personal_training_page/personal_training_page.dart';
import '../widgets/common/dismissible_backgrounds.dart';
import 'stopwatch_page_controller.dart';

class StopWatchPage extends StatefulWidget {
  const StopWatchPage({super.key});

  static const routeName = '/stopwatchs';

  @override
  State<StopWatchPage> createState() => _StopWatchPageState();
}

class _StopWatchPageState extends State<StopWatchPage> {
  final _controller = StopwatchPageController.instance;
  final _settings = AppSettings.instance;
  final _listMessages = <String>[];
  Timer? _snackBarTimer;
  SnackBar? _currentSnackBar;
  bool enableSnackBar = true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (mounted) {
        _controller.snackBarMessage.listen(
          context,
          () => showSnackBar(_controller.snackBarMessage.value),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _snackBarTimer?.cancel();
    super.dispose();
  }

  Future<void> _addStopwatchs() async {
    await Navigator.pushNamed(context, AthletesPage.routeName);
    _controller.addStopwatch();
  }

  void showSnackBar(String? message) {
    if (!enableSnackBar) return;
    if (message != null && message.isNotEmpty) {
      _listMessages.add(message);
      if (_listMessages.length > 5) {
        _listMessages.removeAt(0);
      }

      _updateSnackBar();

      _snackBarTimer?.cancel();
      _snackBarTimer = Timer(const Duration(seconds: 5), () {
        _listMessages.clear();
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      });
    }
  }

  void _updateSnackBar() {
    _currentSnackBar = SnackBar(
      content: Column(
        children: _listMessages.reversed
            .map(
              (msg) => Text(msg),
            )
            .toList(),
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      duration: const Duration(days: 1),
    );

    ScaffoldMessenger.of(context)
        .removeCurrentSnackBar(reason: SnackBarClosedReason.remove);
    ScaffoldMessenger.of(context).showSnackBar(_currentSnackBar!);
  }

  Future<bool> _removeStopwatch(int index) async {
    _controller.removeStopwatch(index);
    return true;
  }

  Future<void> _managerStopwatch(int index) async {
    _snackBarTimer?.cancel();
    _snackBarTimer = Timer(const Duration(milliseconds: 200), () {
      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      }
    });

    enableSnackBar = false;
    if (!context.mounted) return;
    await Navigator.pushNamed(
      context,
      PersonalTrainingPage.routeName,
      arguments: {
        'stopwatch': _controller.stopwatchList[index],
      },
    );
    enableSnackBar = true;
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
        child: Center(
          child: ListView.builder(
            itemCount: _controller.stopwatchLenght.watch(context),
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Dismissible(
                background: DismissibleContainers.background(context,
                    label: 'Manage Training...',
                    iconData: Icons.manage_accounts),
                secondaryBackground:
                    DismissibleContainers.secondaryBackground(context),
                key: GlobalKey(),
                child: _controller.stopwatchList[index],
                confirmDismiss: (direction) async {
                  bool result = false;
                  if (direction == DismissDirection.endToStart) {
                    result = await _removeStopwatch(index);
                  }
                  if (direction == DismissDirection.startToEnd) {
                    _managerStopwatch(index);
                  }
                  return result;
                },
              ),
            ),
          ),
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
