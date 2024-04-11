import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

import '../../common/singletons/app_settings.dart';
import '../athletes_page/athletes_page.dart';
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

  Future<void> _addStopwatchs() async {
    await Navigator.pushNamed(context, AthletesPage.routeName).then(
      (_) {
        _controller.addStopwatch();
      },
    );
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
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        child: Center(
          child: ListView.builder(
            itemCount: _controller.stopwatchLenght.watch(context),
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Dismissible(
                background:
                    DismissibleContainers.background(context, enable: false),
                secondaryBackground: DismissibleContainers.secondaryBackground(
                  context,
                ),
                key: GlobalKey(),
                child: _controller.stopwatch[index],
                confirmDismiss: (direction) async {
                  if (direction == DismissDirection.endToStart) {
                    _controller.removeStopwatch(index);
                    return true;
                  }
                  return false;
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
