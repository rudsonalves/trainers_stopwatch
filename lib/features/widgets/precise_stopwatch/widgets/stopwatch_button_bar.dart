// Copyright (C) 2024 Rudson Alves
//
// This file is part of trainers_stopwatch.

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '/application/stopwatch/bloc/stopwatch_bloc.dart';
import '/application/stopwatch/bloc/stopwatch_state.dart';
import '/application/stopwatch/session/stopwatch_session_view_model.dart';
import '/common/icons/stopwatch_icons_icons.dart';
import '../../common/custon_icon_button.dart';

class StopwatchButtonBar extends StatelessWidget {
  final StopwatchSessionViewModel session;
  final Future<void> Function() setTraining;

  const StopwatchButtonBar({
    super.key,
    required this.session,
    required this.setTraining,
  });

  @override
  Widget build(BuildContext context) {
    final onSurfaceVariant = Theme.of(context).colorScheme.onSurfaceVariant;
    return BlocBuilder<StopwatchBloc, StopwatchState>(
      bloc: session.bloc,
      builder: (context, state) {
        final buttons = switch (state.status) {
          StopwatchStatus.idle => [
              CustomIconButton(
                onPressed:
                    session.isOperationRunning ? null : () => session.start(),
                label: 'PSStart'.tr(),
                icon: Icon(StopwatchIcons.start, color: onSurfaceVariant),
              ),
              CustomIconButton(
                onPressed: session.isOperationRunning ? null : setTraining,
                label: 'PSSets'.tr(),
                icon: Icon(Icons.settings, color: onSurfaceVariant),
              ),
            ],
          StopwatchStatus.running => [
              state.splitCount == state.splitsPerLap - 1
                  ? CustomIconButton(
                      onPressed: session.isOperationRunning
                          ? null
                          : () => session.lap(),
                      label: 'PSLaps'.tr(),
                      icon: Icon(StopwatchIcons.lap1, color: onSurfaceVariant),
                    )
                  : CustomIconButton(
                      onPressed: session.isOperationRunning
                          ? null
                          : () => session.split(),
                      label: 'PSSplit'.tr(),
                      icon:
                          Icon(StopwatchIcons.partial, color: onSurfaceVariant),
                    ),
              CustomIconButton(
                onPressed:
                    session.isOperationRunning ? null : () => session.pause(),
                label: 'PSPause'.tr(),
                icon: Icon(StopwatchIcons.pause, color: onSurfaceVariant),
              ),
            ],
          StopwatchStatus.paused => [
              CustomIconButton(
                onPressed:
                    session.isOperationRunning ? null : () => session.resume(),
                label: 'PSCont'.tr(),
                icon: Icon(StopwatchIcons.start, color: onSurfaceVariant),
              ),
              CustomIconButton(
                onLongPressed:
                    session.isOperationRunning ? null : () => session.reset(),
                label: 'PSReset'.tr(),
                icon: Icon(
                  StopwatchIcons.reset,
                  color: onSurfaceVariant.withRed(130),
                ),
              ),
              CustomIconButton(
                onLongPressed:
                    session.isOperationRunning ? null : () => session.finish(),
                label: 'PSFinish'.tr(),
                icon: Icon(
                  StopwatchIcons.stop,
                  color: onSurfaceVariant.withRed(130),
                ),
              ),
            ],
          StopwatchStatus.finished => [
              CustomIconButton(
                onPressed:
                    session.isOperationRunning ? null : () => session.start(),
                label: 'PSStart'.tr(),
                icon: Icon(StopwatchIcons.start, color: onSurfaceVariant),
              ),
            ],
        };

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            OverflowBar(children: buttons),
            if (session.hasPendingWrite)
              IconButton(
                tooltip: 'Retry',
                onPressed: session.isOperationRunning
                    ? null
                    : () => session.retryPendingWrite(),
                icon: const Icon(Icons.sync_problem),
              )
            else if (session.isOperationRunning)
              const SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else if (session.state.error != null)
              Tooltip(
                message: session.state.error!.message,
                child: const Icon(Icons.error_outline),
              ),
          ],
        );
      },
    );
  }
}
