// Copyright (C) 2024 Rudson Alves
//
// This file is part of trainers_stopwatch.

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '/ui/components/dismissibles/dismissible_backgrounds.dart';
import '/ui/components/precise_stopwatch/precise_stopwatch.dart';
import '../session/stopwatch_session_id.dart';
import '../session/stopwatch_session_view_model.dart';

class StopwatDismissible extends StatelessWidget {
  final StopwatchSessionViewModel session;
  final bool enabled;
  final Future<bool> Function(StopwatchSessionId) removeStopwatch;
  final Future<void> Function(StopwatchSessionViewModel) managerStopwatch;
  final VoidCallback? onPaused;

  const StopwatDismissible({
    super.key,
    this.enabled = true,
    required this.session,
    required this.removeStopwatch,
    required this.managerStopwatch,
    this.onPaused,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Focus(
        child: Dismissible(
          key: ValueKey(session.id.userId),
          direction:
              enabled ? DismissDirection.horizontal : DismissDirection.none,
          background: DismissibleContainers.background(
            context,
            label: 'SWDLabel'.tr(),
            iconData: Icons.manage_accounts,
          ),
          secondaryBackground: DismissibleContainers.secondaryBackground(
            context,
            label: 'SWDLabelDel'.tr(),
          ),
          confirmDismiss: (direction) async {
            if (direction == DismissDirection.endToStart) {
              return removeStopwatch(session.id);
            }
            if (direction == DismissDirection.startToEnd) {
              await managerStopwatch(session);
            }
            return false;
          },
          child: AbsorbPointer(
            absorbing: !enabled,
            child: PreciseStopwatch(
              session: session,
              onPaused: onPaused,
            ),
          ),
        ),
      ),
    );
  }
}
