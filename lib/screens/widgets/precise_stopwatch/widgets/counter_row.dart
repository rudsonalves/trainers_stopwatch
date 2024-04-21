import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

import '../../../../common/theme/app_font_style.dart';

class CounterRow extends StatelessWidget {
  const CounterRow({
    super.key,
    required this.counter,
    required this.label,
  });

  final Signal<int> counter;
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
        Text(
          counter.watch(context).toString(),
          style: AppFontStyle.ibm14SemiBold.copyWith(
            color: primary,
          ),
        ),
      ],
    );
  }
}
