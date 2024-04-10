import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:signals/signals_flutter.dart';

import '../../../bloc/stopwatch_bloc.dart';
import '../../../bloc/stopwatch_events.dart';
import '../../../bloc/stopwatch_state.dart';
import '../../../common/constants.dart';
import '../../../common/icons/stopwatch_icons_icons.dart';
import '../../../common/theme/app_font_style.dart';
import '../../../models/athlete_model.dart';
import '../common/custon_icon_button.dart';
import '../common/show_athlete_image.dart';

class PreciseStopwatch extends StatefulWidget {
  final StopwatchBloc stopwatchBloc;
  final AthleteModel? athlete;

  const PreciseStopwatch({
    super.key,
    required this.stopwatchBloc,
    this.athlete,
  });

  @override
  State<PreciseStopwatch> createState() => _PreciseStopwatchState();
}

class _PreciseStopwatchState extends State<PreciseStopwatch> {
  late StopwatchBloc bloc;
  String name = 'Name';
  String image = defaultPhotoImage;

  @override
  void initState() {
    super.initState();
    bloc = widget.stopwatchBloc;

    if (widget.athlete != null) {
      name = widget.athlete!.name;
      image = widget.athlete!.photo ?? defaultPhotoImage;
    }
  }

  @override
  void dispose() {
    bloc.dispose();
    super.dispose();
  }

  void _startTimer() {
    bloc.add(StopwatchEventRun());
  }

  void _pauseTimer() {
    bloc.add(StopwatchEventPause());
  }

  void _resetTimer() {
    bloc.add(StopwatchEventReset());
  }

  void _incrementeLap() {
    bloc.add(StopwatchEventLap());
  }

  void _splitTimer() {
    bloc.add(StopwatchEventSplit());
  }

  void _stopTimer() {
    bloc.add(StopwatchEventStop());
  }

  String _formatTimer(String duration) {
    final point = duration.indexOf('.');
    return duration.substring(0, point + 3);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final onSurfaceVariant = colorScheme.onSurfaceVariant;
    // final outlineVariant = colorScheme.outlineVariant;

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
                ShowAthleteImage(image),
                const SizedBox(height: 4),
                Text(name),
              ],
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                bloc.counter.watch(context).toString(),
                style: AppFontStyle.ibm30,
              ),
              CustomIconButton(
                onPressed: _incrementeLap,
                label: 'Laps',
                icon: Icon(
                  StopwatchIcons.lap1,
                  color: onSurfaceVariant,
                ),
              ),
            ],
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _formatTimer(bloc.elapsedDuration.watch(context).toString()),
                  style: AppFontStyle.ibm30,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    BlocConsumer<StopwatchBloc, StopwatchState>(
                      bloc: bloc,
                      builder: (context, state) {
                        if (bloc.state is! StopwatchStateRunning) {
                          return ButtonBar(
                            children: [
                              CustomIconButton(
                                onPressed: _startTimer,
                                label: bloc.state is StopwatchStatePaused
                                    ? 'Cont.'
                                    : 'Start',
                                icon: Icon(
                                  StopwatchIcons.start,
                                  color: onSurfaceVariant,
                                ),
                              ),
                              CustomIconButton(
                                onLongPressed: _resetTimer,
                                label: 'Reset',
                                icon: Icon(
                                  StopwatchIcons.reset,
                                  color: onSurfaceVariant.withRed(130),
                                ),
                              ),
                              if (bloc.state is StopwatchStatePaused)
                                CustomIconButton(
                                  onLongPressed: _stopTimer,
                                  label: 'Finish',
                                  icon: Icon(
                                    StopwatchIcons.stop,
                                    color: onSurfaceVariant.withRed(130),
                                  ),
                                ),
                            ],
                          );
                        } else {
                          return ButtonBar(
                            children: [
                              CustomIconButton(
                                onPressed: _splitTimer,
                                label: 'Split',
                                icon: Icon(
                                  StopwatchIcons.partial,
                                  color: onSurfaceVariant,
                                ),
                              ),
                              CustomIconButton(
                                onPressed: _pauseTimer,
                                label: 'Pause',
                                icon: Icon(
                                  StopwatchIcons.pause,
                                  color: onSurfaceVariant,
                                ),
                              ),
                            ],
                          );
                        }
                      },
                      listener: (context, state) {},
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
