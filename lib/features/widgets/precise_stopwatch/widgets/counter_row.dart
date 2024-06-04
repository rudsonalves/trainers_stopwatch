import 'package:flutter/material.dart';

import '../../../../common/theme/app_font_style.dart';

class CounterRow extends StatelessWidget {
  const CounterRow({
    super.key,
    required this.counter,
    required this.label,
  });

  final ValueNotifier<int> counter;
  final String label;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppFontStyle.roboto12,
        ),
        const SizedBox(width: 8),
        ValueListenableBuilder(
          valueListenable: counter,
          builder: (context, value, _) => Text(
            value.toString(),
            style: AppFontStyle.ibm14SemiBold.copyWith(
              color: primary,
            ),
          ),
        ),
      ],
    );
  }
}
