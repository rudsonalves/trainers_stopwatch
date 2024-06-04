import 'package:flutter/material.dart';

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
  final ValueNotifier<String> selectedSpeedUnit;
  final List<String> speedUnits;
  final Map<String, List<String>> speedAllowedValues;
  final ValueNotifier<String> selectedDistUnit;

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
        ValueListenableBuilder(
          valueListenable: widget.selectedDistUnit,
          builder: (context, value, _) => DropdownButton<String>(
            value: widget.selectedSpeedUnit.value,
            items: widget.speedUnits.map(
              (item) {
                final enable = widget.speedAllowedValues[value]!.contains(item);
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
        ),
      ],
    );
  }
}
