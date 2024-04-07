import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trainers_stopwatch/bloc/stopwatch_state.dart';

import '../../../bloc/stopwatch_bloc.dart';
import '../../../bloc/stopwatch_events.dart';
import '../common/custon_icon_button.dart';

class PreciseTimer extends StatefulWidget {
  final StopwatchBloc stopwatchBloc;
  const PreciseTimer({
    super.key,
    required this.stopwatchBloc,
  });

  @override
  State<PreciseTimer> createState() => _PreciseTimerState();
}

class _PreciseTimerState extends State<PreciseTimer> {
  late StopwatchBloc bloc;

  @override
  void initState() {
    super.initState();
    bloc = widget.stopwatchBloc;
  }

  @override
  void dispose() {
    bloc.dispose();
    super.dispose();
  }

  void _startTimer() {
    bloc.add(StopwatchEventRun());
  }

  void _stopTimer() {
    bloc.add(StopwatchEventPause());
  }

  void _resetTimer() {
    bloc.add(StopwatchEventReset());
  }

  void _incrementeCounter() {
    bloc.add(StopwatchEventCounterIncrement());
  }

  void _decrementCounter() {
    bloc.add(StopwatchEventCounterDecrement());
  }

  void _snapshotTimer() {}

  String _formatTimer(String duration) {
    final point = duration.indexOf('.');
    return duration.substring(0, point + 3);
  }

  @override
  Widget build(BuildContext context) {
    final onSurfaceVariant = Theme.of(context).colorScheme.onSurfaceVariant;

    return Card(
      elevation: 5,
      margin: EdgeInsets.zero,
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: 8,
              right: 0,
              top: 8,
              bottom: 8,
            ),
            child: Column(
              children: [
                SizedBox(
                  width: 80,
                  height: 80,
                  child: Image.asset(
                    'assets/images/person.png',
                  ),
                ),
                const Text('Name'),
              ],
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: _incrementeCounter,
                icon: const Icon(Icons.add_circle),
              ),
              ListenableBuilder(
                listenable: bloc.counter,
                builder: (context, _) {
                  return Text(
                    bloc.counter.value.toString(),
                    style: const TextStyle(
                      fontSize: 24,
                    ),
                  );
                },
              ),
              IconButton(
                onPressed: _decrementCounter,
                icon: const Icon(Icons.remove_circle),
              ),
            ],
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ListenableBuilder(
                    listenable: bloc.elapsed,
                    builder: (context, _) {
                      return Text(
                        _formatTimer(bloc.elapsed.value.toString()),
                        style: const TextStyle(
                          fontSize: 30,
                          fontFamily: 'IBMPlexMono',
                        ),
                      );
                    }),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    BlocConsumer<StopwatchBloc, StopwatchState>(
                      bloc: bloc,
                      builder: (context, state) {
                        if (bloc.state is! StopwatchStateRunning) {
                          return CustomIconButton(
                            onPressed: _startTimer,
                            icon: Icon(
                              Icons.play_circle,
                              color: onSurfaceVariant,
                            ),
                          );
                        } else {
                          return CustomIconButton(
                            onPressed: _snapshotTimer,
                            icon: Icon(
                              Icons.stars_sharp,
                              color: onSurfaceVariant,
                            ),
                          );
                        }
                      },
                      listener: (context, state) {},
                    ),
                    // if (bloc.state is! StopwatchStateRunning)
                    //   CustomIconButton(
                    //     onPressed: _startTimer,
                    //     icon: Icon(
                    //       Icons.play_circle,
                    //       color: onSurfaceVariant,
                    //     ),
                    //   ),
                    CustomIconButton(
                      onPressed: _stopTimer,
                      icon: Icon(
                        Icons.pause_circle,
                        color: onSurfaceVariant,
                      ),
                    ),
                    CustomIconButton(
                      onLongPressed: _resetTimer,
                      icon: Icon(
                        Icons.restart_alt,
                        color: onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
