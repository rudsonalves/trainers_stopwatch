// Copyright (C) 2024 Rudson Alves
//
// This file is part of trainers_stopwatch.

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '/ui/pages/stopwatch/session/stopwatch_session_view_model.dart';
import '../../pages/stopwatch/bloc/stopwatch_bloc.dart';
import '../../pages/stopwatch/bloc/stopwatch_state.dart';
import '../common/constants.dart';
import '../dialogs/generic_dialog.dart';
import '../edit_training_dialog/edit_training_dialog.dart';
import 'widgets/lap_split_counters.dart';
import 'widgets/stopwatch_button_bar.dart';
import 'widgets/stopwatch_display.dart';
import 'widgets/user_image_name.dart';

class PreciseStopwatch extends StatelessWidget {
  final StopwatchSessionViewModel session;
  final VoidCallback? onPaused;

  const PreciseStopwatch({
    super.key,
    required this.session,
    this.onPaused,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<StopwatchBloc, StopwatchState>(
      bloc: session.bloc,
      listenWhen: (previous, current) =>
          previous.status != StopwatchStatus.paused &&
          current.status == StopwatchStatus.paused,
      listener: (context, state) => onPaused?.call(),
      child: ListenableBuilder(
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
                    spacing: 4,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      StopwatchDisplay(bloc: session.bloc),
                      StopwatchButtonBar(
                        session: session,
                        setTraining: () => _editTraining(context),
                        reset: _resetFromLongPress,
                        finish: _finishFromLongPress,
                        confirmReset: () => _confirmReset(context),
                        confirmFinish: () => _confirmFinish(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _resetFromLongPress() async {
    await HapticFeedback.mediumImpact();
    await _reset();
  }

  Future<void> _finishFromLongPress() async {
    await HapticFeedback.mediumImpact();
    await _finish();
  }

  Future<void> _reset() => session.reset();

  Future<void> _finish() => session.finish();

  Future<void> _confirmReset(BuildContext context) async {
    final confirmed = await GenericDialog.open(
      context,
      title: 'PSResetConfirmTitle'.tr(),
      message: 'PSResetConfirmMessage'.tr(),
      actions: DialogActions.yesNo,
    );

    if (confirmed) {
      await _reset();
    }
  }

  Future<void> _confirmFinish(BuildContext context) async {
    final confirmed = await GenericDialog.open(
      context,
      title: 'PSFinishConfirmTitle'.tr(),
      message: 'PSFinishConfirmMessage'.tr(),
      actions: DialogActions.yesNo,
    );

    if (confirmed) {
      await _finish();
    }
  }

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
}
