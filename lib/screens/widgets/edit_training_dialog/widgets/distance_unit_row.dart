import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

import '../../../../common/constants.dart';

class DistanceUnitRow extends StatefulWidget {
  final String label;
  final Signal<String> selectedUnit;
  final Signal<String> selectedSpeedUnit;

  const DistanceUnitRow({
    super.key,
    required this.label,
    required this.selectedUnit,
    required this.selectedSpeedUnit,
  });

  @override
  State<DistanceUnitRow> createState() => _DistanceUnitRowState();
}

class _DistanceUnitRowState extends State<DistanceUnitRow> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Text(widget.label),
        const SizedBox(width: 8),
        DropdownButton<String>(
          borderRadius: BorderRadius.circular(12),
          dropdownColor: colorScheme.primaryContainer,
          value: widget.selectedUnit(),
          items: distanceUnits.map(
            (item) {
              return DropdownMenuItem(
                value: item,
                child: Text(item),
              );
            },
          ).toList(),
          onChanged: (value) {
            if (value != null) {
              widget.selectedUnit.value = value;
              if (!speedAllowedValues[value]!
                  .contains(widget.selectedSpeedUnit())) {
                widget.selectedSpeedUnit.value =
                    speedAllowedValues[value]!.first;
              }
            }
          },
        ),
      ],
    );
  }
}
