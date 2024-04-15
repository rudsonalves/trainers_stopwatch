import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:signals/signals_flutter.dart';

import '../../../bloc/stopwatch_bloc.dart';
import '../../../bloc/stopwatch_state.dart';
import '../../../common/constants.dart';
import '../../../common/icons/stopwatch_icons_icons.dart';
import '../../../common/theme/app_font_style.dart';
import '../../../models/athlete_model.dart';
import '../common/custon_icon_button.dart';
import '../common/set_distance_dialog.dart';
import '../common/show_athlete_image.dart';
import 'precise_stopwatch_controller.dart';

class PreciseStopwatch extends StatefulWidget {
  final AthleteModel athlete;
  final PreciseStopwatchController controller;
  final bool isNotClone;

  const PreciseStopwatch({
    super.key,
    required this.athlete,
    required this.controller,
    this.isNotClone = true,
  });

  @override
  State<PreciseStopwatch> createState() => _PreciseStopwatchState();
}

class _PreciseStopwatchState extends State<PreciseStopwatch> {
  late final PreciseStopwatchController _controller;

  String name = 'Name';
  String image = defaultPhotoImage;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
    if (widget.isNotClone) {
      _controller.init(widget.athlete);
    }

    name = widget.athlete.name;
    image = widget.athlete.photo ?? defaultPhotoImage;
  }

  @override
  void dispose() {
    if (widget.isNotClone) {
      _controller.dispose();
    }
    super.dispose();
  }

  Future<void> _setTraining() async {
    await SetDistancesDialog.open(
      context,
      athleteName: _controller.athlete.name,
      training: _controller.training,
    );

    _controller.updateSplitLapLength();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final onSurfaceVariant = colorScheme.onSurfaceVariant;
    // final outlineVariant = colorScheme.outlineVariant;

    return Card(
      elevation: 2,
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
                SizedBox(
                  width: 70,
                  child: Text(
                    name.split(' ').first,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        width: 1,
                        color: colorScheme.primary.withOpacity(0.2),
                      ),
                    ),
                    child: Text(
                      _controller.formatCs(
                          _controller.durationTraining.watch(context)),
                      style: AppFontStyle.ibm26.copyWith(
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    BlocConsumer<StopwatchBloc, StopwatchState>(
                      bloc: _controller.bloc,
                      listener: (context, state) {},
                      builder: (context, state) {
                        switch (_controller.state) {
                          case StopwatchStateInitial():
                            return ButtonBar(
                              children: [
                                CustomIconButton(
                                  onPressed: _controller.blocStartTimer,
                                  label: 'Start',
                                  icon: Icon(
                                    StopwatchIcons.start,
                                    color: onSurfaceVariant,
                                  ),
                                ),
                                CustomIconButton(
                                  onPressed: _setTraining,
                                  label: 'Sets',
                                  icon: Icon(
                                    Icons.settings,
                                    color: onSurfaceVariant,
                                  ),
                                ),
                              ],
                            );
                          case StopwatchStateRunning():
                            return ButtonBar(
                              children: [
                                (_controller.bloc.splitCounter.watch(context) ==
                                        _controller.bloc.splitCounterMax - 1)
                                    ? Badge(
                                        label: Text(
                                          _controller.bloc.lapCounter
                                              .watch(context)
                                              .toString(),
                                        ),
                                        child: CustomIconButton(
                                          onPressed: _controller.blocLapTimer,
                                          label: 'Laps',
                                          icon: Icon(
                                            StopwatchIcons.lap1,
                                            color: onSurfaceVariant,
                                          ),
                                        ),
                                      )
                                    : Badge(
                                        label: Text(
                                          _controller.bloc
                                              .splitCounter()
                                              .toString(),
                                        ),
                                        child: CustomIconButton(
                                          onPressed: _controller.blocSplitTimer,
                                          label: 'Split',
                                          icon: Icon(
                                            StopwatchIcons.partial,
                                            color: onSurfaceVariant,
                                          ),
                                        ),
                                      ),
                                CustomIconButton(
                                  onPressed: _controller.blocPauseTimer,
                                  label: 'Pause',
                                  icon: Icon(
                                    StopwatchIcons.pause,
                                    color: onSurfaceVariant,
                                  ),
                                ),
                              ],
                            );
                          case StopwatchStatePaused():
                            return ButtonBar(
                              children: [
                                CustomIconButton(
                                  onPressed: _controller.blocStartTimer,
                                  label: 'Cont.',
                                  icon: Icon(
                                    StopwatchIcons.start,
                                    color: onSurfaceVariant,
                                  ),
                                ),
                                CustomIconButton(
                                  onLongPressed: _controller.blocResetTimer,
                                  label: 'Reset',
                                  icon: Icon(
                                    StopwatchIcons.reset,
                                    color: onSurfaceVariant.withRed(130),
                                  ),
                                ),
                                CustomIconButton(
                                  onLongPressed: _controller.blocStopTimer,
                                  label: 'Finish',
                                  icon: Icon(
                                    StopwatchIcons.stop,
                                    color: onSurfaceVariant.withRed(130),
                                  ),
                                ),
                              ],
                            );
                          case StopwatchStateReset():
                            return ButtonBar(
                              children: [
                                CustomIconButton(
                                  onPressed: _controller.blocStartTimer,
                                  label: 'Start',
                                  icon: Icon(
                                    StopwatchIcons.start,
                                    color: onSurfaceVariant,
                                  ),
                                ),
                              ],
                            );
                          default:
                            return ButtonBar(
                              children: [
                                CustomIconButton(
                                  onPressed: _controller.blocStartTimer,
                                  label: 'Start',
                                  icon: Icon(
                                    StopwatchIcons.start,
                                    color: onSurfaceVariant,
                                  ),
                                ),
                              ],
                            );
                        }
                      },
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
