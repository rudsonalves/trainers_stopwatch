// Copyright (C) 2024 Rudson Alves
// 
// This file is part of trainers_stopwatch.
// 
// trainers_stopwatch is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
// 
// trainers_stopwatch is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
// 
// You should have received a copy of the GNU General Public License
// along with trainers_stopwatch.  If not, see <https://www.gnu.org/licenses/>.

import 'package:flutter/material.dart';

import '../../../../common/constants.dart';

class DistanceUnitRow extends StatefulWidget {
  final String label;
  final ValueNotifier<String> selectedUnit;
  final ValueNotifier<String> selectedSpeedUnit;

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
          value: widget.selectedUnit.value,
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
                  .contains(widget.selectedSpeedUnit.value)) {
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
