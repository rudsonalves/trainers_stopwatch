import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';
import 'package:trainers_stopwatch/common/singletons/app_settings.dart';

import '../../../../common/constants.dart';

class SpeedUnitRow extends StatefulWidget {
  const SpeedUnitRow({
    super.key,
    required this.label,
    required this.selectedSpeedUnit,
    required this.selectedDistUnit,
  });

  final String label;
  final Signal<String> selectedSpeedUnit;
  final Signal<String> selectedDistUnit;

  @override
  State<SpeedUnitRow> createState() => _SpeedUnitRowState();
}

class _SpeedUnitRowState extends State<SpeedUnitRow> {
  final appSettings = AppSettings.instance;

  @override
  Widget build(BuildContext context) {
    final colorscheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Text(widget.label),
        const SizedBox(width: 8),
        DropdownButton<String>(
          borderRadius: BorderRadius.circular(12),
          dropdownColor: colorscheme.primaryContainer,
          value: widget.selectedSpeedUnit(),
          items: speedUnits.map(
            (item) {
              final enable =
                  speedAllowedValues[widget.selectedDistUnit.watch(context)]!
                      .contains(item);
              return DropdownMenuItem(
                enabled: enable,
                value: item,
                child: Text(
                  item,
                  style: TextStyle(
                    color: enable
                        ? colorscheme.onSurface
                        : colorscheme.onSurface.withOpacity(0.3),
                  ),
                ),
              );
            },
          ).toList(),
          onChanged: (value) {
            if (value != null) {
              widget.selectedSpeedUnit.value = value;
            }
          },
        ),
      ],
    );
  }
}
