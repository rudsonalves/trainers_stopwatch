import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../bloc/stopwatch_bloc.dart';
import '../../../../common/theme/app_font_style.dart';
import 'counter_row.dart';

class LapSplitCouters extends StatelessWidget {
  final StopwatchBloc bloc;
  final ValueNotifier<int?> maxLaps;

  const LapSplitCouters({
    super.key,
    required this.bloc,
    required this.maxLaps,
  });

  Widget lapsHeader(int? value) {
    if (value != null) {
      final String lapLabel = value == 1 ? 'Lap' : 'Laps';
      return Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          '$value $lapLabel',
          style: AppFontStyle.roboto12,
        ),
      );
    } else {
      return Text(
        'PSCounters'.tr(),
        style: AppFontStyle.roboto12,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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
            ValueListenableBuilder(
                valueListenable: maxLaps,
                builder: (context, value, _) => lapsHeader(value)),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: CounterRow(
                label: 'PSLap'.tr(),
                counter: bloc.lapCounter,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: CounterRow(
                counter: bloc.splitCounter,
                label: 'PSSplit'.tr(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
