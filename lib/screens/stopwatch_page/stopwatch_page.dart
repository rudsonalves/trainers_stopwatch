import 'package:flutter/material.dart';

import '../../bloc/stopwatch_bloc.dart';
import '../athletes_page/athletes_page.dart';
import '../widgets/precise_timer/precise_timer.dart';
import 'stopwatch_page_controller.dart';

class StopWatchPage extends StatefulWidget {
  const StopWatchPage({super.key});

  static const routeName = '/stopwatchs';

  @override
  State<StopWatchPage> createState() => _StopWatchPageState();
}

class _StopWatchPageState extends State<StopWatchPage> {
  final _controller = StopwatchPageController.instance;
  final List<Widget> _stopwatch = [];

  // void _addPreciseTimer() {
  //   setState(() {
  //     _stopwatch.add(PreciseTimer(
  //       key: GlobalKey(),
  //       stopwatchBloc: StopwatchBloc(),
  //     ));
  //   });
  // }

  Future<void> _addAthletes() async {
    await Navigator.pushNamed(context, AthletesPage.routeName).then((_) {
      for (final athlete in _controller.newAthletes) {
        _stopwatch.add(PreciseTimer(
          key: GlobalKey(),
          stopwatchBloc: StopwatchBloc(),
          athlete: athlete,
        ));
      }
      _controller.mergeAthleteLists();
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        elevation: 5,
        title: const Text('Trainer\'s Stopwatch'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        child: Center(
          child: ListView.builder(
            itemCount: _stopwatch.length,
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Dismissible(
                background: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.green.withOpacity(0.3),
                  ),
                ),
                secondaryBackground: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.red.withOpacity(0.3),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'Remove',
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.remove_circle),
                      ],
                    ),
                  ),
                ),
                key: GlobalKey(),
                child: _stopwatch[index],
                confirmDismiss: (direction) async {
                  if (direction == DismissDirection.endToStart) {
                    setState(() {
                      _stopwatch.removeAt(index);
                    });
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
        onPressed: _addAthletes,
        child: Icon(
          Icons.group_add,
          color: primary.withOpacity(.5),
        ),
      ),
    );
  }
}
