import 'package:flutter/material.dart';

import '../widgets/precise_timer/precise_timer.dart';

class StopWatchPage extends StatefulWidget {
  const StopWatchPage({super.key});

  @override
  State<StopWatchPage> createState() => _StopWatchPageState();
}

class _StopWatchPageState extends State<StopWatchPage> {
  final List<Widget> _stopwatch = [
    PreciseTimer(
      key: GlobalKey(),
    )
  ];

  void _addPreciseTimer() {
    setState(() {
      _stopwatch.add(PreciseTimer(
        key: GlobalKey(),
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Independent Timers'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addPreciseTimer,
        child: Icon(
          Icons.add,
          color: primary.withOpacity(.5),
        ),
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
                    // color: Colors.green,
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
    );
  }
}
