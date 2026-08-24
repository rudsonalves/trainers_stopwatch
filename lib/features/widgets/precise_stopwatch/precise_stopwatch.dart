// Copyright (C) 2024 Rudson Alves
//
// This file is part of trainers_stopwatch.
//
// trainers_stopwatch is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// trainers_stopwatch is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with trainers_stopwatch.  If not, see <https://www.gnu.org/licenses/>.

import 'package:flutter/material.dart';

import '/common/constants.dart';
import '/common/models/user_model.dart';
import '/common/singletons/app_settings.dart';
import '../edit_training_dialog/edit_training_dialog.dart';
import 'precise_stopwatch_controller.dart';
import 'widgets/lap_split_counters.dart';
import 'widgets/stopwatch_button_bar.dart';
import 'widgets/stopwatch_display.dart';
import 'widgets/user_image_name.dart';

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
  static const _stopwatchHeight = 134.0;

  late final PreciseStopwatchController _controller;
  late final Future<void> _initialization;
  final ValueNotifier<int?> maxLaps = ValueNotifier<int?>(null);
  final trainingColor = ValueNotifier<Color>(primaryColor);
  // Legacy settings bridge; remove with stopwatch migration in backlog 007.
  final app = AppSettings.instance;

  String name = 'Name';
  String image = defaultPhotoImage;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
    name = widget.user.name;
    image = widget.user.photo ?? defaultPhotoImage;
    _initialization = _initialize();
  }

  Future<void> _initialize() async {
    if (widget.isNotClone) {
      await _controller.init(widget.user);
    }
    if (!mounted) return;
    maxLaps.value = _controller.training.maxlaps;
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
    trainingColor.value = _controller.training.color;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const SizedBox(
            height: _stopwatchHeight,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return const SizedBox(
            height: _stopwatchHeight,
            child: Center(child: Icon(Icons.error_outline)),
          );
        }

        return ValueListenableBuilder(
          valueListenable: trainingColor,
          builder: (context, value, _) => Container(
            decoration: BoxDecoration(
              color: value.withValues(alpha: 0.2),
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
                      StopwatchDisplay(bloc: _controller.bloc),
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
          ),
        );
      },
    );
  }
}
