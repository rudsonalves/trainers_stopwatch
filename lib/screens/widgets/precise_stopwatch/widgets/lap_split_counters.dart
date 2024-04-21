import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:trainers_stopwatch/common/theme/app_font_style.dart';

import '../../../../bloc/stopwatch_bloc.dart';
import 'counter_row.dart';

class LapSplitCouters extends StatelessWidget {
  final ColorScheme colorScheme;
  final StopwatchBloc bloc;

  const LapSplitCouters({
    super.key,
    required this.colorScheme,
    required this.bloc,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
        top: 8,
        left: 0,
        bottom: 26,
      ),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: colorScheme.primary.withOpacity(0.2),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'PSCounters'.tr(),
              style: AppFontStyle.roboto12,
            ),
            const SizedBox(height: 4),
            CounterRow(
              label: 'PSLap'.tr(),
              counter: bloc.lapCounter,
            ),
            const SizedBox(height: 4),
            CounterRow(
              counter: bloc.splitCounter,
              label: 'PSSplit'.tr(),
            ),
          ],
        ),
      ),
    );
  }
}
