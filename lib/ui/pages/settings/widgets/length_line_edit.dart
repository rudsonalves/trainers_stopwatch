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

import 'dart:async';

import 'package:flutter/material.dart';

import '/common/constants.dart';
import '/common/theme/app_font_style.dart';
import '/features/widgets/common/numeric_field.dart';

class LengthLineEdit extends StatefulWidget {
  final String lengthLabel;
  final double length;
  final String lengthUnit;
  final ValueChanged<double> onLengthChanged;
  final ValueChanged<String> onUnitChanged;

  const LengthLineEdit({
    super.key,
    required this.lengthLabel,
    required this.length,
    required this.lengthUnit,
    required this.onLengthChanged,
    required this.onUnitChanged,
  });

  @override
  State<LengthLineEdit> createState() => _LengthLineEditState();
}

class _LengthLineEditState extends State<LengthLineEdit> {
  final lengthController = TextEditingController();
  Timer? _lengthDebounce;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(covariant LengthLineEdit oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.length == widget.length) return;
    final current = double.tryParse(lengthController.text);
    if (current != widget.length) {
      lengthController.text = widget.length.toString();
    }
  }

  void _scheduleLengthChange(String text) {
    _lengthDebounce?.cancel();
    final value = double.tryParse(text);
    if (value == null || value <= 0 || value == widget.length) return;
    _lengthDebounce = Timer(
      const Duration(milliseconds: 400),
      () => widget.onLengthChanged(value),
    );
  }

  void _submitLength(String text) {
    _lengthDebounce?.cancel();
    final value = double.tryParse(text);
    if (value == null || value <= 0 || value == widget.length) return;
    widget.onLengthChanged(value);
  }

  @override
  void dispose() {
    _lengthDebounce?.cancel();
    lengthController.dispose();
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
              controller: lengthController,
              onChanged: _scheduleLengthChange,
              onSubmitted: _submitLength,
            ),
          ),
          DropdownButton<String>(
            dropdownColor: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
            value: widget.lengthUnit,
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
                widget.onUnitChanged(value);
              }
            },
          ),
        ],
      ),
    );
  }
}
