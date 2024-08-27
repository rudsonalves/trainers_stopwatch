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

import '../../../common/constants.dart';
import '../../../common/theme/app_font_style.dart';
import '../../widgets/common/numeric_field.dart';

class LengthLineEdit extends StatefulWidget {
  final String lengthLabel;
  final double length;
  final String lengthUnit;

  const LengthLineEdit({
    super.key,
    required this.lengthLabel,
    required this.length,
    required this.lengthUnit,
  });

  @override
  State<LengthLineEdit> createState() => _LengthLineEditState();
}

class _LengthLineEditState extends State<LengthLineEdit> {
  final lenghtController = TextEditingController();
  final unitController = TextEditingController();

  @override
  void initState() {
    super.initState();
    unitController.text = widget.lengthUnit;
  }

  @override
  void dispose() {
    lenghtController.dispose();
    unitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.lengthLabel,
            style: AppFontStyle.roboto16,
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 120,
            child: NumericField(
              value: widget.length,
              controller: lenghtController,
            ),
          ),
          DropdownButton<String>(
            dropdownColor: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
            value: unitController.text,
            items: distanceUnits
                .map(
                  (item) => DropdownMenuItem<String>(
                    value: item,
                    child: Text(
                      item,
                    ),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) {
                unitController.text = value;
              }
            },
          ),
        ],
      ),
    );
  }
}
