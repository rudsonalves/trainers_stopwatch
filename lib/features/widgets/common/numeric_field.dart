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

class NumericField extends StatefulWidget {
  final String? label;
  final bool enable;
  final double? value;
  final TextEditingController controller;
  final FocusNode? focusNode;
  final void Function(String)? onSubmitted;
  final void Function(String)? onChanged;

  const NumericField({
    super.key,
    this.label,
    this.enable = true,
    this.value,
    required this.controller,
    this.focusNode,
    this.onSubmitted,
    this.onChanged,
  });

  @override
  State<NumericField> createState() => _NumericFieldState();
}

class _NumericFieldState extends State<NumericField> {
  final reInitZeroNumber = RegExp(r'^0[1-9][\.\d]*$');
  String oldValue = '';

  @override
  void initState() {
    super.initState();

    oldValue = widget.value != null ? widget.value.toString() : '0';
    widget.controller.text = oldValue;

    widget.controller.addListener(_validadeNumber);
  }

  void _validadeNumber() {
    String newValue = widget.controller.text;

    // Remove spaces
    if (newValue != newValue.trim()) {
      _setControllerText();
      return;
    }

    // Replace empty string by '0'
    if (newValue.isEmpty) {
      oldValue = '0';
      _setControllerText();
      return;
    }

    // Remove zeros of start of number ('02' -> '2')
    if (reInitZeroNumber.hasMatch(newValue)) {
      oldValue = newValue.substring(1);
      _setControllerText();
      return;
    }

    // Check if is a valid number
    final result = double.tryParse(newValue);
    if (result == null) {
      _setControllerText();
      return;
    }

    oldValue = newValue;
  }

  void _setControllerText() {
    widget.controller.text = oldValue;
    widget.controller.selection = TextSelection.fromPosition(
      TextPosition(offset: oldValue.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: widget.controller,
        keyboardType: TextInputType.number,
        focusNode: widget.focusNode,
        decoration: InputDecoration(
          label: Text(widget.label ?? ''),
          floatingLabelBehavior: FloatingLabelBehavior.always,
          enabled: widget.enable,
        ),
        onSubmitted: widget.onSubmitted,
        onChanged: widget.onChanged,
      ),
    );
  }
}
