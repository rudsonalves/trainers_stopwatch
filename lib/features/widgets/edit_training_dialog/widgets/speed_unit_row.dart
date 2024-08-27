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
import '../../../../common/singletons/app_settings.dart';

class SpeedUnitRow extends StatefulWidget {
  const SpeedUnitRow({
    super.key,
    required this.label,
    required this.selectedSpeedUnit,
    required this.selectedDistUnit,
  });

  final String label;
  final ValueNotifier<String> selectedSpeedUnit;
  final ValueNotifier<String> selectedDistUnit;

  @override
  State<SpeedUnitRow> createState() => _SpeedUnitRowState();
}

class _SpeedUnitRowState extends State<SpeedUnitRow> {
  final app = AppSettings.instance;

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
            borderRadius: BorderRadius.circular(12),
            dropdownColor: colorscheme.primaryContainer,
            value: widget.selectedSpeedUnit.value,
            items: speedUnits.map(
              (item) {
                final enable = speedAllowedValues[value]!.contains(item);
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
