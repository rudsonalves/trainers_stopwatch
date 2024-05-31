import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';
import 'package:trainers_stopwatch/common/singletons/app_settings.dart';

import '../../../common/constants.dart';
import '../../../models/athlete_model.dart';
import '../edit_training_dialog/edit_training_dialog.dart';
import 'precise_stopwatch_controller.dart';
import 'widgets/athlete_image_name.dart';
import 'widgets/lap_split_counters.dart';
import 'widgets/stopwatch_button_bar.dart';
import 'widgets/stopwatch_display.dart';

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
  final Signal<int?> maxLaps = signal<int?>(null);
  final app = AppSettings.instance;

  String name = 'Name';
  String image = defaultPhotoImage;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
    if (widget.isNotClone) {
      _controller.init(widget.athlete);
    }

    maxLaps.value = _controller.training.maxlaps;
    name = widget.athlete.name;
    image = widget.athlete.photo ?? defaultPhotoImage;
  }

  @override
  void dispose() {
    if (widget.isNotClone) {
      _controller.dispose();
    }
    maxLaps.dispose();
    super.dispose();
  }

  Future<void> _editTraining() async {
    await EditTrainingDialog.open(
      context,
      athleteName: _controller.athlete.name,
      training: _controller.training,
    );

    _controller.updateSplitLapLength();
    maxLaps.value = _controller.training.maxlaps;
    _controller.bloc.maxLaps = _controller.training.maxlaps;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AthleteImageName(image: image, name: name),
            LapSplitCouters(
              bloc: _controller.bloc,
              maxLaps: maxLaps,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                StopwatchDisplay(
                    durationTraining: _controller.durationTraining),
                StopwatchButtonBar(
                  controller: _controller,
                  setTraining: _editTraining,
                  athleteId: widget.athlete.id!,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
