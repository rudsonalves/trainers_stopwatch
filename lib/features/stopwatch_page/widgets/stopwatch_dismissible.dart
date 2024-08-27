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

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../bloc/stopwatch_state.dart';
import '../../../common/singletons/app_settings.dart';
import '../../widgets/common/dismissible_backgrounds.dart';
import '../../widgets/precise_stopwatch/precise_stopwatch.dart';

class StopwatDismissible extends StatefulWidget {
  final PreciseStopwatch stopwatch;
  final Future<bool> Function(int) removeStopwatch;
  final Future<void> Function(int) managerStopwatch;

  const StopwatDismissible({
    super.key,
    required this.stopwatch,
    required this.removeStopwatch,
    required this.managerStopwatch,
  });

  @override
  State<StopwatDismissible> createState() => _StopwatDismissibleState();
}

class _StopwatDismissibleState extends State<StopwatDismissible> {
  final app = AppSettings.instance;

  @override
  Widget build(BuildContext context) {
    final userId = widget.stopwatch.user.id!;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Focus(
        focusNode: app.isTutorial(userId) ? app.focusNodes[11] : null,
        child: Dismissible(
          key: GlobalKey(),
          background: DismissibleContainers.background(
            context,
            label: 'SWDLabel'.tr(),
            iconData: Icons.manage_accounts,
          ),
          secondaryBackground: DismissibleContainers.secondaryBackground(
            context,
            label: 'SWDLabelDel'.tr(),
          ),
          child: widget.stopwatch,
          confirmDismiss: (direction) async {
            if (direction == DismissDirection.endToStart) {
              final state = widget.stopwatch.controller.bloc.state;
              if (state is StopwatchStateRunning ||
                  state is StopwatchStatePaused) {
                return false;
              }
              bool result = await widget.removeStopwatch(userId);
              return result;
            }
            if (direction == DismissDirection.startToEnd) {
              widget.managerStopwatch(userId);
              return false;
            }
            return false;
          },
        ),
      ),
    );
  }
}
