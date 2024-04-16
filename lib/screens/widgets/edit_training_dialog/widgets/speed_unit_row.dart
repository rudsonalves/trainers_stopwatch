import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

class SpeedUnitRow extends StatefulWidget {
  const SpeedUnitRow({
    super.key,
    required this.label,
    required this.selectedSpeedUnit,
    required this.speedUnits,
    required this.speedAllowedValues,
    required this.selectedDistUnit,
  });

  final String label;
  final Signal<String> selectedSpeedUnit;
  final List<String> speedUnits;
  final Map<String, List<String>> speedAllowedValues;
  final Signal<String> selectedDistUnit;

  @override
  State<SpeedUnitRow> createState() => _SpeedUnitRowState();
}

class _SpeedUnitRowState extends State<SpeedUnitRow> {
  @override
  Widget build(BuildContext context) {
    final colorscheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Text(widget.label),
        const SizedBox(width: 8),
        DropdownButton<String>(
          value: widget.selectedSpeedUnit(),
          items: widget.speedUnits.map(
            (item) {
              final enable = widget
                  .speedAllowedValues[widget.selectedDistUnit.watch(context)]!
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
