import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

class DistanceUnitRow extends StatefulWidget {
  const DistanceUnitRow({
    super.key,
    required this.label,
    required this.selectedUnit,
    required this.distanceUnits,
    required this.speedAllowedValues,
    required this.selectedSpeedUnit,
  });

  final String label;
  final Signal<String> selectedUnit;
  final List<String> distanceUnits;
  final Map<String, List<String>> speedAllowedValues;
  final Signal<String> selectedSpeedUnit;

  @override
  State<DistanceUnitRow> createState() => _DistanceUnitRowState();
}

class _DistanceUnitRowState extends State<DistanceUnitRow> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(widget.label),
        const SizedBox(width: 8),
        DropdownButton<String>(
          value: widget.selectedUnit(),
          items: widget.distanceUnits.map(
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
              if (!widget.speedAllowedValues[value]!
                  .contains(widget.selectedSpeedUnit())) {
                widget.selectedSpeedUnit.value =
                    widget.speedAllowedValues[value]!.first;
              }
            }
          },
        ),
      ],
    );
  }
}
