// Copyright (C) 2024 Rudson Alves
//
// This file is part of trainers_stopwatch.

import 'package:flutter/material.dart';

import '../../pages/stopwatch/session/stopwatch_session_view_model.dart';
import '../common/constants.dart';
import '../edit_training_dialog/edit_training_dialog.dart';
import 'widgets/lap_split_counters.dart';
import 'widgets/stopwatch_button_bar.dart';
import 'widgets/stopwatch_display.dart';
import 'widgets/user_image_name.dart';

class PreciseStopwatch extends StatelessWidget {
  final StopwatchSessionViewModel session;

  const PreciseStopwatch({
    super.key,
    required this.session,
  });

  Future<void> _editTraining(BuildContext context) async {
    final result = await EditTrainingDialog.open(
      context,
      userName: session.user.name,
      training: session.training,
      colorValue: session.colorValue,
    );
    if (result == null) return;
    session.updateTraining(
      result.training,
      colorValue: result.colorValue,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: session,
      builder: (context, _) {
        final color = Color(session.colorValue);
        return Container(
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                UserImageName(
                  image: session.user.photoReference ?? defaultPhotoImage,
                  name: session.user.name,
                ),
                LapSplitCouters(
                  bloc: session.bloc,
                  maxLaps: session.training.maxLaps,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    StopwatchDisplay(bloc: session.bloc),
                    StopwatchButtonBar(
                      session: session,
                      setTraining: () => _editTraining(context),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
