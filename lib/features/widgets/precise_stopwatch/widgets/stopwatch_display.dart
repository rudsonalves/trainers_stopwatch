import 'package:flutter/material.dart';

import '../../../../common/theme/app_font_style.dart';

class StopwatchDisplay extends StatelessWidget {
  final ValueNotifier<Duration> durationTraining;

  const StopwatchDisplay({
    super.key,
    required this.durationTraining,
  });

  String formatCs(Duration duration) {
    final durationStr = duration.toString();
    final point = durationStr.indexOf('.');
    return durationStr.substring(0, point + 3);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          width: 1,
          color: colorScheme.primary.withOpacity(0.2),
        ),
      ),
      child: ValueListenableBuilder(
        valueListenable: durationTraining,
        builder: (context, value, _) => Text(
          formatCs(value),
          style: AppFontStyle.ibm26.copyWith(
            color: colorScheme.primary,
          ),
        ),
      ),
    );
  }
}
