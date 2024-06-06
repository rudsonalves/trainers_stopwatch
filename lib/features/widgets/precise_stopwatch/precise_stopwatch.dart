import 'package:flutter/material.dart';

import '../../../common/constants.dart';
import '../../../common/singletons/app_settings.dart';
import '../../../models/user_model.dart';
import '../edit_training_dialog/edit_training_dialog.dart';
import 'precise_stopwatch_controller.dart';
import 'widgets/user_image_name.dart';
import 'widgets/lap_split_counters.dart';
import 'widgets/stopwatch_button_bar.dart';
import 'widgets/stopwatch_display.dart';

class PreciseStopwatch extends StatefulWidget {
  final UserModel user;
  final PreciseStopwatchController controller;
  final bool isNotClone;

  const PreciseStopwatch({
    super.key,
    required this.user,
    required this.controller,
    this.isNotClone = true,
  });

  @override
  State<PreciseStopwatch> createState() => _PreciseStopwatchState();
}

class _PreciseStopwatchState extends State<PreciseStopwatch> {
  late final PreciseStopwatchController _controller;
  final ValueNotifier<int?> maxLaps = ValueNotifier<int?>(null);
  final trainingColor = ValueNotifier<Color>(primaryColor);
  final app = AppSettings.instance;

  String name = 'Name';
  String image = defaultPhotoImage;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
    if (widget.isNotClone) {
      _controller.init(widget.user);
    }

    maxLaps.value = _controller.training.maxlaps;
    name = widget.user.name;
    image = widget.user.photo ?? defaultPhotoImage;
    trainingColor.value = _controller.training.color;
  }

  @override
  void dispose() {
    if (widget.isNotClone) {
      _controller.dispose();
    }
    trainingColor.dispose();
    maxLaps.dispose();
    super.dispose();
  }

  Future<void> _editTraining() async {
    await EditTrainingDialog.open(
      context,
      userName: _controller.user.name,
      training: _controller.training,
    );

    _controller.updateSplitLapLength();
    maxLaps.value = _controller.training.maxlaps;
    _controller.bloc.maxLaps = _controller.training.maxlaps;
    trainingColor.value = _controller.training.color;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: trainingColor,
        builder: (context, value, _) {
          return Container(
            decoration: BoxDecoration(
              color: value.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  UserImageName(image: image, name: name),
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
                        userId: widget.user.id!,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        });
  }
}
