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
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../bloc/stopwatch_bloc.dart';
import '../../../../bloc/stopwatch_state.dart';
import '../../../../common/icons/stopwatch_icons_icons.dart';
import '../../../../common/singletons/app_settings.dart';
import '../../common/custon_icon_button.dart';
import '../precise_stopwatch_controller.dart';

class StopwatchButtonBar extends StatefulWidget {
  final PreciseStopwatchController controller;
  final Future<void> Function() setTraining;
  final int userId;

  const StopwatchButtonBar({
    super.key,
    required this.controller,
    required this.setTraining,
    required this.userId,
  });

  @override
  State<StopwatchButtonBar> createState() => _StopwatchButtonBarState();
}

class _StopwatchButtonBarState extends State<StopwatchButtonBar> {
  late final PreciseStopwatchController controller;
  final app = AppSettings.instance;

  @override
  void initState() {
    super.initState();
    controller = widget.controller;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final onSurfaceVariant = colorScheme.onSurfaceVariant;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        BlocConsumer<StopwatchBloc, StopwatchState>(
          bloc: controller.bloc,
          listener: (context, state) {},
          builder: (context, state) {
            switch (controller.state) {
              case StopwatchStateInitial():
                return OverflowBar(
                  children: [
                    CustomIconButton(
                      focusNode: app.isTutorial(widget.userId)
                          ? app.focusNodes[12]
                          : null,
                      onPressed: controller.blocStartTimer,
                      label: 'PSStart'.tr(),
                      icon: Icon(
                        StopwatchIcons.start,
                        color: onSurfaceVariant,
                      ),
                    ),
                    CustomIconButton(
                      focusNode: app.isTutorial(widget.userId)
                          ? app.focusNodes[13]
                          : null,
                      onPressed: widget.setTraining,
                      label: 'PSSets'.tr(),
                      icon: Icon(
                        Icons.settings,
                        color: onSurfaceVariant,
                      ),
                    ),
                  ],
                );
              case StopwatchStateRunning():
                return ValueListenableBuilder(
                  valueListenable: controller.bloc.splitCounter,
                  builder: (context, value, _) => OverflowBar(
                    children: [
                      (value == controller.bloc.splitCounterMax - 1)
                          ? CustomIconButton(
                              focusNode: app.isTutorial(widget.userId)
                                  ? app.focusNodes[14]
                                  : null,
                              onPressed: controller.blocLapTimer,
                              label: 'PSLaps'.tr(),
                              icon: Icon(
                                StopwatchIcons.lap1,
                                color: onSurfaceVariant,
                              ),
                            )
                          : CustomIconButton(
                              focusNode: app.isTutorial(widget.userId)
                                  ? app.focusNodes[14]
                                  : null,
                              onPressed: controller.blocSplitTimer,
                              label: 'PSSplit'.tr(),
                              icon: Icon(
                                StopwatchIcons.partial,
                                color: onSurfaceVariant,
                              ),
                            ),
                      CustomIconButton(
                        focusNode: app.isTutorial(widget.userId)
                            ? app.focusNodes[15]
                            : null,
                        onPressed: controller.blocPauseTimer,
                        label: 'PSPause'.tr(),
                        icon: Icon(
                          StopwatchIcons.pause,
                          color: onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                );
              case StopwatchStatePaused():
                return OverflowBar(
                  children: [
                    CustomIconButton(
                      focusNode: app.isTutorial(widget.userId)
                          ? app.focusNodes[12]
                          : null,
                      onPressed: controller.blocStartTimer,
                      label: 'PSCont'.tr(),
                      icon: Icon(
                        StopwatchIcons.start,
                        color: onSurfaceVariant,
                      ),
                    ),
                    CustomIconButton(
                      onLongPressed: controller.blocResetTimer,
                      label: 'PSReset'.tr(),
                      icon: Icon(
                        StopwatchIcons.reset,
                        color: onSurfaceVariant.withRed(130),
                      ),
                    ),
                    CustomIconButton(
                      focusNode: app.isTutorial(widget.userId)
                          ? app.focusNodes[16]
                          : null,
                      onLongPressed: controller.blocStopTimer,
                      label: 'PSFinish'.tr(),
                      icon: Icon(
                        StopwatchIcons.stop,
                        color: onSurfaceVariant.withRed(130),
                      ),
                    ),
                  ],
                );
              case StopwatchStateReset():
                return OverflowBar(
                  children: [
                    CustomIconButton(
                      focusNode: app.isTutorial(widget.userId)
                          ? app.focusNodes[12]
                          : null,
                      onPressed: controller.blocStartTimer,
                      label: 'PSStart'.tr(),
                      icon: Icon(
                        StopwatchIcons.start,
                        color: onSurfaceVariant,
                      ),
                    ),
                  ],
                );
              default:
                return OverflowBar(
                  children: [
                    CustomIconButton(
                      focusNode: app.isTutorial(widget.userId)
                          ? app.focusNodes[12]
                          : null,
                      onPressed: controller.blocStartTimer,
                      label: 'PSStart'.tr(),
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
    );
  }
}
